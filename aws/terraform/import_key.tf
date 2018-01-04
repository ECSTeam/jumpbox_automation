resource "aws_key_pair" "deployer" {
  key_name   = "${var.env_name}"
  public_key = "${var.public_key}"
}
