resource "aws_instance" "servers" {
  count = 3
  instance_type = "${var.instance_type}"
  ami = "${var.image}"
  key_name = "${var.keypair}"

  vpc_security_group_ids = ["${aws_security_group.servers.id}"]
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
      "sudo /tmp/bootstrap.sh server us aws-west2 ${self.public_ip}"
    ]
  }
}

resource "null_resource" "servers_provisioning" {
  triggers {
    cluster_instance_ids = "${join(",", aws_instance.servers.*.id)}"
  }

  provisioner "remote-exec" {
    connection {
      user = "${var.dist_user}"
      host = "${element(aws_instance.servers.*.public_ip, 0)}"
      timeout = "60s"
      private_key = "${file("${var.private_key_path}")}"
      agent = false
    }

    inline = [
      "consul join ${join(" ", aws_instance.servers.*.public_ip)}",
      "consul join -wan ${file("../etape1_initialisation/cluster_ips.txt")}"
    ]
  }
}
