resource "aws_instance" "mysql-slave" {
  ami = "${var.ami}"
  instance_type = "t2.micro"
  key_name = "${var.key_name}"
  count = "${var.servers}"
  tags {
    Name = "${var.name}-${count.index}"
    master_dependency = "${var.master_dependency}"
  }
  vpc_security_group_ids = [ "${var.vpc_security_group_ids}" ]
  subnet_id = "${var.subnet_id}"

  provisioner "chef" {
    attributes {
      "tctest" {
        "database" {
          "slave_id" = "${count.index+2}"
        }
      }
    }
    node_name = "mysql_slave-${count.index}"
    run_list = [ "recipe[apt::default]", "recipe[tctest::database_slave]" ]
    server_url = "${var.chef_server_url}"
    validation_client_name = "${var.chef_validation_client_name}"
    validation_key_path = "${var.chef_validation_key_path}"
    connection {
      user = "${var.conn_user}"
      key_file = "${var.conn_key_file}"
    }
  }

}
