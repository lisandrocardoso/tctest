provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

module "vpc" {
  source = "./modules/vpc"
}

module "web_node" {
  source = "./modules/web_node"
  name = "web"
  vpc_security_group_ids = "${module.vpc.security_group_id}"
  subnet_id = "${module.vpc.subnet_id}"
  servers = 2

  chef_server_url = "https://api.opscode.com/organizations/lisandroec"
  chef_validation_client_name = "lisandroec-validator"
  chef_validation_key_path = "../../chef/tctest/.chef/lisandroec-validator.pem"

  key_name = "tctest"
  conn_user = "ubuntu"
  conn_key_file = "../../keys/tctest.pem"
}

module "elb" {
  source = "./modules/elb"
  node_ids = "${module.web_node.ids}"
  subnet_id = "${module.vpc.subnet_id}"
  security_group_id = "${module.vpc.security_group_id}"
}
