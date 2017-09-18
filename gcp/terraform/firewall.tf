# Allow SSH access to jumpbox from the outside world
resource "google_compute_firewall" "jumpbox-external" {
  name        = "${var.prefix}-jumpbox-external"
  network     = "${google_compute_network.pcf-virt-net.name}"
  target_tags = ["${var.prefix}-jumpbox"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
