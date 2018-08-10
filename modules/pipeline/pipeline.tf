data "aws_caller_identity" "default" {}

data "aws_region" "default" {
  current = true
}

resource "aws_iam_role" "default" {
  name               = "clinfeed-assume-iam-role"
  assume_role_policy = "${data.aws_iam_policy_document.assume.json}"
}

data "aws_iam_policy_document" "assume" {
  statement {
    sid = ""

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = "${aws_iam_role.default.id}"
  policy_arn = "${aws_iam_policy.default.arn}"
}

resource "aws_iam_policy" "default" {
  name   = "clinfeed-default-iam-role"
  policy = "${data.aws_iam_policy_document.default.json}"
}

data "aws_iam_policy_document" "default" {
  statement {
    sid = ""

    actions = [
      "elasticbeanstalk:*",
      "ec2:*",
      "elasticloadbalancing:*",
      "autoscaling:*",
      "cloudwatch:*",
      "s3:*",
      "sns:*",
      "cloudformation:*",
      "rds:*",
      "sqs:*",
      "ecs:*",
      "iam:PassRole",
      "codebuild:*"
    ]

    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_role_policy_attachment" "s3" {
  role       = "${aws_iam_role.default.id}"
  policy_arn = "${aws_iam_policy.s3.arn}"
}

resource "aws_iam_policy" "s3" {
  name   = "clinfeed-s3-iam-policy"
  policy = "${data.aws_iam_policy_document.s3.json}"
}

data "aws_iam_policy_document" "s3" {
  statement {
    sid = ""

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObject",
    ]

    resources = [
      "*"
    ]

    effect = "Allow"
  }
}

resource "aws_iam_role_policy_attachment" "codebuild" {
  role       = "${aws_iam_role.default.id}"
  policy_arn = "${aws_iam_policy.codebuild.arn}"
}

resource "aws_iam_policy" "codebuild" {
  name   = "clinfeed-codebuild"
  policy = "${data.aws_iam_policy_document.codebuild.json}"
}

data "aws_iam_policy_document" "codebuild" {
  statement {
    sid = ""

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ecr:*",
      "ec2:*",
      "s3:*",
    ]

    effect = "Allow"

    resources = [
      "*",
    ]
  }
}

module "build" {
  source             = "./build"
  name               = "${var.services}"
  services           = "${var.services}"
  count              = "${var.count}"
  build_image        = "${var.build_image}"
  build_compute_type = "${var.build_compute_type}"
  aws_region         = "${var.region}"
  aws_account_id     = "${var.accountid}"
  image_repo_name    = "${var.image_repo_name}"
  image_tag          = "${var.image_tag}"
  environment        = "${var.environment}"
  vpcid              = "${var.vpcid}"
  subnet1            = "${var.subnet1}"
  subnet2            = "${var.subnet2}"
  securitygroupid    = "${var.securitygroupid}"
  image_version_tag  = "${var.image_version_tag}"
  s3ObjectKey        = "${var.s3ObjectKey}"
}

resource "aws_iam_role_policy_attachment" "codebuild_s3" {
  role       = "${module.build.role_arn}"
  policy_arn = "${aws_iam_policy.s3.arn}"
}

resource "aws_codepipeline" "source_build_deploy" {
  count = "${var.count}"
  name     = "clinfeed-${element(var.services, count.index)}-pipeline"
  role_arn = "${aws_iam_role.default.arn}"


  artifact_store {
    #location = "${aws_s3_bucket.default.bucket}"
    location = "${var.artifactbucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["MyApp"]
      run_order        = "1"

      configuration {
        S3Bucket = "${var.SourceS3Bucket}"
        S3ObjectKey = "${element(var.s3ObjectKey, count.index)}.zip"
      }
    }
  }

  stage {
    name = "Build${element(var.services, count.index)}"

    action {
      name     = "Build"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"

      input_artifacts  = ["MyApp"]
      output_artifacts = ["MyAppBuild"]

      configuration {
        ProjectName = "${module.build.project_name[count.index]}"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy${element(var.services, count.index)}"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["MyAppBuild"]
      version         = "1"

      configuration {
        ClusterName = "${var.cluster}"
        ServiceName = "${element(var.services, count.index)}"
        FileName = "imagedefinitions.json"
      }
    }
  }
}

################# Schedule Worker Role Pipeline ###########################

resource "aws_codepipeline" "schedule_worker_role_source_build_deploy" {
  name     = "clinfeed-scheduleworkerrole-pipeline"
  role_arn = "${aws_iam_role.default.arn}"


  artifact_store {
    location = "${var.artifactbucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["MyApp"]
      run_order        = "1"

      configuration {
        S3Bucket = "${var.SourceS3Bucket}"
        S3ObjectKey = "scheduleworkerrole.zip"
      }
    }
  }

  stage {
    name = "BuildScheduleWorkerRole"

    action {
      name     = "Build"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"

      input_artifacts  = ["MyApp"]
      output_artifacts = ["MyAppBuild"]

      configuration {
        ProjectName = "ClinFeed-scheduleworkerrole"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "DeployScheduleWorkerRole"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["MyAppBuild"]
      version         = "1"

      configuration {
        ClusterName = "${var.cluster}"
        ServiceName = "scheduleworkerrole"
        FileName = "imagedefinitions.json"
      }
    }
  }
}