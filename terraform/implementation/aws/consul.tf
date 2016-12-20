variable "acct_remote_state" {}
variable "consul_asg_max" { default = 5 }
variable "consul_asg_min" { default = 3 }
variable "consul_asg_desired" { default = 3 }
variable "consul_app_name" { default = "consul" }
variable "consul_ami_id" {}
variable "consul_instance_type" {}
variable "consul_root_volume_size" {}
variable "consul_server_join_tag_key" { default = "ConsulCluster" }
variable "datacenter" {}
variable "dns_server" {}
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
    consul_server_join_tag_value = "${var.region}-${var.datacenter}"
    ssl_cert = "${file("../../../setup/vault.crt")}"
    consul_server_count = "${var.consul_asg_desired}"
    dns_server = "${var.dns_server}"
  }
}

data "template_file" "vault-userdata" {
  template = "${file("templates/vault-userdata.tpl")}"
  vars {
    aws_region = "${var.region}"
    datacenter = "${var.datacenter}"
    consul_server_join_tag_key = "${var.consul_server_join_tag_key}"
    consul_server_join_tag_value = "${var.region}-${var.datacenter}"
    ssl_cert = "${file("../../../setup/vault.crt")}"
    ssl_key = "${file("../../../setup/vault.key")}"
    dns_server = "${var.dns_server}"
  }
}

module "consul" {
  source = "../../modules/compute"
  priv_subnets = "${data.terraform_remote_state.network.pub_subnets}"
  consul_server_join_tag_value = "${var.region}-${var.datacenter}"
  consul_server_join_tag_key = "${var.consul_server_join_tag_key}"
  asg_max = "${var.consul_asg_max}"
  asg_min = "${var.consul_asg_min}"
  asg_desired = "${var.consul_asg_desired}"
  key_name = "${var.key_name}"
  app_name = "${var.consul_app_name}"
  ami_id = "${var.consul_ami_id}"
  instance_type = "${var.consul_instance_type}"
  asg_sgs = ["${aws_security_group.baseline.id}"]
  datacenter = "${var.datacenter}"
  userdata = "${data.template_file.consul-userdata.rendered}"
  root_volume_size = "${var.consul_root_volume_size}"
  iam_instance_profile = "${data.terraform_remote_state.acct.describe_tags_self}"
}

module "vault" {
  source = "../../modules/compute"
  priv_subnets = "${data.terraform_remote_state.network.pub_subnets}"
  consul_server_join_tag_value = "${var.region}-${var.datacenter}"
  consul_server_join_tag_key = "${var.consul_server_join_tag_key}"
  asg_max = "${var.vault_asg_max}"
  asg_min = "${var.vault_asg_min}"
  asg_desired = "${var.vault_asg_desired}"
  key_name = "${var.key_name}"
  app_name = "${var.vault_app_name}"
  ami_id = "${var.vault_ami_id}"
  instance_type = "${var.vault_instance_type}"
  asg_sgs = ["${aws_security_group.baseline.id}"]
  datacenter = "${var.datacenter}"
  userdata = "${data.template_file.vault-userdata.rendered}"
  root_volume_size = "${var.vault_root_volume_size}"
  iam_instance_profile = "${data.terraform_remote_state.acct.describe_tags_self}"
}

resource "aws_security_group" "baseline" {
  name = "baseline"
  vpc_id = "${data.terraform_remote_state.network.vpc_id}"
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
