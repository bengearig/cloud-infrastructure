terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~>6.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~>6.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.25.0"
    }
  }
}

provider "google" {
  user_project_override = true
}

provider "google-beta" {
  user_project_override = true
}

provider "postgresql" {
  alias           = "laf_dev"
  host            = google_sql_database_instance.database_dev.ip_address.0.ip_address
  port            = 5432
  database        = var.lost_and_found_projects_database_name
  username        = var.database_projects_user
  password        = data.google_secret_manager_secret_version.database_dev.secret_data
  connect_timeout = 15
  superuser       = false
}
