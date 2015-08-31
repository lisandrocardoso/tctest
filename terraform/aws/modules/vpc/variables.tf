variable "access_key" {
  default = "AKIAIF3ZI2343J2JRRWQ"
}
variable "secret_key" {
  default = "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"
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
