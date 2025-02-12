####################################################################################################
# Transfere o código do dataproc para o bucket de codigos
####################################################################################################

resource "google_storage_bucket_object" "dataproc_jw" {
  for_each = fileset("../codigo", "*")

  name = "dataproc/${each.value}"
  bucket = google_storage_bucket.codigos_jw.name
  source = "../codigo/${each.value}"
}
