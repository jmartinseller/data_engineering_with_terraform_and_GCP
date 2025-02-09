####################################################################################################
# Datasets
####################################################################################################

resource "google_bigquery_dataset" "stg_dash_audiencia" {
  project = var.data-project
  dataset_id = "teste"
  description = "Dados stg com origem no GA4 de Audiencia"
  labels = local.labels
  access {
    role = "OWNER"
    group_by_email = "GCP-Administrators-${data-project}@g.globo"  # !!!!ATENCAO!!!!! sempre adicionar esse acesso com lifecycle habilitado
  }
  lifecycle {
    ignore_changes = [ access ] 
  }
}