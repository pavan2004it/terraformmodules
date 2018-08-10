variable elastic_instance_size {}
variable region {}
variable environment {}
variable private_subnet_ids {type = "list"}
variable vpc_id {}
variable stream_function_name {}
//variable subnet_ids {type = "list"}
variable tags {type="map"}

resource "aws_security_group" "elastic" {
  name        = "elastic-clinfeed"
  description = "elastic-clinfeed"
  vpc_id      = "${var.vpc_id}"


  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["67.238.136.122/32"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(var.tags, map("Name", "${var.tags["Environment"]}-sg-elastic"))}"
}

resource "aws_elasticsearch_domain" "es" {
  domain_name           = "clinfeed-es"
  elasticsearch_version = "6.2"
  cluster_config {
    instance_type = "${var.elastic_instance_size}" #"t2.medium.elasticsearch"
  }
/**
  vpc_options {
    security_group_ids = ["${aws_security_group.elastic.id}"]
    subnet_ids = ["${var.subnet_ids}"]
  }
*/
  ebs_options {
    ebs_enabled = "true"
    volume_size = "30"
  }

  vpc_options {
    security_group_ids = [
      "${aws_security_group.elastic.id}"]
    subnet_ids = [
      "${element(var.private_subnet_ids, 0)}"]
  }

  advanced_options {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  access_policies = <<CONFIG
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": {
              "AWS": [
                "*"
                ]
            },
            "Effect": "Allow",
            "Resource": "arn:aws:es:${var.region}:672985825598:domain/clinfeed-es/*"
        }
    ]
}
CONFIG

  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  tags = "${merge(var.tags, map("Name", "${var.tags["Environment"]}-sg-elastic"))}"
}

## Cloudwatch to Elastic lambda setup ##

data "archive_file" "init" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/LogsToElasticSearch.zip"
}

resource "aws_iam_role" "lambda_elasticsearch_execution_role" {
  name = "lambda_elasticsearch_execution_role_clinfeed"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_elasticsearch_execution_policy" {
  name = "lambda_elasticsearch_execution_policy"
  role = "${aws_iam_role.lambda_elasticsearch_execution_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:*",
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",

      "Action": "es:*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_lambda_function" "cwl_stream_lambda" {
  filename         = "${data.archive_file.init.output_path}"
  source_code_hash = "${data.archive_file.init.output_base64sha256}"
  function_name    = "${var.stream_function_name}"
  role             = "${aws_iam_role.lambda_elasticsearch_execution_role.arn}"
  handler          = "index.handler"
  runtime          = "nodejs4.3"

  environment {
    variables = {
      es_endpoint = "${aws_elasticsearch_domain.es.endpoint}"
    }
  }
  vpc_config {
    security_group_ids = ["sg-9c186be1"]
    subnet_ids = ["${var.private_subnet_ids}"]
  }
}

