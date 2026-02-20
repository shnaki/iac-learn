terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.5"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "network" {
  source       = "../../modules/network"
  project_name = var.project_name
}

module "lambda" {
  source        = "../../modules/lambda"
  project_name  = var.project_name
  function_name = "${var.project_name}-hello-lambda"
  source_dir    = "${path.root}/../../../src/lambda"
}

module "ecs_fargate" {
  source          = "../../modules/ecs_fargate"
  project_name    = var.project_name
  aws_region      = var.aws_region
  task_family     = "${var.project_name}-hello-fargate"
  container_name  = "hello-fargate"
  container_image = var.fargate_image
}

module "stepfunctions" {
  source                 = "../../modules/stepfunctions"
  project_name           = var.project_name
  lambda_arn             = module.lambda.function_arn
  cluster_arn            = module.ecs_fargate.cluster_arn
  task_definition_arn    = module.ecs_fargate.task_definition_arn
  subnet_ids             = module.network.subnet_ids
  security_group_ids     = module.network.security_group_ids
  ecs_execution_role_arn = module.ecs_fargate.execution_role_arn
  ecs_task_role_arn      = module.ecs_fargate.task_role_arn
}
