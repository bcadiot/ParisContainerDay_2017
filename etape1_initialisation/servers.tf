resource "google_compute_instance" "servers" {
  count        = 3
  name         = "server-europe-${count.index + 1}"
  machine_type = "${var.instance_type}"
  zone         = "${var.region}"

  disk {
    image = "${var.image}"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  network_interface {
    network = "${google_compute_network.nomad.name}"
    access_config {
      // Auto generate
    }
  }

  provisioner "file" {
    connection {
      user = "${var.dist_user}"
      host = "${self.network_interface.0.access_config.0.assigned_nat_ip}"
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
      host = "${self.network_interface.0.access_config.0.assigned_nat_ip}"
      timeout = "60s"
      private_key = "${file("${var.private_key_path}")}"
      agent = false
    }

    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo /tmp/bootstrap.sh server gce-west1"
    ]
  }
}

resource "null_resource" "servers_provisioning" {
  provisioner "remote-exec" {
    connection {
      user = "${var.dist_user}"
      host = "${element(google_compute_instance.servers.*.network_interface.0.access_config.0.assigned_nat_ip, 0)}"
      timeout = "60s"
      private_key = "${file("${var.private_key_path}")}"
      agent = false
    }

    inline = [
      "consul join ${join(" ", google_compute_instance.servers.*.network_interface.0.access_config.0.assigned_nat_ip)}"
    ]
  }
}
