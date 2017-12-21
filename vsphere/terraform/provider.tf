# Configure the VMware vSphere Provider
provider "vsphere" {
  user           = "${var.viuser}"
  password       = "${var.vipassword}"
  vsphere_server = "${var.viserver}"
  #version        = "~> 0.4"
  version        = "~> 1.1.0"
  # if you have a self-signed cert
  allow_unverified_ssl = true
}

# Create a folder
# resource "vsphere_folder" "concourse-base" {
#   path = "VirtualMachines"
#   datacenter = "Lab06-Datacenter01"
# }
