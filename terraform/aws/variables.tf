variable "access_key" {
  default = ""
}
variable "secret_key" {
  default = ""
}
variable "region" {
  default = "us-east-1"
}
variable "amis" {
  default = {
    us-east-1 = "ami-d05e75b8"
    us-west-2 = "ami-5189a661"
  }
}
