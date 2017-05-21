resource "aws_instance" "servers" {
  connection {
    user = "centos"
  }

  count = 3
  instance_type = "${var.instance_type}"
  ami = "${var.image}"
  key_name = "${var.keypair}"

  vpc_security_group_ids = ["${aws_security_group.servers.id}"]
  subnet_id = "${aws_subnet.pub.id}"

  provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo /tmp/bootstrap.sh server us aws-west2 ${self.public_ip}"
    ]
  }
}

resource "null_resource" "servers_provisioning" {
  triggers {
    cluster_instance_ids = "${join(",", aws_instance.servers.*.id)}"
  }

  provisioner "remote-exec" {

    inline = [
      "consul join ${join(" ", aws_instance.servers.*.public_ip)}",
      "consul join -wan ${file("../etape1_initialisation/cluster_ips.txt")}"
    ]
  }
}
