variable "project_name" {
  type    = string
  default = "iac-learn"
}

variable "aws_region" {
  type    = string
  default = "ap-northeast-1"
}

variable "fargate_image" {
  type = string
}
