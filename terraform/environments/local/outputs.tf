output "lambda_arn" {
  value = module.lambda.function_arn
}

output "lambda_function_name" {
  value = module.lambda.function_name
}

output "ecs_cluster_arn" {
  value = module.ecs_fargate.cluster_arn
}

output "ecs_task_definition_arn" {
  value = module.ecs_fargate.task_definition_arn
}

output "stepfunctions_state_machine_arn" {
  value = module.stepfunctions.state_machine_arn
}
