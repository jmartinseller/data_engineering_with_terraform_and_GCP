####################################################################################################
# Transfere o código do dataproc para o bucket de codigos
####################################################################################################

resource "google_storage_bucket_object" "dataproc_jw" {
  for_each = fileset("${path.module}/codigo", "*")
  name = "${each.value}"
  bucket = google_storage_bucket.codigos_jw.name
  source = "${path.module}/codigo/${each.value}"
}


####################################################################################################
# Dataprocs
####################################################################################################

resource "google_dataproc_workflow_template" "dataproc_jw" {
  name     = "dataproc-jw"
  location = var.region

  placement {
    managed_cluster {
      cluster_name = "dataproc-jw-temp"
      config {
        staging_bucket = google_storage_bucket.tmp_dataproc_jw.name
        temp_bucket    = google_storage_bucket.tmp_dataproc_jwc.name

        gce_cluster_config {
          internal_ip_only = true
          subnetwork       = google_compute_subnetwork.subnet_jw.self_link
        }

        master_config {
          num_instances = 1
          machine_type  = "n1-standard-2" # Máquina pequena para economizar
          disk_config {
            boot_disk_type    = "pd-standard"
            boot_disk_size_gb = 30
          }
        }

        # Sem nós workers para reduzir custo (usando autoscaling, se necessário)
      }
    }
  }

  jobs {
    step_id = "tb_leads_sales"
    pyspark_job {
      main_python_file_uri = "gs://codigos_jw/tb_leads_sales.py"
      args = [
        "gs://codigos_jw/dados/input.csv", # Caminho do arquivo a ser processado
        "gs://codigos_jw/dados/output",    # Caminho para salvar resultado
      ]
    }
  }
}
