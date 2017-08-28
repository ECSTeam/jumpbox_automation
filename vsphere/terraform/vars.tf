variable "viuser" {}
variable "vipassword" {}
variable "viserver" {}

// default VM name in vSphere and its hostname
variable "vmname" {
  default = "test-vm"
}

// default datastore to deploy vmdk
variable "vmdatastore" {
  default = "nfs-lab09-vol1"
}

// default VM Template
variable "vmtemp" {}
