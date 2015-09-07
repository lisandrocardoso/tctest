output "id" {
  value = "${aws_instance.mysql-master.id}"
}
output "private_ip" {
  value = "${aws_instance.mysql-master.private_ip}"
}
