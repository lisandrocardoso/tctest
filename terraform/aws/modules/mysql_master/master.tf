resource "aws_instance" "mysql-master" {
  ami = "${var.ami}"
  instance_type = "t2.micro"
  key_name = "${var.key_name}"
  tags {
    Name = "mysql-master"
  }
  vpc_security_group_ids = [ "${var.vpc_security_group_ids}" ]
  subnet_id = "${var.subnet_id}"

  provisioner "chef" {
    node_name = "mysql-master"
    run_list = [ "recipe[apt::default]", "recipe[tctest::database_master]" ]
    server_url = "${var.chef_server_url}"
    validation_client_name = "${var.chef_validation_client_name}"
    validation_key_path = "${var.chef_validation_key_path}"
    connection {
      user = "${var.conn_user}"
      key_file = "${var.conn_key_file}"
    }
  }

}
