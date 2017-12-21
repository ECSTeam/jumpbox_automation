#NOTE:
# Those variables set via environment variables should be set like TF_VAR_variable_name
# When used in the shell use the full name when referenced in terraform use just the variable name

variable "viuser"     {} #Configure these in the setup-env.sh
variable "vipassword" {} #Configure these in the setup-env.sh
variable "viserver"   {} #Configure these in the setup-env.sh
variable "vidomain"   {} #Configure these in the setup-env.sh

# SSH User Credentials
variable "ssh_user"     {} #This needs to be set as environment variable so it is available to both the shell and terraform. Configure these in the setup-env.sh
variable "ssh_password" {} #This needs to be set as environment variable so it is available to both the shell and terraform. Configure these in the setup-env.sh

variable vm-name            {}
variable vm-cpu             {}
variable vm-memory          {}
variable vm-datacenter      {}
variable vm-network-label   {}
variable vm-template        {}
variable vm-folder          {}
variable vm-data-type       { default = "thin" }
variable vm-datastore       {}
variable vm-default-user    { default = "ubuntu" }
variable vm-prepare-file    { default = "../../prepare-jumpbox.sh" }
variable vm-user-list       {}
variable vm-cores           {}
variable vm-pool            {}
variable vm-ipv4-addr       {}
variable vm-ipv4-netmask    {}
variable vm-ipv4-gateway    {}
variable ssh_key_path       {} #This needs to be set as environment variable so it is available to both the shell and terraform. Configure these in the setup-env.sh
variable vm_client_cert     {} #This needs to be set as environment variable so it is available to both the shell and terraform. Configure these in the setup-env.sh
variable vm_svr_cert        {} #This needs to be set as environment variable so it is available to both the shell and terraform. Configure these in the setup-env.sh
