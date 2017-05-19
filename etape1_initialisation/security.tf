resource "google_compute_firewall" "icmp" {
  name    = "icmp"
  network = "${google_compute_network.nomad.name}"

  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "ssh" {
  name    = "ssh"
  network = "${google_compute_network.nomad.name}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "consul-servers" {
  name    = "consul-servers"
  network = "${google_compute_network.nomad.name}"

  allow {
    protocol = "tcp"
    ports    = ["8300-8302", "8500"]
  }

  allow {
    protocol = "udp"
    ports    = ["8301-8302"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["consul-servers"]
}

resource "google_compute_firewall" "nomad-servers" {
  name    = "nomad-servers"
  network = "${google_compute_network.nomad.name}"

  allow {
    protocol = "tcp"
    ports    = ["4646-4648"]
  }

  allow {
    protocol = "udp"
    ports    = ["4648"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["nomad-servers"]
}
