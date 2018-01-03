resource "google_compute_network" "infra-virt-net" {
  name = "${var.env_name}-virt-net"
  auto_create_subnetworks = false
}

// Jumpbox and Ops Man
resource "google_compute_subnetwork" "subnet-infra-private" {
  name          = "${var.env_name}-subnet-infra-private-${var.region}"
  ip_cidr_range = "${var.private_infra_cidr}"
  network       = "${google_compute_network.infra-virt-net.self_link}"
  region	= "${var.region}"
}

// NAT
resource "google_compute_subnetwork" "subnet-infra-public" {
  name          = "${var.env_name}-subnet-infra-public-${var.region}"
  ip_cidr_range = "${var.public_infra_cidr}"
  network       = "${google_compute_network.infra-virt-net.self_link}"
  region	= "${var.region}"
}
