# Create Jumpbox

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

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file(var.ssh_private_file)}"
    host        = "${aws_instance.jumpbox.public_ip}"
  }

  provisioner "file" {
    source      = "../../files/prepare-jumpbox.sh"
    destination = "/home/ubuntu/prepare-jumpbox.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/prepare-jumpbox.sh",
      "sudo /home/ubuntu/prepare-jumpbox.sh -u ${var.jumpbox_users}",
    ]
  }
}
