provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

resource "aws_vpc" "tctest" {
  cidr_block = "10.1.0.0/16"

  tags {
    Name = "tctest"
  }
}

resource "aws_security_group" "web" {
  name = "web"
  description = "Allow SSH and HTTP for web nodes"

  tags {
    Name = "web"
  }

  vpc_id = "${aws_vpc.tctest.id}"

  # SSH access from anywhere
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "web_node" {
  source = "./modules/web_node"
  name = "web"
  vpc_security_group_ids = "${aws_security_group.web.id}"
  servers = 2

  chef_path = "../../chef/tctest/"

}

resource "aws_elb" "tctest" {
  name = "tctest-elb"
  instances = [ "${module.web_node.ids}" ]
  cross_zone_load_balancing = true
  tags {
    Name = "tctest-elb"
  }

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:8000/"
    interval = 30
  }
}
