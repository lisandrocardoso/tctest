resource "aws_elb" "tctest" {
  name = "tctest-elb"
  instances = [ "${split(",", "${var.node_ids}")}" ]
  cross_zone_load_balancing = true
  subnets = [ "${var.subnet_id}" ]
  tags {
    Name = "tctest-elb"
  }

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:80/"
    interval = 30
  }
}
