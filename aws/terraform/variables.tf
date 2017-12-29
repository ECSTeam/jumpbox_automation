variable "aws_role_arn" {}
variable "aws_key_name" {}
variable "prefix" {}
variable "aws_region" {}
variable "az1" {}
variable "vpc_cidr" {}
variable "public_subnet_cidr" {}
variable "private_subnet_cidr" {}
variable "nat_ip" {}
variable "jumpbox_ami" {}
variable "jumpbox_private_ip" {}
variable "jumpbox_users" {}
variable "ssh_private_file" {
    description = "Path to an SSH private key"
    default = "../ssh-key/oss-bosh-infra"
}
variable "jumpbox_instance_type" {
    description = "Instance Type for Jumpbox VM"
    default = "t2.micro"
}
variable "nat_ami" {
    description = "Amazon Machine Image for Nat VM"
    default = "ami-303b1458"
}
variable "nat_instance_type" {
    description = "Instance Type for Nat VM"
    default = "t2.medium"
}
