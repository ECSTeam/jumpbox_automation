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

  boot_disk {
    initialize_params {
      image = "${var.jumpbox-image-url}"
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.subnet-infra.name}"

    access_config {
      # Empty for ephemeral external IP allocation
    }
  }

  metadata = {
    sshKeys                = "${format("%s ubuntu", tls_private_key.jumpbox.public_key_openssh)}"
    blockProjectSshKeys = "TRUE"
  }
}

resource "tls_private_key" "jumpbox" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}
