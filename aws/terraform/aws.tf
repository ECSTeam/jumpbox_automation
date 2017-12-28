provider "aws" {
    assume_role {
      role_arn = "${var.aws_role_arn}"
    }
    region     = "${var.aws_region}"
    version    = "~> 1.1"
}

provider "template" {
    version = "~> 1.0"
}
