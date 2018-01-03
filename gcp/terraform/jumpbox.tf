# resource "google_compute_image" "jumpbox-image" {
#   name           = "${var.env_name}-jumpbox-image"
#   create_timeout = 20

#   raw_disk {
#     source = "${var.jumpbox-image-url}"
#   }
# }

resource "google_compute_instance" "jumpbox" {
  name           = "${var.env_name}-jumpbox"
  depends_on   = ["google_compute_subnetwork.subnet-infra-public"]
  machine_type   = "${var.jumpbox-machine-type}"
  zone           = "${element(var.zones, 1)}"

  tags           = ["${var.env_name}-jumpbox", "jumpbox"]

  boot_disk {
    initialize_params {
      image = "${var.jumpbox-image-url}"
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.subnet-infra-public.name}"

    access_config {
      nat_ip = "${google_compute_address.jumpbox.address}"
    }
  }

  metadata = {
    sshKeys                = "${format("%s ubuntu", tls_private_key.jumpbox.public_key_openssh)}"
    blockProjectSshKeys = "TRUE"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${tls_private_key.jumpbox.private_key_pem}"
    host        = "${google_compute_instance.jumpbox.network_interface.0.access_config.0.assigned_nat_ip}"
  }

  provisioner "file" {
    source      = "../../files/prepare-jumpbox.sh"
    destination = "/home/ubuntu/prepare-jumpbox.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/prepare-jumpbox.sh",
      "sudo /home/ubuntu/prepare-jumpbox.sh -u ${var.jumpbox_users}",
    ]
  }
}

resource "tls_private_key" "jumpbox" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}
