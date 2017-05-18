variable "region" {
  default = "europe-west1-d" // We're going to need it in several places in this config
}

provider "google" {
  region = "${var.region}"
}
