variable "ami" {
  default = "ami-d05e75b8"
}
variable "key_name" {
  default = ""
}
variable "name" {
  default = ""
}
variable "chef_server_url" {
  default = ""
}
variable "chef_validation_client_name" {
  default = ""
}
variable "chef_validation_key_path" {
  default = ""
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
variable "conn_user" {
  default = ""
}
variable "conn_key_file" {
  default = ""
}
variable "slave_dependency" {
  default = ""
}
