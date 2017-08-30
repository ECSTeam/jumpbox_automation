# subnet associations for public subnet
resource "aws_route_table_association" "a_az1" {
    subnet_id = "${aws_subnet.BoshInfraVpcPublicSubnet_az1.id}"
    route_table_id = "${aws_route_table.PublicSubnetRouteTable.id}"
}

# subnet associations for infrastructure subnet
resource "aws_route_table_association" "i_az1" {
    subnet_id = "${aws_subnet.BoshInfraVpcPrivateSubnet_az1.id}"
    route_table_id = "${aws_route_table.PrivateSubnetRouteTable_az1.id}"
}
