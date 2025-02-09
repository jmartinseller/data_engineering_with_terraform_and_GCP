####################################################################################################
# Datasets
####################################################################################################

resource "google_bigquery_dataset" "raw_uncover" {
  project = var.project
  dataset_id = "raw_uncover"
  description = "Dataset contendo dados brutos sem nenhuma transformação"
  labels = local.labels
}


####################################################################################################
# Tabelas Externas
####################################################################################################

# resource "google_bigquery_table" "tb_leads_sales" {
#   project = var.project
#   dataset_id = google_bigquery_dataset.raw_uncover.dataset_id
#   table_id  = "tb_leads_sales"
#   schema = file("terraform/schemas/tb_leads_sales.json")

#   labels = local.labels

#  external_data_configuration {
#    autodetect    = true
#    source_format = "PARQUET" #O formato dos arquivos
#    source_uris = [
#      "gs://${var.bk_parquet}/leads_sales.parquet",
#    ]
#  }
# }

# resource "google_bigquery_table" "tb_tv_radio_influencers" {
#   project = var.project
#   dataset_id = google_bigquery_dataset.raw_uncover.dataset_id
#   table_id  = "tb_tv_radio_influencers"
#   schema = file("terraform/schemas/tb_tv_radio_influencers.json")

#   labels = local.labels

#  external_data_configuration {
#    autodetect    = true
#    source_format = "CSV" #O formato dos arquivos

#    csv_options {
#      quote                 = "\""
#      field_delimiter       = ","
#      skip_leading_rows = 1
#    }

#    source_uris = [
#      "gs://${var.bk_csv}/*.csv",
#    ]
#  }
# }
