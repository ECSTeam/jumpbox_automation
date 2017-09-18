resource "google_compute_network" "pcf-virt-net" {
  name = "${var.prefix}-virt-net"
}

// Jumpbox and Ops Man
resource "google_compute_subnetwork" "subnet-infra" {
  name          = "${var.prefix}-subnet-infra-${var.region}"
  ip_cidr_range = "10.0.0.0/26"
  network       = "${google_compute_network.pcf-virt-net.self_link}"
}