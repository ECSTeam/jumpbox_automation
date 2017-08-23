resource "azurerm_public_ip" "jumpbox-public-ip" {
  name                         = "jumpbox-public-ip"
  location                     = "${var.location}"
  depends_on                   = ["azurerm_resource_group.oss_bosh_infra_resource_group"]
  resource_group_name          = "${var.env_name}"
  public_ip_address_allocation = "static"
}
