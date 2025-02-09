terraform {
    backend "gcs" { 
      bucket  = var.bk_backend
      prefix  = "prod"
    }
}

provider "google" {
  project = var.project
  region = var.region
}
