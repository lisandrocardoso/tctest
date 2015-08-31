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
variable "subnet_id" {
  default = ""
}
