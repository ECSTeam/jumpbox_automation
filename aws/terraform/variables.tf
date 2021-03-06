variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "env_name" {}
variable "aws_region" {}
variable "az1" {}
variable "vpc_cidr" {}
variable "public_subnet_cidr" {}
variable "private_subnet_cidr" {}
variable "nat_ip" {}
variable "jumpbox_ami" {}
variable "jumpbox_private_ip" {}
variable "jumpbox_users" {}
variable "public_key" {}
variable "ssh_private_file" {
    description = "Path to an SSH private key"
}
variable "jumpbox_instance_type" {
    description = "Instance Type for Jumpbox VM"
    default = "t2.micro"
}
variable "nat_ami" {
    description = "Amazon Machine Image for Nat VM"
    type = "map"
    default = {
      us-east-1 = "ami-303b1458"
      us-west-2 = "ami-69ae8259"
    }
}
variable "nat_instance_type" {
    description = "Instance Type for Nat VM"
    default = "t2.medium"
}
