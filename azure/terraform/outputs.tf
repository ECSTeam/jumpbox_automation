output "env_name" {
  value = "${var.env_name}"
}
output "jumpbox_public_ip" {
  value = "${azurerm_public_ip.jumpbox-public-ip.ip_address}"
}
output "internal_cidr" {
  value = "${azurerm_subnet.oss_bosh_infra_subnet.address_prefix}"
}
output "vnet_name" {
  value = "${azurerm_virtual_network.oss_bosh_infra_virtual_network.name}"
}
output "subnet_name" {
  value = "${azurerm_subnet.oss_bosh_infra_subnet.name}"
}
output "resource_group_name" {
  value = "${azurerm_resource_group.oss_bosh_infra_resource_group.name}"
}
output "storage_account_name" {
  value = "${azurerm_storage_account.bosh_storage_account.name}"
}
output "security_group_name" {
  value = "${azurerm_network_security_group.jumpbox_security_group.name}"
}
output "internal_gw" {
  value = "${cidrhost(azurerm_subnet.oss_bosh_infra_subnet.address_prefix, 1)}"
}
