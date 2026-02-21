variable "project_name" {
  type = string
}

variable "function_name" {
  type = string
}

variable "source_dir" {
  type = string
}

variable "runtime" {
  type    = string
  default = "python3.12"
}

variable "handler" {
  type    = string
  default = "handler.handler"
}
