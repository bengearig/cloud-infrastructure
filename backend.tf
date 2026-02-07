terraform {
  backend "gcs" {
    bucket = "bootstrap-wjz4-tfstate"
    prefix = "terraform/state"
  }
}
