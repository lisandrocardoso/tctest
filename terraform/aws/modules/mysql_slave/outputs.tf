output "id" {
  value = "${aws_instance.mysql-slave.id}"
}
output "private_ip" {
  value = "${aws_instance.mysql-slave.private_ip}"
}
