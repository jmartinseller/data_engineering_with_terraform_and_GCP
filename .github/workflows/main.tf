terraform {
    backend "gcs" { 
      bucket  = "terraform-state-jb-cicdproject"
      prefix  = "prod"
    }
}

provider "google" {
  project = var.project
  region = var.region
}
