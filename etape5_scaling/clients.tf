resource "aws_instance" "clients" {
  count = 3
  instance_type = "${var.instance_type}"
  ami = "${var.image}"
  key_name = "${var.keypair}"

  vpc_security_group_ids = ["${aws_security_group.clients.id}"]
  subnet_id = "${aws_subnet.pub.id}"
  associate_public_ip_address = true

  provisioner "file" {
    connection {
      user = "${var.dist_user}"
      host = "${self.public_ip}"
      timeout = "60s"
      private_key = "${file("${var.private_key_path}")}"
      agent = false
    }

    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    connection {
      user = "${var.dist_user}"
      host = "${self.public_ip}"
      timeout = "60s"
      private_key = "${file("${var.private_key_path}")}"
      agent = false
    }

    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo /tmp/bootstrap.sh client us aws-west2 ${self.public_ip}",
      "consul join ${join(" ", aws_instance.servers.*.public_ip)}"
    ]
  }
}
