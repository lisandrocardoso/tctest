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

resource "aws_subnet" "tctest_web_subnet" {
  vpc_id = "${aws_vpc.tctest_vpc.id}"
  cidr_block = "${var.web_subnet_cidr_block}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"

  tags {
      Name = "tctest web"
  }
}

resource "aws_subnet" "tctest_db_subnet" {
  vpc_id = "${aws_vpc.tctest_vpc.id}"
  cidr_block = "${var.db_subnet_cidr_block}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"

  tags {
      Name = "tctest db"
  }
}
resource "aws_route_table" "tctest_web_route_table" {
  vpc_id = "${aws_vpc.tctest_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.tctest_igw.id}"
  }
}

resource "aws_route_table" "tctest_db_route_table" {
  vpc_id = "${aws_vpc.tctest_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.tctest_igw.id}"
  }
}

resource "aws_route_table_association" "tctest_web_rta" {
  subnet_id = "${aws_subnet.tctest_web_subnet.id}"
  route_table_id = "${aws_route_table.tctest_web_route_table.id}"
}
resource "aws_route_table_association" "tctest_db_rta" {
  subnet_id = "${aws_subnet.tctest_db_subnet.id}"
  route_table_id = "${aws_route_table.tctest_db_route_table.id}"
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
resource "aws_security_group" "db" {
  name = "db"
  description = "Allow MySQL from subnet"

  tags {
    Name = "db"
  }

  vpc_id = "${aws_vpc.tctest_vpc.id}"

  # SSH access from anywhere
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["${var.web_subnet_cidr_block}"]
  }

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["${var.db_subnet_cidr_block}"]
  }

  # outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
