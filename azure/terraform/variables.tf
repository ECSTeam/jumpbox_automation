variable "env_name" {}
variable "subscription_id" {}
variable "tenant_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "location" {}

variable "azure_terraform_vnet_cidr" {}
variable "azure_terraform_subnet_infra_cidr" {}

variable "jumpbox_vm_size" {}
variable "jumpbox_private_ip" {}
variable "jumpbox_users" {}
variable "jumpbox_image_version" {}
variable "vm_admin_username" {}
variable "vm_admin_password" {}
variable "vm_admin_public_key" {}
variable "ssh_private_file" {
    description = "Path to an SSH private key"
}
