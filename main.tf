terraform {
    backend "gcs" { 
      bucket  = var.backend
      prefix  = "prod"
    }
}

provider "google" {
  project = var.project
  region = var.region
}
