# Allow SSH access to jumpbox from the outside world
resource "google_compute_firewall" "jumpbox-external" {
  name        = "${var.env_name}-jumpbox-external"
  network     = "${google_compute_network.infra-virt-net.name}"
  target_tags = ["${var.env_name}-jumpbox"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
