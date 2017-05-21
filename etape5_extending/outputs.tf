output "servers_ips" {
  value = ["${aws_instance.servers.*.public_ip}"]
}

output "clients_ips" {
  value = ["${aws_instance.clients.*.public_ip}"]
}
