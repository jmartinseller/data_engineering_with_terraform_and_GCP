terraform {
    backend "gcs" { 
      bucket  = "tf-state-gh-cicdproject"
      prefix  = "prod"
    }
}

provider "google" {
  project = var.project
  region = var.region
}
