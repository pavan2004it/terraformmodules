output "ecs_cluster_log_group" {
  value = "${aws_cloudwatch_log_group.cluster-log-group.name}"
}

output "clinfeed_container_log_group" {
  value = "${aws_cloudwatch_log_group.clinfeed_container_log_group.*.name}"
}

output "clinfeed_scheduleworkerrole_log_group" {
  value = "${aws_cloudwatch_log_group.scheduleworkerrole-log-group.name}"
}