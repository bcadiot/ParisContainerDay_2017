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
}
