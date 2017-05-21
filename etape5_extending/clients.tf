resource "aws_instance" "clients" {
  connection {
    user = "centos"
  }

  count = 3
  instance_type = "${var.instance_type}"
  ami = "${var.image}"
  key_name = "${var.keypair}"

  vpc_security_group_ids = ["${aws_security_group.clients.id}"]
  subnet_id = "${aws_subnet.pub.id}"

  provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo /tmp/bootstrap.sh client us aws-west2 ${self.public_ip}",
      "consul join ${join(" ", aws_instance.servers.*.public_ip)}"
    ]
  }
}
