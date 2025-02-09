####################################################################################################
# Bucket para armazenar o arquivo parquet leads_sales
####################################################################################################

resource "google_storage_bucket" "leads_sales_files" {
  name = "leads_sales_files"
  uniform_bucket_level_access = true
  labels = local.labels
  location = var.region
}

locals {
  bk_parquet = "${google_storage_bucket.leads_sales_files.name}"
}

####################################################################################################
# Bucket para armazenar os arquivos csv's tv_radio_influencers
####################################################################################################

resource "google_storage_bucket" "tv_radio_influencers_files" {
  name = "tv_radio_influencers_files"
  uniform_bucket_level_access = true
  labels = local.labels
  location = var.region
}

locals {
  bk_csv = "${google_storage_bucket.tv_radio_influencers_files.name}"
}