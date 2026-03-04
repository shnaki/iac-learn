output "ssm_parameter_arns" {
  description = "SSM パラメータの ARN マップ。"
  value       = {for k, v in aws_ssm_parameter.this : k => v.arn}
}

output "ssm_parameter_names" {
  description = "SSM パラメータ名のマップ。"
  value       = {for k, v in aws_ssm_parameter.this : k => v.name}
}
