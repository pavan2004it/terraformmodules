variable "project" { default = "Unknown" }
variable "environment" { default = "Unknown" }
variable "vpc_id" {}
variable "private_subnet_ids" { type = "list" }
variable "access_log_prefix" {}
//variable "ssl_certificate_arn" {}
variable "cluster_name" {}
variable "desired_count" { default = "1" }
variable "deployment_min_healthy_percent" { default = "50" }
variable "deployment_max_percent" { default = "200" }
variable "container_port" { type = "list" }
variable "host_port" { type = "list" }
variable "min_count" { default = "1" }
variable "max_count" { default = "1" }
variable "scale_up_cooldown_seconds" { default = "300" }
variable "scale_down_cooldown_seconds" { default = "300" }
variable "ecs_service_role_arn" {}
variable "ecs_autoscale_role_arn" {}
variable "services" { type = "list" }
variable "healthpath" { type = "list" }
variable "count" {}
