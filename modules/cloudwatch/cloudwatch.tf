variable cwl_stream_lambda_arn {}
variable env {}
variable lambda_function_name {}
variable services { type = "list" }
variable count {}

####### Servioe Logs

resource "aws_cloudwatch_log_group" "clinfeed_container_log_group" {
  count = "${var.count}"
  name = "clinfeed-${element(var.services, count.index)}-container-logs-${var.env}"
  retention_in_days = 14
}

resource "aws_lambda_permission" "clinfeed_container_logs_allow" {
  count = "${var.count}"
  statement_id = "cloudwatch_allow_${element(var.services, count.index)}"
  action = "lambda:InvokeFunction"
  function_name = "${var.lambda_function_name}"
  principal = "logs.us-east-1.amazonaws.com"
  source_arn = "${aws_cloudwatch_log_group.clinfeed_container_log_group.*.arn[count.index]}"
}

resource "aws_cloudwatch_log_subscription_filter" "clinfeed_container_logs_to_es" {
  count = "${var.count}"
  depends_on = ["aws_lambda_permission.clinfeed_container_logs_allow"]
  name            = "cloudwatch_logs_to_elasticsearch"
  log_group_name  = "${aws_cloudwatch_log_group.clinfeed_container_log_group.*.name[count.index]}"
  filter_pattern  = ""
  destination_arn = "${var.cwl_stream_lambda_arn}"
}

####### ScheduleWorkerRole

resource "aws_cloudwatch_log_group" "scheduleworkerrole-log-group" {
  name = "clinfeed-scheduleworkerrole-container-logs-${var.env}"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_subscription_filter" "scheduleworkerrole_logs_to_es" {
  depends_on = ["aws_lambda_permission.scheduleworkerrole_logs_allow"]
  name            = "cloudwatch_logs_to_elasticsearch"
  log_group_name  = "${aws_cloudwatch_log_group.scheduleworkerrole-log-group.name}"
  filter_pattern  = ""
  destination_arn = "${var.cwl_stream_lambda_arn}"
}

resource "aws_lambda_permission" "scheduleworkerrole_logs_allow" {
  statement_id = "cloudwatch_allow_scheduleworkerrole"
  action = "lambda:InvokeFunction"
  function_name = "${var.lambda_function_name}"
  principal = "logs.us-east-1.amazonaws.com"
  source_arn = "${aws_cloudwatch_log_group.scheduleworkerrole-log-group.arn}"
}

####### Cluster Logs

resource "aws_cloudwatch_log_group" "cluster-log-group" {
  name = "fls-cluster-logs-${var.env}"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_subscription_filter" "cluster_logs_to_es" {
  depends_on = ["aws_lambda_permission.cluster_logs_allow"]
  name            = "cloudwatch_logs_to_elasticsearch"
  log_group_name  = "${aws_cloudwatch_log_group.cluster-log-group.name}"
  filter_pattern  = ""
  destination_arn = "${var.cwl_stream_lambda_arn}"
}

resource "aws_lambda_permission" "cluster_logs_allow" {
  statement_id = "cloudwatch_allow"
  action = "lambda:InvokeFunction"
  function_name = "${var.lambda_function_name}"
  principal = "logs.us-east-1.amazonaws.com"
  source_arn = "${aws_cloudwatch_log_group.cluster-log-group.arn}"
}


/*
##### APPROVALS #####
resource "aws_cloudwatch_log_group" "approval_container_log_group" {
  name = "approval-container-logs-${var.env}"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_subscription_filter" "approval_container_logs_to_es" {
  depends_on = ["aws_lambda_permission.trident_container_logs_allow"]
  name            = "cloudwatch_logs_to_elasticsearch"
  log_group_name  = "${aws_cloudwatch_log_group.approval_container_log_group.name}"
  filter_pattern  = ""
  destination_arn = "${var.cwl_stream_lambda_arn}"
}

resource "aws_lambda_permission" "approval_container_logs_allow" {
  statement_id = "cloudwatch_allow_2"
  action = "lambda:InvokeFunction"
  function_name = "${var.lambda_function_name}"
  principal = "logs.us-east-1.amazonaws.com"
  source_arn = "${aws_cloudwatch_log_group.approval_container_log_group.arn}"
}

##### AUTHORIZATION #####
resource "aws_cloudwatch_log_group" "authorization_container_log_group" {
  name = "authorization-container-logs-${var.env}"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_subscription_filter" "authorization_container_logs_to_es" {
  depends_on = ["aws_lambda_permission.trident_container_logs_allow"]
  name            = "cloudwatch_logs_to_elasticsearch"
  log_group_name  = "${aws_cloudwatch_log_group.authorization_container_log_group.name}"
  filter_pattern  = ""
  destination_arn = "${var.cwl_stream_lambda_arn}"
}

resource "aws_lambda_permission" "authorization_container_logs_allow" {
  statement_id = "cloudwatch_allow_2"
  action = "lambda:InvokeFunction"
  function_name = "${var.lambda_function_name}"
  principal = "logs.us-east-1.amazonaws.com"
  source_arn = "${aws_cloudwatch_log_group.authorization_container_log_group.arn}"
}
##### CLINCONNECTBRIDGE #####
resource "aws_cloudwatch_log_group" "clinconnectbridge_container_log_group" {
  name = "authorization-container-logs-${var.env}"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_subscription_filter" "clinconnectbridge_container_logs_to_es" {
  depends_on = ["aws_lambda_permission.trident_container_logs_allow"]
  name            = "cloudwatch_logs_to_elasticsearch"
  log_group_name  = "${aws_cloudwatch_log_group.clinconnectbridge_container_log_group.name}"
  filter_pattern  = ""
  destination_arn = "${var.cwl_stream_lambda_arn}"
}

resource "aws_lambda_permission" "clinconnectbridge_container_logs_allow" {
  statement_id = "cloudwatch_allow_2"
  action = "lambda:InvokeFunction"
  function_name = "${var.lambda_function_name}"
  principal = "logs.us-east-1.amazonaws.com"
  source_arn = "${aws_cloudwatch_log_group.clinconnectbridge_container_log_group.arn}"
}
##### CLINPOINTBRIDGE CVOPS #####

##### CLINPOINTBRIDGE DEV4 #####

##### EMAILGATEWAY #####

##### EVENTDATECONFIG #####

##### FEEDSERVICE #####

##### MAPPINGRULES CVOPS #####

##### MAPPINGRULES DEV4 #####

##### MESSAGEBROKER #####

##### MULTITENANT #####

##### SCHEDULEWORKERROLE #####

##### STORAGESERVICE #####

##### STUDYCONFIGURATION #####

##### STUDYEVENT CVOPS #####

##### STUDYEVENT DEV4 #####

##### TRANSFORMEVENTS #####

##### UI #####

##### UISERVICE #####
*/