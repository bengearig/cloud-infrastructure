resource "random_string" "bootstrap" {
  length = 4
  special = false
  upper = false
}

resource "google_project" "bootstrap" {
  name            = "bootstrap"
  project_id      = "bootstrap-${random_string.bootstrap.result}"
  org_id = var.organization_id
  billing_account = var.billing_account_id
}

resource "google_project_service" "bootstrap" {
  project = google_project.bootstrap.project_id
  for_each = toset([
    "serviceusage.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudbilling.googleapis.com",
    "storage.googleapis.com",
    "iam.googleapis.com",
    "sqladmin.googleapis.com",
    "orgpolicy.googleapis.com",
    "secretmanager.googleapis.com",
  ])
  service = each.key
}

resource "google_storage_bucket" "bootstrap" {
  name                        = "${google_project.bootstrap.project_id}-tfstate"
  location                    = "US"
  project                     = google_project.bootstrap.project_id
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
}

resource "google_service_account" "bootstrap" {
  account_id   = "bootstrap"
  display_name = "bootstrap"
  project      = google_project.bootstrap.project_id
  depends_on = [
    google_project_service.bootstrap
  ]
}

resource "google_service_account_iam_binding" "bootstrap" {
  members            = [
    "user:contact@bengearig.com",
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_actions.name}/attribute.org/${var.github_org}"
  ]
  for_each = toset([
    "roles/iam.serviceAccountTokenCreator",
  ])
  role               = each.key
  service_account_id = google_service_account.bootstrap.id
  depends_on = [
    google_service_account.bootstrap,
    google_iam_workload_identity_pool.github_actions,
  ]
}

resource "google_organization_iam_member" "bootstrap" {
  org_id = var.organization_id
  for_each = toset([
    "roles/resourcemanager.organizationAdmin",
    "roles/resourcemanager.folderAdmin",
    "roles/resourcemanager.projectCreator",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/owner",
    "roles/orgpolicy.policyAdmin",
  ])
  role    = each.key
  member  = "serviceAccount:${google_service_account.bootstrap.email}"
}

resource "google_billing_account_iam_member" "bootstrap" {
  billing_account_id = var.billing_account_id
  for_each           = toset([
    "roles/billing.admin",
  ])
  role                = each.key
  member              = "serviceAccount:${google_service_account.bootstrap.email}"
}

resource "google_billing_account_iam_member" "bootstrap_temp" {
  billing_account_id = var.billing_account_id_temp
  for_each           = toset([
    "roles/billing.admin",
  ])
  role                = each.key
  member              = "serviceAccount:${google_service_account.bootstrap.email}"
}

######## Workload Identity Federation ########

resource "google_iam_workload_identity_pool" "github_actions" {
  project      = google_project.bootstrap.project_id
  workload_identity_pool_id = "github-actions-pool"
  depends_on = [
    google_service_account.bootstrap,
  ]
}

resource "google_iam_workload_identity_pool_provider" "github_actions" {
  project                           = google_project.bootstrap.project_id
  workload_identity_pool_id         = google_iam_workload_identity_pool.github_actions.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions-provider"
  oidc {
    allowed_audiences = [
      "https://github.com/${var.github_org}",
    ]
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
    "attribute.org"        = "assertion.repository_owner"
    "attribute.ref"        = "assertion.ref"
  }
  attribute_condition = "attribute.org == '${var.github_org}'"
  depends_on = [
    google_iam_workload_identity_pool.github_actions,
  ]
}

