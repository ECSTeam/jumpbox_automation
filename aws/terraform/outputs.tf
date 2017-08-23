output "prefix" {
    value = "${var.prefix}"
}
output "region" {
    value = "${var.aws_region}"
}
output "jumpbox_az" {
    value = "${var.jumpbox_az}"
}
output "vpc_id" {
    value = "${var.aws_vpc}"
}
output "jumpbox_security_group" {
    value = "${aws_security_group.jumpboxSG.id}"
}
output "jumpbox_public_ip" {
    value = "${aws_instance.jumpbox.public_ip}"
}

# DNS
output "dns" {
    value = "${cidrhost("${var.vpc_cidr}", 2)}"
}

output "public_subnet_cidr" {
    value = "${var.public_subnet_cidr}"
}
output "public_subnet_id" {
    value = "${var.aws_public_subnet}"
}
