provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

module "vpc" {
  source = "./modules/vpc"
}

module "mysql_master" {
  source = "./modules/mysql_master"
  name = "mysql_master"
  vpc_security_group_ids = "${module.vpc.db_security_group_id}"
  subnet_id = "${module.vpc.db_subnet_id}"

  chef_server_url = "https://api.opscode.com/organizations/lisandroec"
  chef_validation_client_name = "lisandroec-validator"
  chef_validation_key_path = "../../chef/tctest/.chef/lisandroec-validator.pem"

  key_name = "tctest"
  conn_user = "ubuntu"
  conn_key_file = "../../keys/tctest.pem"
}

module "mysql_slave" {
  master_dependency = "${module.mysql_master.id}"

  source = "./modules/mysql_slave"
  name = "mysql_slave"
  vpc_security_group_ids = "${module.vpc.db_security_group_id}"
  subnet_id = "${module.vpc.db_subnet_id}"
  servers = 1

  chef_server_url = "https://api.opscode.com/organizations/lisandroec"
  chef_validation_client_name = "lisandroec-validator"
  chef_validation_key_path = "../../chef/tctest/.chef/lisandroec-validator.pem"

  key_name = "tctest"
  conn_user = "ubuntu"
  conn_key_file = "../../keys/tctest.pem"
}

module "web_node" {
  slave_dependency = "${module.mysql_slave.id}"

  source = "./modules/web_node"
  name = "web"
  vpc_security_group_ids = "${module.vpc.web_security_group_id}"
  subnet_id = "${module.vpc.web_subnet_id}"
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
  subnet_id = "${module.vpc.web_subnet_id}"
  security_group_id = "${module.vpc.web_security_group_id}"
}
