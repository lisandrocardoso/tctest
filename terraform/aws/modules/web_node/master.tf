resource "aws_instance" "web" {
  ami = "${var.ami}"
  instance_type = "t2.micro"
  key_name = "${var.key_name}"
  count = "${var.servers}"
  tags {
    Name = "${var.name}-${count.index}"
  }
  vpc_security_group_ids = [ "${var.vpc_security_group_ids}" ]
  subnet_id = "${var.subnet_id}"

  provisioner "chef" {
    node_name = "web-${count.index}"
    run_list = [ "recipe[learn_chef_apache2]" ]
    server_url = "${var.chef_server_url}"
    validation_client_name = "${var.chef_validation_client_name}"
    validation_key_path = "${var.chef_validation_key_path}"
    connection {
      user = "${var.conn_user}"
      key_file = "${var.conn_key_file}"
    }
  }
}
