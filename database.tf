######## FOLDER ########

resource "google_folder" "database" {
  display_name = var.database_projects_prefix
  parent       = "organizations/${var.organization_id}"
}

######## PROJECTS ########

resource "random_string" "database_dev" {
  length = 4
  special = false
  upper = false
}

resource "random_string" "database_prod" {
  length = 4
  special = false
  upper = false
}

resource "google_project" "database_dev" {
  name            = "${var.database_projects_prefix}-dev"
  project_id      = "${var.database_projects_prefix}-dev-${random_string.database_dev.result}"
  folder_id       = google_folder.database.id
  billing_account = var.billing_account_id_temp
  depends_on = [
    google_folder.database,
    random_string.database_dev,
  ]
}

resource "google_project" "database_prod" {
  name            = "${var.database_projects_prefix}-prod"
  project_id      = "${var.database_projects_prefix}-prod-${random_string.database_prod.result}"
  folder_id       = google_folder.database.id
  billing_account = var.billing_account_id_temp
  depends_on = [
    google_folder.database,
    random_string.database_prod,
  ]
}

######## PROJECT SERVICES ########

resource "terraform_data" "database_dev_enable_service_usage_api" {
  provisioner "local-exec" {
    command = "gcloud services enable serviceusage.googleapis.com cloudresourcemanager.googleapis.com --project ${google_project.database_dev.project_id}"
  }
  depends_on = [
    google_project.database_dev
  ]
}

resource "terraform_data" "database_prod_enable_service_usage_api" {
  provisioner "local-exec" {
    command = "gcloud services enable serviceusage.googleapis.com cloudresourcemanager.googleapis.com --project ${google_project.database_prod.project_id}"
  }
  depends_on = [
    google_project.database_prod
  ]
}

resource "google_project_service" "database_dev" {
  project = google_project.database_dev.id
  for_each = toset([
    "secretmanager.googleapis.com",
    "sqladmin.googleapis.com",
  ])
  service            = each.key
  disable_on_destroy = false
  depends_on = [
    terraform_data.database_dev_enable_service_usage_api
  ]
}

resource "google_project_service" "database_prod" {
  project = google_project.database_prod.id
  for_each = toset([
    "secretmanager.googleapis.com",
    "sqladmin.googleapis.com",
  ])
  service            = each.key
  disable_on_destroy = false
  depends_on = [
    terraform_data.database_prod_enable_service_usage_api
  ]
}

######## CLOUD SQL INSTANCES ########

resource "google_sql_database_instance" "database_dev" {
  provider         = google-beta
  name             = "${var.database_projects_prefix}"
  database_version = "POSTGRES_17"
  region           = var.database_projects_primary_region
  project          = google_project.database_dev.project_id
  deletion_protection = false
  settings {
    tier      = "db-f1-micro"
    edition   = "ENTERPRISE"
    disk_size = 10
    ip_configuration {
      ipv4_enabled = false
      psc_config {
        psc_enabled = true
        allowed_consumer_projects = [
          google_project.database_dev.project_id,
          google_project.website_dev.project_id,
          google_project.lost_and_found_dev.project_id,
        ]
      }
    }
    deletion_protection_enabled = true
  }
  depends_on = [
    google_project_service.database_dev
  ]
}

######## SQL USER ########

ephemeral "random_password" "database_dev" {
  length  = 16
  special = true
  upper   = true
  lower   = true
  numeric = true
}

resource "google_secret_manager_secret" "database_dev" {
  secret_id  = "${google_project.database_dev.project_id}"
  project    = google_project.database_dev.project_id
  replication {
    auto {}
  }
  depends_on = [
    google_project_service.database_dev
  ]
}

resource "google_secret_manager_secret_version" "database_dev" {
  secret         = google_secret_manager_secret.database_dev.id
  secret_data_wo = ephemeral.random_password.database_dev.result
  secret_data_wo_version = var.database_projects_dev_password_version
  depends_on = [
    google_secret_manager_secret.database_dev,
    ephemeral.random_password.database_dev,
  ]
}

resource "google_sql_user" "database_dev" {
  instance    = google_sql_database_instance.database_dev.name
  project     = google_project.database_dev.project_id
  name        = var.database_projects_user
  password_wo = ephemeral.random_password.database_dev.result
  password_wo_version = var.database_projects_dev_password_version
  depends_on  = [
    google_sql_database_instance.database_dev,
    ephemeral.random_password.database_dev,
  ]
}

######## SQL DATABASE ########

resource "google_sql_database" "database_dev" {
  instance = google_sql_database_instance.database_dev.name
  project  = google_project.database_dev.project_id
  name     = "my_test"
  depends_on = [
    google_sql_database_instance.database_dev,
  ]
}
