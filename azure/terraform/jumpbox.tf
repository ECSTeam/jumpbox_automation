resource "azurerm_network_interface" "jumpbox_nic" {
  name                = "${var.env_name}-jumpbox-nic"
  location            = "${var.location}"
  resource_group_name = "${var.env_name}"

  ip_configuration {
    name                          = "${var.env_name}-jumpbox-ip-config"
    subnet_id                     = "${azurerm_subnet.oss_bosh_infra_subnet.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "${var.jumpbox_private_ip}"
    public_ip_address_id          = "${azurerm_public_ip.jumpbox-public-ip.id}"
  }
}

resource "azurerm_virtual_machine" "jumpbox_vm" {
  name                  = "${var.env_name}-jumpbox-vm"
  depends_on            = ["azurerm_network_interface.jumpbox_nic"]
  location              = "${var.location}"
  resource_group_name   = "${var.env_name}"
  network_interface_ids = ["${azurerm_network_interface.jumpbox_nic.id}"]
  vm_size               = "${var.jumpbox_vm_size}"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "14.04.2-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "jumpboxosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.env_name}-jumpbox"
    admin_username = "${var.vm_admin_username}"
    admin_password = "${var.vm_admin_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.vm_admin_username}/.ssh/authorized_keys"
      key_data = "${var.vm_admin_public_key}"
    }
  }
}
