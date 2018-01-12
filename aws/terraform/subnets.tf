/*
  For First availability zone
*/

# Create Public Subnet
resource "aws_subnet" "BoshInfraVpcPublicSubnet_az1" {
    vpc_id = "${aws_vpc.BoshInfraVpc.id}"

    cidr_block = "${var.public_subnet_cidr}"
    availability_zone = "${var.az1}"

    tags {
        Name = "${var.env_name}BoshInfraVpc Public Subnet AZ1"
    }
}

# Private network  - For bosh director and it's deployments
resource "aws_subnet" "BoshInfraVpcPrivateSubnet_az1" {
    vpc_id = "${aws_vpc.BoshInfraVpc.id}"

    cidr_block = "${var.private_subnet_cidr}"
    availability_zone = "${var.az1}"

    tags {
        Name = "${var.env_name}BoshInfraVpc Private Subnet"
    }
}
