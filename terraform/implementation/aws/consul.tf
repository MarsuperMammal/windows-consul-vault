variable "acct_remote_state" {}
variable "consul_asg_max" { default = 5 }
variable "consul_asg_min" { default = 3 }
variable "consul_asg_desired" { default = 3 }
variable "consul_app_name" { default = "consul" }
variable "consul_ami_id" {}
variable "consul_instance_type" {}
variable "consul_root_volume_size" {}
variable "consul_server_join_tag_key" { default = "ConsulCluster" }
variable "consul_sgs" { type = "list" }
variable "datacenter" {}
variable "key_name" {}
variable "network_remote_state" {}
variable "region" {}
variable "remote_state_bucket" {}

data "terraform_remote_state" "acct" {
  backend = "s3"
  config {
    bucket = "${var.remote_state_bucket}"
    key = "${var.acct_remote_state}"
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config {
    bucket = "${var.remote_state_bucket}"
    key = "${var.network_remote_state}"
  }
}

data "template_file" "consul-userdata" {
  template = "${file("templates/consul-userdata.tpl")}"
  vars {
    aws_region = "${var.region}"
    datacenter = "${var.datacenter}"
    consul_server_join_tag_key = "${var.consul_server_join_tag_key}"
    consul_server_join_tag_value = "${var.consul_server_join_tag_value}"
  }
}

module "consul" {
  source = "../modules/compute"
  priv_subnets = "${data.terraform_remote_state.network.priv_subnets}"
  asg_max = "${var.consul_asg_max}"
  asg_min = "${var.consul_asg_min}"
  asg_desired = "${var.consul_asg_desired}"
  key_name = "${data.terraform_remote_state.network.key_pair}"
  app_name = "${var.consul_app_name}"
  ami_id = "${var.consul_ami_id}"
  instance_type = "${var.consul_instance_type}"
  asg_sgs = "${var.consul_sgs}"
  userdata = "${data.template_file.consul-userdata.rendered}"
  root_volume_size = "${var.consul_root_volume_size}"
  iam_instance_profile = "${data.terraform_remote_state.acct.describe_tags_self.id}"
}
