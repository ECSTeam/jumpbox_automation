resource "azurerm_storage_account" "bosh" {
  name                = "${var.env_name}boshinfrastorage"
  resource_group_name = "${azurerm_resource_group.oss_bosh_infra_resource_group.name}"
  location            = "${var.location}"
  account_tier        = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "bosh" {
  name                  = "bosh"
  depends_on            = ["azurerm_storage_account.bosh"]
  resource_group_name   = "${azurerm_resource_group.oss_bosh_infra_resource_group.name}"
  storage_account_name  = "${azurerm_storage_account.bosh.name}"
  container_access_type = "private"
}

resource "azurerm_storage_container" "stemcell" {
  name                  = "stemcell"
  depends_on            = ["azurerm_storage_account.bosh"]
  resource_group_name   = "${azurerm_resource_group.oss_bosh_infra_resource_group.name}"
  storage_account_name  = "${azurerm_storage_account.bosh.name}"
  container_access_type = "blob"
}

resource "azurerm_storage_table" "stemcells" {
  name                 = "stemcells"
  resource_group_name  = "${azurerm_resource_group.oss_bosh_infra_resource_group.name}"
  storage_account_name = "${azurerm_storage_account.bosh.name}"
}
