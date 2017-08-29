
resource "vsphere_virtual_machine" "ubuntuguest" {
  name = "ubuntuguest"
  vcpu = 1
  memory = 1024
  datacenter = "Lab09-Datacenter01"

  network_interface {
    label = "Lab09-NetA"
  }

  disk {
    template = "${var.vmtemp}"
    type = "thin"
    datastore = "${var.vmdatastore}"
  }
}
