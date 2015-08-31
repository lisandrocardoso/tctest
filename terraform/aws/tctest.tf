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
  vpc_security_group_ids = "${module.vpc.sg_id}"
  subnet_id = "${module.vpc.subnet_id}"
  servers = 2

  chef_path = "../../chef/tctest/"

}

module "elb" {
  source = "./modules/elb"
  node_ids = "${module.web_node.ids}"
  subnet_id = "${module.vpc.subnet_id}"
}
