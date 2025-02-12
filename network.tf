resource "google_compute_network" "vpc_rede_jw" {
  name                    = "vpc-rede-jw"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet_jw" {
  name          = "subnet-dataproc-jw"
  network       = google_compute_network.vpc_rede_jw.self_link
  ip_cidr_range = "10.10.0.0/24"
  region        = var.region
}