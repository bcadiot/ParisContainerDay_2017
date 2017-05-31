resource "openstack_compute_instance_v2" "servers" {
  count           = 3
  region          = "GRA3"
  name            = "server-ovh-france-${count.index + 1}"
  image_name      = "CentOS 7"
  flavor_name     = "s1-2"
  key_pair        = "Bastien-MBP"
  security_groups = ["default"]

  network {
    name = "Ext-Net"
  }

  provisioner "file" {
    connection {
      user = "${var.dist_user}"
      host = "${self.access_ip_v4}"
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
      host = "${self.access_ip_v4}"
      timeout = "60s"
      private_key = "${file("${var.private_key_path}")}"
      agent = false
    }

    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo /tmp/bootstrap.sh server europe france"
    ]
  }
}

resource "null_resource" "servers_join" {
  triggers {
    cluster_instance_ids = "${join(",", openstack_compute_instance_v2.servers.*.id)}"
  }

  provisioner "remote-exec" {
    connection {
      user = "${var.dist_user}"
      host = "${element(openstack_compute_instance_v2.servers.*.access_ip_v4, 0)}"
      timeout = "60s"
      private_key = "${file("${var.private_key_path}")}"
      agent = false
    }

    inline = [
      "consul join ${join(" ", openstack_compute_instance_v2.servers.*.access_ip_v4)}",
      "consul join -wan ${file("../etape1_initialisation/cluster_ips.txt")}"
    ]
  }
}
