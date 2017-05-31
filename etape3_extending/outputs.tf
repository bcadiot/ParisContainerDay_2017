output "servers_ips" {
  value = ["${openstack_compute_instance_v2.servers.*.access_ip_v4}"]
}

output "clients_ips" {
  value = ["${openstack_compute_instance_v2.data_node.*.access_ip_v4}"]
}
