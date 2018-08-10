

variable "name" {
  default     = "app"
  description = "Solution name, e.g. 'app' or 'jenkins'"
}

variable "enabled" {
  default     = "true"
  description = "Enable ``CodePipeline`` creation"
}

variable "app" {
  type        = "string"
  default     = ""
  description = "Elastic Beanstalk application name. If not provided or set to empty string, the ``Deploy`` stage of the pipeline will not be created"
}

variable "env" {
  type        = "string"
  default     = ""
  description = "Elastic Beanstalk environment name. If not provided or set to empty string, the ``Deploy`` stage of the pipeline will not be created"
}

variable "build_image" {
  default     = "aws/codebuild/docker:1.12.1"
  description = "Docker image for build environment, _e.g._ `aws/codebuild/docker:1.12.1` or `aws/codebuild/eb-nodejs-6.10.0-amazonlinux-64:4.0.0`"
}

variable "build_compute_type" {
  default     = "BUILD_GENERAL1_SMALL"
  description = "`CodeBuild` instance size.  Possible values are: ```BUILD_GENERAL1_SMALL``` ```BUILD_GENERAL1_MEDIUM``` ```BUILD_GENERAL1_LARGE```"
}

variable "buildspec" {
  default     = ""
  description = " Declaration to use for building the project. [For more info](http://docs.aws.amazon.com/codebuild/latest/userguide/build-spec-ref.html)"
}

# https://www.terraform.io/docs/configuration/variables.html
# It is recommended you avoid using boolean values and use explicit strings
variable "poll_source_changes" {
  type        = "string"
  default     = "true"
  description = "Periodically check the location of your source content and run the pipeline if changes are detected"
}

variable "delimiter" {
  type        = "string"
  default     = "-"
  description = "Delimiter to be used between `name`, `namespace`, `stage`, etc."
}

variable "attributes" {
  type        = "list"
  default     = []
  description = "Additional attributes (e.g. `policy` or `role`)"
}

variable "tags" {
  type        = "map"
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit', 'XYZ')`"
}

variable "privileged_mode" {
  default     = "false"
  description = "If set to true, enables running the Docker daemon inside a Docker container on the CodeBuild instance. Used when building Docker images"
}

variable "aws_region" {
  type        = "string"
  default     = ""
  description = "AWS Region, e.g. us-east-1. Used as CodeBuild ENV variable when building Docker images. [For more info](http://docs.aws.amazon.com/codebuild/latest/userguide/sample-docker.html)"
}

variable "aws_account_id" {
  type        = "string"
  default     = ""
  description = "AWS Account ID. Used as CodeBuild ENV variable when building Docker images. [For more info](http://docs.aws.amazon.com/codebuild/latest/userguide/sample-docker.html)"
}

variable "image_repo_name" {
  type        = "string"
  default     = "UNSET"
  description = "ECR repository name to store the Docker image built by this module. Used as CodeBuild ENV variable when building Docker images. [For more info](http://docs.aws.amazon.com/codebuild/latest/userguide/sample-docker.html)"
}

variable "image_tag" {
  type        = "string"
  default     = "latest"
  description = "Docker image tag in the ECR repository, e.g. 'latest'. Used as CodeBuild ENV variable when building Docker images. [For more info](http://docs.aws.amazon.com/codebuild/latest/userguide/sample-docker.html)"
}

variable "environment_variables" {
  type = "list"

  default = [{
    "name"  = "NO_ADDITIONAL_BUILD_VARS"
    "value" = "TRUE"
  }]

  description = "A list of maps, that contain both the key 'name' and the key 'value' to be used as additional environment variables for the build."
}

variable "cache_enabled" {
  default     = "true"
  description = "If cache_enabled is true, create an S3 bucket for storing codebuild cache inside"
}

variable "cache_expiration_days" {
  default     = "7"
  description = "How many days should the build cache be kept."
}

variable "cache_bucket_suffix_enabled" {
  default     = "true"
  description = "The cache bucket generates a random 13 character string to generate a unique bucket name. If set to false it uses terraform-null-label's id value"
}

# variable "project" {}

variable "environment" {}

variable "vpcid" {}

variable "subnet1" {}

variable "subnet2" {}

variable "securitygroupid" {}

variable "image_version_tag" {}

variable "services" { type = "list" }

variable "count" {}

variable "s3ObjectKey" { type = "list" }
