resource "aws_ssm_parameter" "this" {
  for_each = var.ssm_parameters

  name  = each.value.name
  type  = each.value.type
  value = each.value.value

  tags = {
    Project = var.project_name
  }
}
