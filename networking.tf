######## FOLDER ########

resource "google_folder" "networking" {
  display_name = var.networking_projects_prefix
  parent       = "organizations/${var.organization_id}"
}

######## PROJECTS ########

resource "random_string" "networking_dev" {
  length = 4
  special = false
  upper = false
}

resource "random_string" "networking_prod" {
  length = 4
  special = false
  upper = false
}

resource "google_project" "networking_dev" {
  name            = "${var.networking_projects_prefix}-dev"
  project_id      = "${var.networking_projects_prefix}-dev-${random_string.networking_dev.result}"
  folder_id       = google_folder.networking.id
  billing_account = var.billing_account_id_temp
  depends_on = [
    google_folder.networking,
    random_string.networking_dev,
    google_billing_account_iam_member.bootstrap_temp,
  ]
}

resource "google_project" "networking_prod" {
  name            = "${var.networking_projects_prefix}-prod"
  project_id      = "${var.networking_projects_prefix}-prod-${random_string.networking_prod.result}"
  folder_id       = google_folder.networking.id
  billing_account = var.billing_account_id_temp
  depends_on = [
    google_folder.networking,
    random_string.networking_prod,
    google_billing_account_iam_member.bootstrap_temp,
  ]
}

######## PROJECT SERVICES ########

resource "terraform_data" "networking_dev_enable_service_usage_api" {
  provisioner "local-exec" {
    command = "gcloud services enable serviceusage.googleapis.com cloudresourcemanager.googleapis.com --project ${google_project.networking_dev.project_id}"
  }
  depends_on = [
    google_project.networking_dev
  ]
}

resource "terraform_data" "networking_prod_enable_service_usage_api" {
  provisioner "local-exec" {
    command = "gcloud services enable serviceusage.googleapis.com cloudresourcemanager.googleapis.com --project ${google_project.networking_prod.project_id}"
  }
  depends_on = [
    google_project.networking_prod
  ]
}

resource "google_project_service" "networking_dev" {
  project = google_project.networking_dev.id
  for_each = toset([
    "compute.googleapis.com",
  ])
  service            = each.key
  disable_on_destroy = false
  depends_on = [
    terraform_data.networking_dev_enable_service_usage_api
  ]
}

resource "google_project_service" "networking_prod" {
  project = google_project.networking_prod.id
  for_each = toset([
    "compute.googleapis.com",
  ])
  service            = each.key
  disable_on_destroy = false
  depends_on = [
    terraform_data.networking_prod_enable_service_usage_api
  ]
}

######## NETWORKS ########

resource "google_compute_network" "networking_dev" {
  provider                = google-beta
  name                    = "${google_project.networking_dev.project_id}"
  project                 = google_project.networking_dev.project_id
  auto_create_subnetworks = false
  depends_on              = [
    google_project_service.networking_dev
  ]
}

resource "google_compute_network" "networking_prod" {
  provider                = google-beta
  name                    = "${google_project.networking_prod.project_id}"
  project                 = google_project.networking_prod.project_id
  auto_create_subnetworks = false
  depends_on              = [
    google_project_service.networking_prod
  ]
}
