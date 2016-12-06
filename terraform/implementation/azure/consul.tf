variable "admin_username" {}
variable "atlas_username" {}
variable "atlas_token" {}
variable "consul_server_count" {}
variable "datacenter" {}
variable "node_name" {}
variable "env" {}
variable "admin_password" {}
variable "capacity" {}
variable "custom_data" {}
variable "ip_config_name" { default = "default" }
variable "location" {}
variable "network_profile_name" { default = "default" }
variable "os_disk_caching" { default = "ReadWrite" }
variable "os_disk_image" {}
variable "os_disk_name" { default = "default" }
variable "provision_vm_agent" { default = "" }
variable "rgroup_name" {}
variable "scale_set_inst_size" {}
variable "scale_set_name" {}
variable "scale_set_prefix" {}
variable "scale_set_tier" {}
variable "subnet_id" {}
variable "upgrade_policy_mode" {}
variable "vhd_containers" {}

data "template_file" "custom_data" {
  template = "${file("templates/consul.tpl")}"

  vars {
    atlas_username = "${var.atlas_username}"
    atlas_token = "${var.atlas_token}"
    consul_server_count = "${var.consul_server_count}"
    datacenter = "${var.env}${var.datacenter}"
    node_name = "${var.node_name}"
  }
}

module "consul" {
  rgroup_name = "${var.rgroup_name}"
  location = "${var.location}"
  capacity = "${var.capacity}"
  custom_data = "${data.template_file.custom_data.rendered}"
  admin_username = "${var.admin_username}"
  admin_password = "${var.admin_password}"
  os_disk_image = "${var.os_disk_image}"
  scale_set_inst_size = "${var.scale_set_inst_size}"
  scale_set_name = "${var.scale_set_name}"
  scale_set_prefix = "${var.scale_set_prefix}"
  scale_set_tier = "${var.scale_set_tier}"
  subnet_id = "${var.subnet_id}"
  upgrade_policy_mode = "${var.upgrade_policy_mode}"
  vhd_containers = "${var.vhd_containers}"
}
