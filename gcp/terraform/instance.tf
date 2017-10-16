# resource "google_compute_image" "jumpbox-image" {
#   name           = "${var.prefix}-jumpbox-image"
#   create_timeout = 20

#   raw_disk {
#     source = "${var.jumpbox-image-url}"
#   }
# }

resource "google_compute_instance" "jumpbox" {
  name           = "${var.prefix}-jumpbox"
  machine_type   = "${var.jumpbox-machine-type}"
  zone           = "${element(var.zones, 1)}"

  tags           = ["${var.prefix}-jumpbox", "jumpbox"]

  attached_disk {
    image = "${var.jumpbox-image-url}"
    size  = 150
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.subnet-infra.name}"

    access_config {
      # Empty for ephemeral external IP allocation
    }
  }

  metadata = {
    ssh-keys               = "${format("ubuntu:%s", tls_private_key.jumpbox.public_key_openssh)}"
    block-project-ssh-keys = "TRUE"
  }
}

resource "tls_private_key" "jumpbox" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}
