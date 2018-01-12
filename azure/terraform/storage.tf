resource "azurerm_storage_account" "bosh_storage_account" {
  name                = "${var.env_name}boshinfrastorage"
  resource_group_name = "${azurerm_resource_group.oss_bosh_infra_resource_group.name}"
  location            = "${var.location}"
  account_type        = "Standard_LRS"
}

resource "azurerm_storage_container" "bosh_storage_container" {
  name                  = "${var.env_name}bosh"
  depends_on            = ["azurerm_storage_account.bosh_storage_account"]
  resource_group_name   = "${azurerm_resource_group.oss_bosh_infra_resource_group.name}"
  storage_account_name  = "${azurerm_storage_account.bosh_storage_account.name}"
  container_access_type = "private"
}

resource "azurerm_storage_container" "stemcell_storage_container" {
  name                  = "${var.env_name}stemcell"
  depends_on            = ["azurerm_storage_account.bosh_storage_account"]
  resource_group_name   = "${azurerm_resource_group.oss_bosh_infra_resource_group.name}"
  storage_account_name  = "${azurerm_storage_account.bosh_storage_account.name}"
  container_access_type = "blob"
}

resource "azurerm_storage_table" "stemcells_storage_table" {
  name                 = "${var.env_name}stemcells"
  resource_group_name  = "${azurerm_resource_group.oss_bosh_infra_resource_group.name}"
  storage_account_name = "${azurerm_storage_account.bosh_storage_account.name}"
}
