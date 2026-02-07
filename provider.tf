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