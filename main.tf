

provider "aws" {
  region              = "${var.aws_region}"
  allowed_account_ids = ["${var.aws_account}"]

}


data "aws_availability_zones" "available" {}

module "ecs" {
  source  = "./modules/ecs-cluster/"

  environment = "Test"
  cluster_name = "Clinfeed-Test"
  vpc_id = "${var.vpc_id}"
  private_subnet_ids = "${var.private_subnet_ids}"
  lookup_latest_ami = true
  key_name = "ecs-clinfeed"
  instance_type = "m5.xlarge"
  desired_capacity = "1"
  min_size = "1"
  max_size = "2"
  root_block_device_type = "gp2"
  root_block_device_size = "100"
}

resource "aws_security_group_rule" "allow_all_egress" {
  type            = "egress"
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
  cidr_blocks     = ["0.0.0.0/0"]
  security_group_id = "${module.ecs.container_instance_security_group_id}"
}

resource "aws_security_group_rule" "allow_ingress_9000" {
  type            = "ingress"
  from_port       = 9000
  to_port         = 9000
  protocol        = "-1"
  source_security_group_id = "${module.ecs-clinfeed-service.lb_security_group_id}"
  security_group_id = "${module.ecs.container_instance_security_group_id}"
}

module "ecs-clinfeed-service" {
  source  = "./modules/ecs-service-alb/"

  ecs_autoscale_role_arn  = "${module.ecs.ecs_autoscale_role_arn}"
  vpc_id                  = "${var.vpc_id}"
  private_subnet_ids       = ["${var.private_subnet_ids}"]
  CLUSTER_ARN            = "${module.ecs.cluster_arn}"
  container_port          = "${var.container_port}"
  ecs_service_role_arn   = "${module.ecs.ecs_service_role_name}"
  access_log_prefix       = "ALB"
  host_port               = "${var.host_port}"
  environment             = "${var.env}"
  project                 = "fls"
  services                = "${var.services}"
  healthpath		  = "${var.healthpath}"
  count = "16"
}
/*
module "elastic" {
  source = "clinfeed-new/modules/elastic/"

  elastic_instance_size =  "${var.elastic_instance_size}"
  region = "${var.aws_region}"
  environment = "${var.env}"
  private_subnet_ids = "${var.private_subnet_ids}"
  vpc_id = "${var.vpc_id}"
  stream_function_name = "${var.stream_function_name}"

  tags = "${
    map(
        "VPC", "${var.vpc_id}",
        "Environment", "${var.env}"
        )
    }"
}


module "cloudwatch" {
  source = "clinfeed-new/modules/cloudwatch/"
  cwl_stream_lambda_arn = "${module.elastic.cwl_stream_lambda_arn}"
  lambda_function_name = "${module.elastic.lambda_name}"
  env = "${var.env}"
  services = "${var.services}"
  count = "19"
}

module "clinfeed-pipeline-dev" {
  source = "clinfeed-new/modules/pipeline"

  name = "clinfeed"
  build_image = "aws/codebuild/docker:17.09.0"
  build_compute_type = "BUILD_GENERAL1_SMALL"
  region = "${var.aws_region}"
  accountid = "${var.aws_account}"
  image_repo_name = "fls/"
  image_tag = "latest"
  environment = "dev"
  services = "${var.services}"
  s3ObjectKey = "${var.s3ObjectKey}"
  count = "19"
  vpcid = "${var.vpc_id}"
  subnet1 = "subnet-7e109725"
  subnet2 = "subnet-63f28f2a"
  securitygroupid = "sg-9c186be1"
  image_version_tag = "v1"
  artifactbucket = "clinfeedartifactsdev"
  SourceS3Bucket = "fls-clinfeed"
  cluster = "${module.ecs.name}"

}
*/
