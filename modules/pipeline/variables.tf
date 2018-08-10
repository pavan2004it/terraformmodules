variable "name" { description = "clinfeed-pipeline" }

variable "build_image" { default = "aws/codebuild/docker:1.12.1" }

variable "build_compute_type" { default     = "BUILD_GENERAL1_SMALL" }

variable "region" { default = "us-east-1" }

variable "accountid" { default = "672985825598"}

variable "image_repo_name" {}

variable "image_tag" {}

variable "environment" { default = "dev"}

variable "vpcid" { default = "vpc-727b9214"}

variable "subnet1" { default = "subnet-7e109725"}

variable "subnet2" { default = "subnet-63f28f2a"}

variable "securitygroupid" { default = "sg-9c186be1"}

variable "image_version_tag" {}

variable "artifactbucket" { default = "clinfeedartifactsdev"}

variable "SourceS3Bucket" { default = "fls-clinfeed" }

# variable "SourceS3ObjectKey" {}

variable "cluster" {}

variable "services" { type = "list" }

variable "count" {}

variable "s3ObjectKey" { type = "list" }