resource "google_compute_network" "nomad" {
  name                    = "nomad"
  auto_create_subnetworks = "true"
}
