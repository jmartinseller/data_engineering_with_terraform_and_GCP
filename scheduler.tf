####################################################################################################
 #Criando um agendador para rodar o workflow diariamente
 ####################################################################################################
resource "google_cloud_scheduler_job" "daily_trigger" {
  name     = "daily-dataproc-trigger"
  schedule = "0 3 * * *"  # Executa diariamente às 3h UTC 
  time_zone = "America/Sao_Paulo"

  http_target {
    uri = "https://dataproc.googleapis.com/v1/projects/${var.project}/regions/us-east1/workflowTemplates/${google_dataproc_workflow_template.dataproc-jw.name}:instantiate"
    http_method = "POST"

      oauth_token {
      service_account_email = "tfsa-942@aprendizado-450314.iam.gserviceaccount.com"
    }
  }
}