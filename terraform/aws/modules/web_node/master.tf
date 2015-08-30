variable "ami" {
  default = "ami-d05e75b8"
}
variable "name" {
  default = "web-instance"
}
variable "chef_path" {
  default = "./chef/"
}
variable "servers" {
  default = 1
}
variable "vpc_security_group_ids" {
  default = []
}
variable "elb_id" {
  default = ""
}

# The actual instance

resource "aws_instance" "web" {
  ami = "${var.ami}"
  instance_type = "t2.micro"
  count = "${var.servers}"
  tags {
    Name = "${var.name}-${count.index}"
  }
  vpc_security_group_ids = [ "${var.vpc_security_group_ids}" ]
}

# Outputs

output "ids" {
  value = [ "${aws_instance.web.*.id}" ]
}
output "public_ips" {
  value = "${join(",", aws_instance.web.*.public_ip)}"
}

