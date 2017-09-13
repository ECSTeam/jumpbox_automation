variable "viuser"     {}
variable "vipassword" {}
variable "viserver"   {}

# SSH User Credentials
variable "ssh-user"     {}
variable "ssh-password" {}
variable "ssh-identity" { default = "" }

variable vm-name          {}
variable vm-cpu           {}
variable vm-memory        {}
variable vm-datacenter    {}
variable vm-network-label {}
variable vm-template      {}
variable vm-data-type     { default = "thin" }
variable vm-datastore     {}
variable vm-default-user  { default = "ubuntu" }
variable vm-rsa-file      {}
variable vm-pub-rsa-file  {}
variable vm-prepare-file  { default = "../../prepare-jumpbox.sh" }
variable vm-user-list     {}