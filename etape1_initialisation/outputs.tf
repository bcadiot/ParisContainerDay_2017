output "servers_ips" {
  value = ["${google_compute_instance.servers.*.network_interface.0.access_config.0.assigned_nat_ip}"]
}

output "clients_ips" {
  value = ["${google_compute_instance.clients.*.network_interface.0.access_config.0.assigned_nat_ip}"]
}
