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
      version = "1.26.0"
    }
    docker = {
      source = "kreuzwerker/docker"
      version = "~> 3.6.2"
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
  scheme          = "gcppostgres"
  host            = google_sql_database_instance.database_dev.connection_name
  port            = 5432
  database        = var.lost_and_found_projects_database_name
  username        = var.database_projects_user
  password        = data.google_secret_manager_secret_version.database_dev.secret_data
  connect_timeout = 15
  superuser       = false
}

provider "docker" {
  registry_auth {
    address = "${var.primary_region}-docker.pkg.dev"
  }
}
