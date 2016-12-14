variable "region" {}
variable "priv_subnets" { type = "list" }
variable "asg_max" {}
variable "asg_min" {}
variable "asg_desired" {}
variable "key_name" {}
variable "app_name" {}
variable "ami_id" {}
variable "userdata" {}
variable "instance_type" {}
variable "root_volume_size" {}
variable "asg_sgs" { type = "list" }

resource "aws_launch_configuration" "lc" {
  name_prefix = "${var.app_name}"
  image_id = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  user_data = "${var.userdata}"
  security_groups = ["${var.asg_sgs}"]
  key_name = "${var.key_name}"
  root_block_device {
    volume_size = "${var.root_volume_size}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name = "${aws_launch_configuration.lc.name}"
  launch_configuration  = "${aws_launch_configuration.lc.name}"
  vpc_zone_identifier = ["${var.priv_subnets}"]
  max_size = "${var.asg_max}"
  min_size = "${var.asg_min}"
  desired_capacity = "${var.asg_desired}"
  health_check_grace_period = 300
  health_check_type = "EC2"
  force_delete = true
  tag {
    key = "Name"
    value = "${var.app_name}"
    propagate_at_launch = true
  }
  tag {
    key = "ConsulCluster"
    value = "${var.datacenter}"
    propagate_at_launch = true
  }
}
