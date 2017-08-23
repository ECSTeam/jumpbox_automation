variable "aws_vpc" {}
variable "aws_public_subnet" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_key_name" {}
variable "prefix" {}
variable "aws_region" {}
variable "jumpbox_az" {}
variable "jumpbox_ami" {}

variable "jumpbox_instance_type" {
    description = "Instance Type for Jumpbox"
    default = "t2.micro"
}

variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "10.0.0.0/16"
}

# public subnet
variable "public_subnet_cidr" {
    description = "CIDR for the Public Subnet"
    default = "10.0.0.0/24"
}

variable "jumpbox_private_ip" {
    default = "10.0.0.5"
}
