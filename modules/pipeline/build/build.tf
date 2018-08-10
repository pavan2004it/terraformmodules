data "aws_caller_identity" "default" {}

data "aws_region" "default" {}

resource "aws_iam_role" "default" {
  name               = "clinfeed-codebuild-role"
  assume_role_policy = "${data.aws_iam_policy_document.role.json}"
}

data "aws_iam_policy_document" "role" {
  statement {
    sid = ""

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_policy" "default" {
  name   = "clinfeed-codebuild-policy"
  path   = "/service-role/"
  policy = "${data.aws_iam_policy_document.permissions.json}"
}


data "aws_iam_policy_document" "permissions" {
  statement {
    sid = ""

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ecr:*",
      "ec2:*",
      "s3:*",
      "ecs:*",
    ]

    effect = "Allow"

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "default" {
  policy_arn = "${aws_iam_policy.default.arn}"
  role       = "${aws_iam_role.default.id}"
}


resource "aws_codebuild_project" "default" {
  count = "${var.count}"
  name         = "ClinFeed-${element(var.services, count.index)}"
  service_role = "${aws_iam_role.default.arn}"

  vpc_config {
    vpc_id = "${var.vpcid}"

    subnets = [
      "${var.subnet1}",
      "${var.subnet2}",
    ]

    security_group_ids = [
      "${var.securitygroupid}",
    ]
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "${var.build_compute_type}"
    image           = "${var.build_image}"
    type            = "LINUX_CONTAINER"

    privileged_mode = true

    environment_variable = [
      {
        "name"  = "AWS_DEFAULT_REGION"
        "value" = "${var.aws_region}"
      },
      {
        "name"  = "AWS_ACCOUNT_ID"
        "value" = "${var.aws_account_id}"
      },
      {
        "name"  = "IMAGE_REPO_NAME"
        "value" = "${var.image_repo_name}${element(var.s3ObjectKey, count.index)}"
      },
      {
        "name"  = "IMAGE_TAG"
        "value" = "${element(var.services, count.index)}-cp"
      },
      {
        "name"  = "IMAGE_VERSION_TAG"
        "value" = "${var.image_version_tag}"
      },
    ]
  }
}

########## ScheduleWorkerRole

resource "aws_codebuild_project" "scheduleworkerrole" {
  name         = "ClinFeed-scheduleworkerrole"
  service_role = "${aws_iam_role.default.arn}"

  vpc_config {
    vpc_id = "${var.vpcid}"

    subnets = [
      "${var.subnet1}",
      "${var.subnet2}",
    ]

    security_group_ids = [
      "${var.securitygroupid}",
    ]
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "${var.build_compute_type}"
    image           = "${var.build_image}"
    type            = "LINUX_CONTAINER"

    privileged_mode = true

    environment_variable = [
      {
        "name"  = "AWS_DEFAULT_REGION"
        "value" = "${var.aws_region}"
      },
      {
        "name"  = "AWS_ACCOUNT_ID"
        "value" = "${var.aws_account_id}"
      },
      {
        "name"  = "IMAGE_REPO_NAME"
        "value" = "${var.image_repo_name}scheduleworkerrole"
      },
      {
        "name"  = "IMAGE_TAG"
        "value" = "scheduleworkerrole-cp"
      },
      {
        "name"  = "IMAGE_VERSION_TAG"
        "value" = "${var.image_version_tag}"
      },
    ]
  }
}