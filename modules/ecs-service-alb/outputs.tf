output "lb_security_group_id" {
  value = "${aws_security_group.main.id}"
}

output "alb" {
  value = "${aws_alb.main.dns_name}"
}