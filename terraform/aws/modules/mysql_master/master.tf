resource "aws_instance" "mysql" {
  ami = "${var.ami}"
  instance_type = "t2.micro"
  tags {
    Name = "mysql-master"
  }
  vpc_security_group_ids = [ "${var.vpc_security_group_ids}" ]
  subnet_id = "${var.subnet_id}"
}
