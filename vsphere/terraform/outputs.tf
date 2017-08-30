output "jumpbox_public_ip" {
  value = "${vsphere_virtual_machine.jumpbox.network_interface.0.ipv4_address}"
}
