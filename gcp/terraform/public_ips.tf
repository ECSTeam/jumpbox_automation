// Static IP address for JumpBox
resource "google_compute_address" "jumpbox" {
  name = "${var.env_name}-jumpbox"
}
