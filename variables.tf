
variable "aws_account" {default = "672985825598"}
variable "aws_region" {default = "us-east-1"}
variable "env" {default = "test"}
variable "elastic_instance_size" {default = "t2.medium.elasticsearch"}
variable "az_count" {default = 2}
variable "vpc_cidr" {default = "10.20.0.0/16"}
variable "vpc_id" {default = "vpc-727b9214"}
variable "public_subnet_ids" {default = ["subnet-e258eccf","subnet-fd268df2"]}
variable "private_subnet_ids" {default = ["subnet-63f28f2a","subnet-7e109725"]}
variable "db_subnet_group_name" {default = "dev-trust-db-subnet-group"}
variable "services" {
  type = "list"
  default = [
    "approvals",
    "authorization",
    "clinconnectbridge",
    "clinpointbridge-cvops",
    "emailgateway",
    "eventdateconfig",
    "feedservice",
    "mappingrules-cvops",
    "messagebroker",
    "multitenant",
    "storageservice",
    "studyconfiguration",
    "studyevent-cvops",
    "transformevents",
    "uiservice",
    "clinfeedui"
  ]
}

variable "healthpath" {
  type = "list"
  default = [
    "/api/approvals/health",
    "/api/AuthorizationsService/health",
    "/api/ClinConnectBridgeService",
    "/api/ClinPointBridge/testConnection",
    "/api/emailgatewayservice",
    "/api/EventDateConfig/health",
    "/api/feedstore/health",
    "/api/mappingrules?studyid=",
    "/api/messagebroker/queues",
    "/api/MultiTenant/health",
    "/api/storageservice/health",
    "/api/StudyConfigurationService/health",
    "/api/StudyEventsService/health",
    "/api/TransformEventsService/health",
    "/api/uiservice/health",
    "/"
  ]
}

variable "host_port" {
  type = "list"
  default = [
    "9000",  # approval
    "7080",  # authorization
    "5800",  # clinconnectbridge
    "5702",  # clinpointbridge-cvops
    "7098",  # emailgateway
    "5400",  # eventdateconfig
    "7000",  # feedservice
    "5502",  # mappingrules-cvops
    "5000",  # messagebroker
    "7900",  # multitenant
    "3000",  # storageservice
    "7070",  # studyconfiguration
    "5602",  # studyevent-cvops
    "7050",  # transformevents
    "7095",   # uiservice
    "4200"    # clinfeeduiservice
  ]
}

variable "container_port" {
  type = "list"
  default = [
    "9000",  # approval
    "7080",  # authorization
    "5800",  # clinconnectbridge
    "5700",  # clinpointbridge-cvops
    "7098",  # emailgateway
    "5400",  # eventdateconfig
    "7000",  # feedservice
    "5500",  # mappingrules-cvops
    "5000",  # messagebroker
    "7900",  # multitenant
    "3000",  # storageservice
    "7070",  # studyconfiguration
    "5600",  # studyevent-cvops
    "7050",  # transformevents
    "7095",   # uiservice
    "4200"   # clinfeeduiservice
  ]
}

variable "s3ObjectKey" {
  type = "list"
  default = [
    "approvals",
    "authorization",
    "clinconnectbridge",
    "clinpointbridge",
    "clinpointbridge",
    "emailgateway",
    "eventdateconfig",
    "feedservice",
    "MappingRules",
    "MappingRules",
    "messagebroker",
    "multitenant",
#    "scheduleworkerrole",
    "storageservice",
    "studyconfiguration",
    "studyevent",
    "studyevent",
    "transformevents",
    "clinfeedui",
    "uiservice",
    "clinfeeduiservice"
  ]
}

variable "stream_function_name" {default = "LogsToElasticsearch-ClinFeed"}
//variable "root_domain" {default = "goinmo.com"}
