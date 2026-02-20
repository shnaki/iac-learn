variable "project_name" {
  type    = string
  default = "iac-learn"
}

variable "aws_region" {
  type    = string
  default = "ap-northeast-1"
}

variable "localstack_endpoint" {
  type    = string
  default = "http://localstack:4566"
}

variable "fargate_image" {
  type    = string
  default = "iac-learn/fargate:local"
}
