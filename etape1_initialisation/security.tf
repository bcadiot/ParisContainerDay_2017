resource "google_compute_firewall" "icmp" {
  name    = "icmp"
  network = "${google_compute_network.nomad.name}"

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "ssh" {
  name    = "ssh"
  network = "${google_compute_network.nomad.name}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
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

resource "google_compute_firewall" "consul-clients" {
  name    = "consul-clients"
  network = "${google_compute_network.nomad.name}"

  allow {
    protocol = "tcp"
    ports    = ["8300-8301", "8500"]
  }

  allow {
    protocol = "udp"
    ports    = ["8301"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["consul-clients"]
}

resource "google_compute_firewall" "nomad-clients" {
  name    = "nomad-clients"
  network = "${google_compute_network.nomad.name}"

  allow {
    protocol = "tcp"
    ports    = ["4646-4647"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["nomad-clients"]
}

resource "google_compute_firewall" "nomad-apps" {
  name    = "nomad-apps"
  network = "${google_compute_network.nomad.name}"

  allow {
    protocol = "tcp"
    ports    = ["20000-60000", "80", "443"]
  }

  allow {
    protocol = "udp"
    ports    = ["20000-60000"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["nomad-clients"]
}
