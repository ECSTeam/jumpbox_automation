
resource "vsphere_virtual_machine" "jumpbox" {
  name = "jumpbox01"
  vcpu = 1
  memory = 1024
  datacenter = "Lab06-Datacenter01"
  linked_clone = "true"

  network_interface {
    label = "Lab06-NetA"
  }

  disk {
    template = "${var.vmtemp}"
    type = "thin"
    datastore = "${var.vmdatastore}"
  }

  connection {
    type = "ssh"
    user = "${var.vm-connection-user}"
    private_key = "${file("${var.vm-connection-identity}")}"
  }

  provisioner "file" {
    source = "${var.vm-prepare-source-file}"
    destination = "/tmp/prepare-jumpbox.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/prepare-jumpbox.sh",
      "sudo /tmp/prepare-jumpbox.sh -u mminges,swall,ecoles",
      "exit"
    ]
  }
}
