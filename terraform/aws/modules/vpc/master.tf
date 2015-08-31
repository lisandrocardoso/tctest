resource "aws_vpc" "tctest_vpc" {
  cidr_block = "${var.vpc_cidr_block}"

  tags {
    Name = "tctest"
  }
}

resource "aws_internet_gateway" "tctest_igw" {
  vpc_id = "${aws_vpc.tctest_vpc.id}"
  tags {
    Name = "tctest"
  }
}

resource "aws_subnet" "tctest_subnet" {
  vpc_id = "${aws_vpc.tctest_vpc.id}"
  cidr_block = "${var.subnet_cidr_block}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"

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
