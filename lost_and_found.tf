######## FOLDER ########

resource "google_folder" "lost_and_found" {
  display_name = var.lost_and_found_projects_prefix
  parent       = "organizations/${var.organization_id}"
}

######## PROJECTS ########

resource "random_string" "lost_and_found_dev" {
  length = 4
  special = false
  upper = false
}

resource "random_string" "lost_and_found_prod" {
  length = 4
  special = false
  upper = false
}

resource "google_project" "lost_and_found_dev" {
  name            = "${var.lost_and_found_projects_prefix}-dev"
  project_id      = "${var.lost_and_found_projects_prefix}-dev-${random_string.lost_and_found_dev.result}"
  folder_id       = google_folder.lost_and_found.id
  billing_account = var.billing_account_id
  depends_on = [
    google_folder.lost_and_found,
    random_string.lost_and_found_dev,
  ]
}

resource "google_project" "lost_and_found_prod" {
  name            = "${var.lost_and_found_projects_prefix}-prod"
  project_id      = "${var.lost_and_found_projects_prefix}-prod-${random_string.lost_and_found_prod.result}"
  folder_id       = google_folder.lost_and_found.id
  billing_account = var.billing_account_id
  depends_on = [
    google_folder.lost_and_found,
    random_string.lost_and_found_prod,
  ]
}

######## PROJECT SERVICES ########

resource "terraform_data" "lost_and_found_dev_enable_service_usage_api" {
  provisioner "local-exec" {
    command = "gcloud services enable serviceusage.googleapis.com cloudresourcemanager.googleapis.com --project ${google_project.lost_and_found_dev.project_id}"
  }
  depends_on = [
    google_project.lost_and_found_dev
  ]
}

resource "terraform_data" "lost_and_found_prod_enable_service_usage_api" {
  provisioner "local-exec" {
    command = "gcloud services enable serviceusage.googleapis.com cloudresourcemanager.googleapis.com --project ${google_project.lost_and_found_prod.project_id}"
  }
  depends_on = [
    google_project.lost_and_found_prod
  ]
}

resource "google_project_service" "lost_and_found_dev" {
  project = google_project.lost_and_found_dev.id
  for_each = toset([
    "secretmanager.googleapis.com",
    "sqladmin.googleapis.com",
  ])
  service            = each.key
  disable_on_destroy = false
  depends_on = [
    terraform_data.lost_and_found_dev_enable_service_usage_api
  ]
}

resource "google_project_service" "lost_and_found_prod" {
  project = google_project.lost_and_found_prod.id
  for_each = toset([
    "secretmanager.googleapis.com",
    "sqladmin.googleapis.com",
  ])
  service            = each.key
  disable_on_destroy = false
  depends_on = [
    terraform_data.lost_and_found_prod_enable_service_usage_api
  ]
}
