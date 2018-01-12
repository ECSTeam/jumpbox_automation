# Routing Tables for all subnets

resource "aws_route_table" "PublicSubnetRouteTable" {
    vpc_id = "${aws_vpc.BoshInfraVpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.internetGw.id}"
    }

    tags {
        Name = "${var.env_name}Public Subnet Route Table"
    }
}

# AZ1 Routing table
resource "aws_route_table" "PrivateSubnetRouteTable_az1" {
    vpc_id = "${aws_vpc.BoshInfraVpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        instance_id = "${aws_instance.nat_az1.id}"
    }

    tags {
        Name = "${var.env_name}Private Subnet Route Table AZ1"
    }
}
