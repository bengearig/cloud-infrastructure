variable "organization_id" {
  type    = string
  default = "552152162315"
}

variable "billing_account_id" {
  type    = string
  default = "010B08-FEAD5B-BFED85"
}

variable "billing_account_id_temp" {
  type    = string
  default = "015F57-6F7863-606C85"
}

variable "primary_region" {
  type = string
  default = "us-central1"
}

variable "github_org" {
  type = string
  default = "bengearig"
}

variable "github_repo_names" {
  type = list(string)
  default = [
    "cloud-infrastructure"
  ]
}

variable "bootstrap_key_version" {
  type = string
  default = 20260206
}

variable "networking_projects_prefix" {
  type = string
  default = "networking"
}

variable "networking_projects_primary_region" {
  type = string
  default = "us-central1"
}

variable "database_projects_prefix" {
  type = string
  default = "database"
}

variable "database_projects_user" {
  type = string
  default = "admin"
}

variable "database_projects_primary_region" {
  type = string
  default = "us-central1"
}

variable "database_projects_dev_password_version" {
  type = string
  default = 20260202
}

variable "website_projects_prefix" {
  type = string
  default = "website"
}

variable "lost_and_found_projects_prefix" {
  type = string
  default = "lost-and-found"
}
