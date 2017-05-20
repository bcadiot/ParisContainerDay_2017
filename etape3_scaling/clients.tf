resource "openstack_compute_instance_v2" "data_node" {
  count           = 0
  region          = "GRA3"
  name            = "client-ovh-france-${count.index + 1}"
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
      "sudo /tmp/bootstrap.sh client europe france",
      "consul join ${join(" ", openstack_compute_instance_v2.servers.*.access_ip_v4)}"
    ]
  }
}
