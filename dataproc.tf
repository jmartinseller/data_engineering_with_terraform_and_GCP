####################################################################################################
# Transfere o código do dataproc para o bucket de codigos
####################################################################################################

resource "google_storage_bucket_object" "dataproc_jw" {
  for_each = fileset("${path.module}/codigo", "*")
  name = "${each.value}"
  bucket = google_storage_bucket.codigos_jw.name
  source = "${path.module}/codigo/${each.value}"
}
