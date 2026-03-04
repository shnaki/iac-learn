project_name  = "iac-learn"
aws_region    = "ap-northeast-1"
fargate_image = "iac-learn/fargate:local"

ssm_parameters = {
  db_host = {
    name  = "/iac-learn/db/host"
    type  = "String"
    value = "localhost"
  }
  db_port = {
    name  = "/iac-learn/db/port"
    type  = "String"
    value = "5432"
  }
  db_password = {
    name  = "/iac-learn/db/password"
    type  = "SecureString"
    value = "dev-password-localstack"
  }
  api_key = {
    name  = "/iac-learn/api/key"
    type  = "SecureString"
    value = "dev-api-key-localstack"
  }
  api_endpoint = {
    name  = "/iac-learn/api/endpoint"
    type  = "String"
    value = "https://api.example.com/v1"
  }
  app_log_level = {
    name  = "/iac-learn/app/log_level"
    type  = "String"
    value = "DEBUG"
  }
  app_feature_flag = {
    name  = "/iac-learn/app/feature_flag"
    type  = "String"
    value = "true"
  }
}
