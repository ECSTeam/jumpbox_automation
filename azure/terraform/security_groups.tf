resource "azurerm_network_security_group" "jumpbox_security_group" {
  name                = "jumpbox-security-group"
  depends_on          = ["azurerm_resource_group.oss_bosh_infra_resource_group"]
  location            = "${var.location}"
  resource_group_name = "${var.env_name}"

  security_rule {
    name                       = "internal-anything"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ssh"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 22
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}
