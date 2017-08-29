output "prefix" {
    value = "${var.prefix}"
}
output "region" {
    value = "${var.aws_region}"
}
output "jumpbox_az" {
    value = "${var.az1}"
}
output "vpc_id" {
    value = "${aws_vpc.BoshInfraVpc.id}"
}
output "public_subnet_id" {
    value = "${aws_subnet.BoshInfraVpcPublicSubnet_az1.id}"
}
output "public_subnet_cidr" {
    value = "${var.public_subnet_cidr}"
}
output "private_subnet_id" {
    value = "${aws_subnet.BoshInfraVpcPrivateSubnet_az1.id}"
}
output "private_subnet_cidr" {
    value = "${var.private_subnet_cidr}"
}
output "jumpbox_security_group" {
    value = "${aws_security_group.jumpboxSG.id}"
}
output "jumpbox_public_ip" {
    value = "${aws_instance.jumpbox.public_ip}"
}
