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
