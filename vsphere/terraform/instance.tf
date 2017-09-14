
resource "vsphere_virtual_machine" "jumpbox" {
  name = "${var.vm-name}"
  vcpu = "${var.vm-cpu}"
  memory = "${var.vm-memory}"
  datacenter = "${var.vm-datacenter}"
  linked_clone = "true"

  network_interface {
    label = "${var.vm-network-label}"
  }

  disk {
    template = "${var.vm-template}"
    type = "${var.vm-data-type}"
    datastore = "${var.vm-datastore}"
  }

  # Create SSH Key Direcotry
  provisioner "local-exec" {
    command = "[ -d ./ssh-key ] && echo 'Key directory exists' || mkdir ssh-key"
  }

  # Create SSH Key
  provisioner "local-exec" {
    command = "[ -f ./ssh-key/jumpbox_rsa ] && echo 'Key file exists' || ssh-keygen -t rsa -C ${var.vm-default-user} -f ./ssh-key/jumpbox_rsa -q -N ''"
  }

  # Connect to box without SSH (Used to upload key)
  connection {
    type = "ssh"
    user = "${var.ssh-user}"
    password = "${var.ssh-password}"
    # private_key = "${file("${var.ssh-identity}")}"
  }

  # Upload SSH Key 
  provisioner "file" {
    source = "${var.vm-pub-rsa-file}"
    destination = "/home/${var.vm-default-user}/.ssh" # TODO: Figure out why key file cannot be uploaded directly to "/home/ubuntu/.ssh/authorized-keys"
  }

  # Upload Prepare SCript
  provisioner "file" {
    source = "${var.vm-prepare-file}"
    destination = "/tmp/prepare-jumpbox.sh"
  }

  # Setup SSH keys for box
  provisioner "remote-exec" {
    inline = [
      "mv /home/${var.vm-default-user}/.ssh /home/${var.vm-default-user}/authorized-keys",
      "mkdir /home/${var.vm-default-user}/.ssh/",
      "mv /home/${var.vm-default-user}/authorized-keys /home/${var.vm-default-user}/.ssh/"
    ]
  }

  # Setup jumpbox for IaaS
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/prepare-jumpbox.sh",
      "sudo /tmp/prepare-jumpbox.sh -u ${var.vm-user-list}"
    ]
  }
}
