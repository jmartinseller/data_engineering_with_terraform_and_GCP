####################################################################################################
# Bucket para conter os códigos das cloudfunctions, dataprocs, etc
####################################################################################################

resource "google_storage_bucket" "codigos" {
  name = "codigos"
  uniform_bucket_level_access = true
  labels = local.labels
  location = var.region
}


####################################################################################################
# Bucket para conter os arquivos temporários do dataproc
####################################################################################################

resource "google_storage_bucket" "tmp-dataproc" {
  name = "tmp-dataproc"
  uniform_bucket_level_access = true
  labels = local.labels
  location = var.region
  lifecycle_rule {
    condition {
      age = 90 # dias
    }
    action {
      type = "Delete"
    }
  }
}