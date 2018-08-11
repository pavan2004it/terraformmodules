#
# Security group resources
#
resource "aws_security_group" "main" {
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "ClinFeedsgLoadBalancer"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}

#
# ALB resources
#
resource "aws_alb" "main" {
  security_groups = ["${aws_security_group.main.id}"]
  subnets         = ["${var.private_subnet_ids}"]
  name            = "clinfeed-alb-${var.environment}"
  internal        = true

  tags {
    Name        = "clinfeed-alb-${var.environment}"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}

resource "aws_alb_target_group" "main" {
  count = "${var.count}"
  name = "tg${var.environment}${element(var.services, count.index)}"
  target_type = "instance"

  health_check {
    healthy_threshold   = "3"
    interval            = "5"
    protocol            = "HTTP"
    timeout             = "3"
    path                = "${element(var.healthpath, count.index)}"
    unhealthy_threshold = "2"
    matcher             = "200-499"
  }

  port = "${element(var.host_port, count.index)}"   // this was just var.port
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = "${aws_alb.main.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "arn:aws:acm:us-east-1:672985825598:certificate/d1e71210-631e-4ee2-b0bb-5f97403c84a7"

  default_action {
    # target_group_arn = "${element(aws_alb_target_group.main.arn, count.index)}"
    target_group_arn = "${aws_alb_target_group.main.*.arn[15]}"
    type             = "forward"
  }
}

resource "aws_lb_listener_rule" "clinfeed" {
  count = "${var.count}"
  listener_arn = "${aws_alb_listener.https.arn}"
  priority     = "${count.index + 1}"

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.main.*.arn[count.index]}"
  }

  condition {
    field  = "path-pattern"
    values = ["/api/${element(var.services, count.index)}*"]
  }
} 

data "template_file" "task_def" {
  count = "${var.count}"
  template = "${file("${path.module}/containerdef/${element(var.services, count.index)}-container-def.json")}"
  vars {
    LOG_GROUP = "clinfeed-${element(var.services, count.index)}-container-logs-${var.environment}"
    ALB = "${aws_alb.main.dns_name}"
    CVOPS_DB = "flsdb.czavkspy3bd9.us-east-1.rds.amazonaws.com"
    DEV4_DB = "flsdb.czavkspy3bd9.us-east-1.rds.amazonaws.com"
    ASPNETCORE_ENVIRONMENT = "Development"
    adfs.url = "https://fs.clinpay.com/adfs"
    ConnectionString = "Data Source=flsdb.czavkspy3bd9.us-east-1.rds.amazonaws.com;Initial Catalog=SystemDB;User Id=aoteam;Password=123@Queso;Integrated Security=false;Connection Timeout=60;MultipleActiveResultSets=false;"
    ClinPointDbConnString_flsdev4 = "Data Source=flsdb.czavkspy3bd9.us-east-1.rds.amazonaws.com;Initial Catalog=ClinPointDB;User Id=ClinFeeduser;Password=Abcd@4321;Integrated Security=false;Connection Timeout=60;MultipleActiveResultSets=false;"
    ClinPointDbConnString_flscvops = "Data Source=flsdb.czavkspy3bd9.us-east-1.rds.amazonaws.com;Initial Catalog=ClinPointDB;User Id=ClinFeeduser;Password=Abcd@4321;Integrated Security=false;Connection Timeout=60;MultipleActiveResultSets=false;"
    AnypointMqConfigBaseUrl = "https://mq-us-east-1.anypoint.mulesoft.com/api/v1/"
    AnypointMqConfigClientId = "f8452cc7acc649aaa6ca2c4030710473"
    AnypointMqConfigClientSecret = "be8298a197514f0585226977042EBDEA"
    BlobStorage = "DefaultEndpointsProtocol=https;AccountName=clinfeedstoragedev;AccountKey=2wEq4KK+JtMc4O5Twtjcat61uIZiiZhCz405P2IA+ex4tUSCvCL5ge5H/AWmbyfFoMjKoMHGkbOVkTF4me7++A==;BlobEndpoint=https://clinfeedstoragedev.blob.core.windows.net/"
  }
}

resource "aws_ecs_task_definition" "task_definition" {
  count = "${var.count}"
  family = "${element(var.services, count.index)}-test"
  network_mode = "bridge"

  container_definitions = "${data.template_file.task_def.*.rendered[count.index]}"
}

# "${data.template_file.task_def.*.rendered[count.index]}"

#
# ECS resources
#
resource "aws_ecs_service" "main" {
  count = "${var.count}"
  lifecycle {
    create_before_destroy = true
  }

  name                               = "${element(var.services, count.index)}"
  cluster                            = "${var.CLUSTER_ARN}"
  # task_definition                    = "${element(aws_ecs_task_definition.task_definition.id, count.index)}"
  task_definition                    = "${aws_ecs_task_definition.task_definition.*.arn[count.index]}"
  desired_count                      = "${var.desired_count}"
  deployment_minimum_healthy_percent = "${var.deployment_min_healthy_percent}"
  deployment_maximum_percent         = "${var.deployment_max_percent}"
  //iam_role                           = "${var.ecs_service_role_arn}"
  health_check_grace_period_seconds   = "180"


  load_balancer {
    target_group_arn = "${aws_alb_target_group.main.*.id[count.index]}"
    container_name   = "${element(var.services, count.index)}"
    container_port   = "${element(var.container_port, count.index)}"
  }
   
  depends_on = ["aws_alb.main"]

}

