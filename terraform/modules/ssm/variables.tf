variable "project_name" {
  type        = string
  description = "プロジェクト名（タグに使用）。"
}

variable "ssm_parameters" {
  type = map(object({
    name  = string
    type  = string
    value = string
  }))
  description = "作成する SSM パラメータのマップ。"
  default = {}
}
