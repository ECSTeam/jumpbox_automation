resource "azurerm_resource_group" "oss_bosh_infra_resource_group" {
  name     = "${var.env_name}"
  location = "${var.location}"
}
