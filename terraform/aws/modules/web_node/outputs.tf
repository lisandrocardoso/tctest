output "ids" {
  value = "${join(",", aws_instance.web.*.id)}"
}
output "public_ips" {
  value = "${join(",", aws_instance.web.*.public_ip)}"
}

