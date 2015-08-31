resource "aws_vpc" "tctest_vpc" {
  cidr_block = "10.2.0.0/16"

  tags {
    Name = "tctest"
  }
}

resource "aws_internet_gateway" "tctest_gw" {
  vpc_id = "${aws_vpc.tctest_vpc.id}"
  tags {
    Name = "tctest"
  }
}

resource "aws_subnet" "tctest_subnet" {
  vpc_id = "${aws_vpc.tctest_vpc.id}"
  cidr_block = "10.2.1.0/24"
  map_public_ip_on_launch = true

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

  vpc_id = "${aws_vpc.tctest_vpc.id}"

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
  subnet_id = "${aws_subnet.tctest_subnet.id}"
  servers = 2

  chef_path = "../../chef/tctest/"

}

resource "aws_elb" "tctest" {
  name = "tctest-elb"
  instances = [ "${split(",", module.web_node.ids)}" ]
  cross_zone_load_balancing = true
  subnets = [ "${aws_subnet.tctest_subnet.id}" ]
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
    target = "HTTP:80/"
    interval = 30
  }
}

output "web_ids" {
  value = "${module.web_node.ids}"
}
