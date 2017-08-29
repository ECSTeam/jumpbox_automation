/*
  For Region
*/
resource "aws_vpc" "BoshInfraVpc" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    tags {
        Name = "${var.prefix}_terraform_bosh_infra_vpc"
    }
}
resource "aws_internet_gateway" "internetGw" {
    vpc_id = "${aws_vpc.BoshInfraVpc.id}"
    tags {
        Name = "${var.prefix}-internet-gateway"
    }
}

# NAT instance setup
# Security Group for NAT
resource "aws_security_group" "nat_instance_sg" {
    name = "${var.prefix}_nat_instance_sg"
    description = "${var.prefix} NAT Instance Security Group"
    vpc_id = "${aws_vpc.BoshInfraVpc.id}"
    tags {
        Name = "${var.prefix}-NAT intance security group"
    }
    ingress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["${var.vpc_cidr}"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
}
# Create NAT instance
resource "aws_instance" "nat_az1" {
    ami = "${var.nat_ami}"
    availability_zone = "${var.az1}"
    instance_type = "${var.nat_instance_type}"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.nat_instance_sg.id}"]
    subnet_id = "${aws_subnet.BoshInfraVpcPublicSubnet_az1.id}"
    associate_public_ip_address = true
    source_dest_check = false
    private_ip = "${var.nat_ip}"

    tags {
        Name = "${var.prefix}-Nat Instance az1"
    }
}
