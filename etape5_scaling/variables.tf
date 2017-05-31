variable "dist_user" {
  default = "centos"
}

variable "region" {
  default = "us-west-2"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "image" {
  default = "ami-d2c924b2"
}

variable "az_count" {
  default     = "2"
}

variable "keypair" {
  description = "AWS Keypair"
}

variable "private_key_path" {
  default = "~/.ssh/id_rsa"
}
