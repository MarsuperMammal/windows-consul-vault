variable "acct_remote_state" {}
variable "consul_server_join_tag_key" { default = "ConsulCluster" }
variable "datacenter" {}
variable "key_name" {}
variable "network_remote_state" {}
variable "region" {}
variable "remote_state_bucket" {}
variable "vault_asg_max" { default = 2 }
variable "vault_asg_min" { default = 2 }
variable "vault_asg_desired" { default = 2 }
variable "vault_app_name" { default = "vault" }
variable "vault_ami_id" {}
variable "vault_instance_type" {}
variable "vault_root_volume_size" {}
variable "vault_sgs" { type = "list" }

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

data "template_file" "vault-userdata" {
  template = "${file("templates/vault-userdata.tpl")}"
  vars {
    aws_region = "${var.region}"
    datacenter = "${var.datacenter}"
    consul_server_join_tag_key = "${var.consul_server_join_tag_key}"
    consul_server_join_tag_value = "${var.consul_server_join_tag_value}"
  }
}

module "vault" {
  source = "../modules/compute"
  priv_subnets = "${data.terraform_remote_state.network.priv_subnets}"
  asg_max = "${var.vault_asg_max}"
  asg_min = "${var.vault_asg_min}"
  asg_desired = "${var.vault_asg_desired}"
  key_name = "${data.terraform_remote_state.network.key_pair}"
  app_name = "${var.vault_app_name}"
  ami_id = "${var.vault_ami_id}"
  instance_type = "${var.vault_instance_type}"
  asg_sgs = "${var.vault_sgs}"
  userdata = "${data.template_file.vault-userdata.rendered}"
  root_volume_size = "${var.vault_root_volume_size}"
  iam_instance_profile = "${data.terraform_remote_state.acct.describe_tags_self.id}"
}
