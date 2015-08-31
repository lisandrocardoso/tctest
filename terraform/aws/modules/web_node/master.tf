resource "aws_instance" "web" {
  ami = "${var.ami}"
  instance_type = "t2.micro"
  count = "${var.servers}"
  tags {
    Name = "${var.name}-${count.index}"
  }
  vpc_security_group_ids = [ "${var.vpc_security_group_ids}" ]
  subnet_id = "${var.subnet_id}"
}