output "vpc_id" {
  value = "${aws_vpc.tctest_vpc.id}"
}
output "internet_gateway_id" {
  value = "${aws_internet_gateway.tctest_igw.id}"
}
output "subnet_id" {
  value = "${aws_subnet.tctest_subnet.id}"
}
output "sg_id" {
  value = "${aws_security_group.web.id}"
}
