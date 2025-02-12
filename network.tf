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

resource "google_compute_router" "dataproc_router" {
  name    = "dataproc-router"
  network = google_compute_network.vpc_rede_jw.self_link 
  region  = "us-east1"

  bgp {
    asn = 64512 # Número padrão para BGP (Border Gateway Protocol)
  }
}

resource "google_compute_router_nat" "dataproc_nat" {
  name   = "dataproc-nat"
  router = google_compute_router.dataproc_router.name
  region = google_compute_router.dataproc_router.region

  nat_ip_allocate_option = "AUTO_ONLY" 
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}