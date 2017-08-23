/*
  Security Group Definitions
*/

/*
  Jumpbox Security Group
*/
resource "aws_security_group" "jumpboxSG" {
    name = "${var.prefix}-jumpbox_sg"
    description = "Allow incoming connections for the Jumpbox."
    vpc_id = "${var.aws_vpc}"
    tags {
        Name = "${var.prefix}-Jumpbox Security Group"
    }
}

resource "aws_security_group_rule" "allow_jumpboxsg_ssh" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.jumpboxSG.id}"
}

resource "aws_security_group_rule" "allow_jumpboxsg_egress_default" {
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.jumpboxSG.id}"
}
