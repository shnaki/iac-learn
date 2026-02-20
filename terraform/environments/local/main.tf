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
  region                      = var.aws_region
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    ec2           = var.localstack_endpoint
    ecs           = var.localstack_endpoint
    ecr           = var.localstack_endpoint
    events        = var.localstack_endpoint
    iam           = var.localstack_endpoint
    lambda        = var.localstack_endpoint
    logs          = var.localstack_endpoint
    sfn           = var.localstack_endpoint
    sts           = var.localstack_endpoint
  }
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
  source                = "../../modules/stepfunctions"
  project_name          = var.project_name
  lambda_arn            = module.lambda.function_arn
  cluster_arn           = module.ecs_fargate.cluster_arn
  task_definition_arn   = module.ecs_fargate.task_definition_arn
  subnet_ids            = module.network.subnet_ids
  security_group_ids    = module.network.security_group_ids
  ecs_execution_role_arn = module.ecs_fargate.execution_role_arn
  ecs_task_role_arn      = module.ecs_fargate.task_role_arn
}
