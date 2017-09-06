resource "azurerm_network_security_group" "bosh_security_group" {
  name                = "bosh-security-group"
  depends_on          = ["azurerm_resource_group.oss_bosh_infra_resource_group"]
  location            = "${var.location}"
  resource_group_name = "${var.env_name}"

  security_rule {
    name                       = "internal-anything"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "0-65535"
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
    source_address_prefix      = "${var.jumpbox_private_ip}/32"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "director_agent"
    priority                   = 201
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 6868
    source_address_prefix      = "${var.jumpbox_private_ip}/32"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "director_endpoint"
    priority                   = 202
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 25555
    source_address_prefix      = "${var.jumpbox_private_ip}/32"
    destination_address_prefix = "*"
  }
}
