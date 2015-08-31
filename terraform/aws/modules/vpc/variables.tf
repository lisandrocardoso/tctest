variable "vpc_cidr_block" {
  default = "10.2.0.0/16"
}
variable "subnet_cidr_block" {
  default = "10.2.1.0/24"
}
variable "map_public_ip_on_launch" {
  default = true
}
