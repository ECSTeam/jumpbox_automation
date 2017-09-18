provider "google" {
  credentials = "${file("${var.credentials-file}")}"
  project     = "${var.project}"
  region      = "${var.region}"
}