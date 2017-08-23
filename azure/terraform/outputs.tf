output "jumpbox_public_ip" {
  value = "${azurerm_public_ip.jumpbox-public-ip.ip_address}"
}
