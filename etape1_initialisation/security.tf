resource "google_compute_firewall" "nomad-icmp" {
  name    = "nomad-icmp"
  network = "${google_compute_network.nomad.name}"

  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "nomad-ssh" {
  name    = "nomad-ssh"
  network = "${google_compute_network.nomad.name}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
