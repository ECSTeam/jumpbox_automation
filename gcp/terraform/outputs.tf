output "jumpbox_public_ip" {
  value = "${google_compute_instance.jumpbox.network_interface.0.access_config.0.assigned_nat_ip}"
}

output "project" {
  value = "${var.project}"
}

output "region" {
  value = "${var.region}"
}

output "azs" {
  value = "${var.zones}"
}

output "network_name" {
  value = "${google_compute_network.infra-virt-net.name}"
}

output "ssh_private_key" {
    value = "${tls_private_key.jumpbox.private_key_pem}"
}

output "ssh_public_key" {
    value = "${tls_private_key.jumpbox.public_key_pem}"
}
