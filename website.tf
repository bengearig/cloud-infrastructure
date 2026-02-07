######## FOLDER ########

resource "google_folder" "website" {
  display_name = var.website_projects_prefix
  parent       = "organizations/${var.organization_id}"
}

######## PROJECTS ########

resource "random_string" "website_dev" {
  length = 4
  special = false
  upper = false
}

resource "random_string" "website_prod" {
  length = 4
  special = false
  upper = false
}

resource "google_project" "website_dev" {
  name            = "${var.website_projects_prefix}-dev"
  project_id      = "${var.website_projects_prefix}-dev-${random_string.website_dev.result}"
  folder_id       = google_folder.website.id
  billing_account = var.billing_account_id
  depends_on = [
    google_folder.website,
    random_string.website_dev,
  ]
}

resource "google_project" "website_prod" {
  name            = "${var.website_projects_prefix}-prod"
  project_id      = "${var.website_projects_prefix}-prod-${random_string.website_prod.result}"
  folder_id       = google_folder.website.id
  billing_account = var.billing_account_id
  depends_on = [
    google_folder.website,
    random_string.website_prod,
  ]
}
