# Create Jumpbox

data "template_file" "PrepareJumpbox" {
    template = <<-EOF
              #!/bin/bash
              apt-get update
              wget https://s3.amazonaws.com/jumpbox-automation/prepare-jumpbox.sh 
              chmod +x ./prepare-jumpbox.sh
              ./prepare-jumpbox.sh -u mminges,swall
              EOF
}

resource "aws_instance" "jumpbox" {
    ami = "${var.jumpbox_ami}"
    availability_zone = "${var.az1}"
    instance_type = "${var.jumpbox_instance_type}"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.jumpboxSG.id}"]
    subnet_id = "${aws_subnet.BoshInfraVpcPublicSubnet_az1.id}"
    associate_public_ip_address = true 
    private_ip = "${var.jumpbox_private_ip}"
    root_block_device {
        volume_size = 30
    }
    tags {
        Name = "${var.prefix}-BoshInfraJumpbox"
    }
    user_data = "${data.template_file.PrepareJumpbox.rendered}"
}
