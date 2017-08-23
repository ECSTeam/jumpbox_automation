# Create Jumpbox

data "template_file" "prepare-bastion" {
    template = <<-EOF
              #!/bin/bash
              apt-get update
              wget https://s3.amazonaws.com/mpm-ecs-pcf-aws-er-blobstore/prepare-bastion.sh
              chmod +x ./prepare-bastion.sh
              ./prepare-bastion.sh -u mminges,swall
              EOF
}

resource "aws_instance" "jumpbox" {
    ami = "${var.jumpbox_ami}"
    availability_zone = "${var.jumpbox_az}"
    instance_type = "${var.jumpbox_instance_type}"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.jumpboxSG.id}"]
    subnet_id = "${var.aws_public_subnet}"
    associate_public_ip_address = true 
    private_ip = "${var.jumpbox_private_ip}"
    root_block_device {
        volume_size = 30
    }
    tags {
        Name = "${var.prefix}-Jumpbox"
    }
    user_data = "${data.template_file.prepare-bastion.rendered}"
}
