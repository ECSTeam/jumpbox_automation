variable "viuser" {}
variable "vipassword" {}
variable "viserver" {}

// default VM name in vSphere and its hostname
variable "vmname" {
  default = "test-vm"
}

// default datastore to deploy vmdk
variable "vmdatastore" {
  default = "nfs-lab06-vol1"
}

// default VM Template
variable "vmtemp" {}

variable "vm-prepare-source-file" {
  default = "../../prepare-jumpbox.sh"
}

variable "vm-connection-user" {
  default = "ubuntu"
}

variable "vm-connection-identity" {}