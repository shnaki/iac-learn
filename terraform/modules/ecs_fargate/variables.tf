variable "project_name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "task_family" {
  type    = string
  default = "hello-fargate"
}

variable "container_name" {
  type    = string
  default = "hello-fargate"
}

variable "container_image" {
  type = string
}
