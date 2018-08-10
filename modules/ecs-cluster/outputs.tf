
output "cluster_arn" {
  value = "${aws_ecs_cluster.cluster.id}"
}

output "container_instance_security_group_id" {
  value = "${aws_security_group.container_instance.id}"
}

output "container_instance_ecs_for_ec2_service_role_name" {
  value = "${aws_iam_role.container_instance_ec2.name}"
}

output "ecs_service_role_name" {
  value = "${aws_iam_role.ecs_service_role.name}"
}

output "ecs_autoscale_role_name" {
  value = "${aws_iam_role.ecs_autoscale_role.name}"
}

output "ecs_service_role_arn" {
  value = "${aws_iam_role.ecs_service_role.arn}"
}

output "ecs_autoscale_role_arn" {
  value = "${aws_iam_role.ecs_autoscale_role.arn}"
}

output "container_instance_ecs_for_ec2_service_role_arn" {
  value = "${aws_iam_role.container_instance_ec2.arn}"
}
