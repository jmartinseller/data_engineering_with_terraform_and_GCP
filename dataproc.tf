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

resource "google_dataproc_workflow_template" "dataproc-jw" {
  name     = "dataproc-daily-execution"
  location = "us-east1-b"
  
  placement {
    managed_cluster {
      cluster_name = "dataproc-cluster-jw"
      config {
        staging_bucket = google_storage_bucket.tmp_dataproc_jw.name
        temp_bucket    = google_storage_bucket.tmp_dataproc_jw.name

        software_config {
          image_version = "2.2-debian11"
          properties = {
            "spark:spark.jars.packages" = "com.google.cloud.spark:spark-bigquery-with-dependencies_2.12:0.34.0"
          }
        }

        gce_cluster_config {
          zone             = var.region
          internal_ip_only = true
          service_account_scopes = [
            "https://www.googleapis.com/auth/cloud-platform"
          ]
          subnetwork = "default"
        }

        master_config {
          num_instances = 1
          machine_type  = "n1-standard-2" # Máquina pequena p/ economizar
          disk_config {
            boot_disk_type    = "pd-standard"
            boot_disk_size_gb = 30
          }
        }
      }
    }
  }

  # Job para rodar script PySpark
  jobs {
    step_id = "job_step_1"
    pyspark_job {
      main_python_file_uri = "gs://${google_storage_bucket.codigos_jw.name}/tb_leads_sales.py"
    }
  }

  jobs {
    step_id = "job_step_2"
    prerequisite_step_ids = ["job_step_1"]  # Job 2 depende de Job 1
    pyspark_job {
      main_python_file_uri = "gs://${google_storage_bucket.codigos_jw.name}/tb_public_test_crm_email.py"
    }
  }

  jobs {
    step_id = "job_step_3"
    prerequisite_step_ids = ["job_step_2"]  # Job 3 depende de Job 2
    pyspark_job {
      main_python_file_uri = "gs://${google_storage_bucket.codigos_jw.name}/tb_public_test_crm_sms.py"
    }
  }

  jobs {
    step_id = "job_step_4"
    prerequisite_step_ids = ["job_step_3"]  # Job 4 depende de Job 3
    pyspark_job {
      main_python_file_uri = "gs://${google_storage_bucket.codigos_jw.name}/tb_tv_radio_influencers.py"
    }
  }
}

