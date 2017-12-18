data "vsphere_datacenter" "dc" {
  name = "${var.vm-datacenter}"
}

data "vsphere_datastore" "ds" {
  name          = "${var.vm-datastore}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool" {
  name          = "${var.vm-pool}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name          = "${var.vm-network-label}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template" {
  name          = "${var.vm-template}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
