output "vpc_id" {
  value = "${aws_vpc.tctest_vpc.id}"
}
output "internet_gateway_id" {
  value = "${aws_internet_gateway.tctest_igw.id}"
}
output "web_subnet_id" {
  value = "${aws_subnet.tctest_web_subnet.id}"
}
output "web_security_group_id" {
  value = "${aws_security_group.web.id}"
}
output "db_subnet_id" {
  value = "${aws_subnet.tctest_db_subnet.id}"
}
output "db_security_group_id" {
  value = "${aws_security_group.db.id}"
}
