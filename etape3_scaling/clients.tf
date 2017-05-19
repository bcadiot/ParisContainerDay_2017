resource "openstack_compute_instance_v2" "data_node" {
  region          = "GRA3"
  name            = "data_node"
  image_name      = "CentOS 7"
  flavor_name     = "s1-2"
  key_pair        = "Bastien-MBP"
  security_groups = ["default"]

  network {
    name = "Ext-Net"
  }
}
