provider "google" {
  credentials = "${file("${var.credentials_file}")}" 
  project     = "${var.project}"
  region      = "${var.region}"
  version     = "~> 1.1"
}

provider "template" {
  version = "~> 1.0"
}

provider "tls" {
  version = "~> 1.0"
}
