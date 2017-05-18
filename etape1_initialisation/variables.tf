variable "region" {
  default = "europe-west1-d" // We're going to need it in several places in this config
}

variable "instance_type" {
  default = "f1-micro"
}

variable "image" {
  default = "centos-7-v20170426"
}
