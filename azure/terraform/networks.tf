resource "azurerm_virtual_network" "oss_bosh_infra_virtual_network" {
  name                = "${var.env_name}-virtual-network"
  depends_on          = ["azurerm_resource_group.oss_bosh_infra_resource_group"]
  resource_group_name = "${var.env_name}"
  address_space       = ["${var.azure_terraform_vnet_cidr}"]
  location            = "${var.location}"
}

resource "azurerm_subnet" "oss_bosh_infra_subnet" {
  name                 = "${var.env_name}-subnet"
  resource_group_name  = "${var.env_name}"
  virtual_network_name = "${azurerm_virtual_network.oss_bosh_infra_virtual_network.name}"
  address_prefix       = "${var.azure_terraform_subnet_infra_cidr}"
}
