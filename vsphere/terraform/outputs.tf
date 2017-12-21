output "jumpbox_public_ip" {
  value = "${vsphere_virtual_machine.jumpbox.default_ip_address}"
}
