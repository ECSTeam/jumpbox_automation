# Configure the VMware vSphere Provider
provider "vsphere" {
  user           = "${var.viuser}"
  password       = "${var.vipassword}"
  vsphere_server = "${var.viserver}"

  # if you have a self-signed cert
  allow_unverified_ssl = true
}

# Create a folder
resource "vsphere_folder" "concourse-base" {
  path = "VirtualMachines"
  datacenter = "Lab09-Datacenter01"
}