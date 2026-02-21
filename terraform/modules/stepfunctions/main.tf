resource "aws_iam_role" "sfn" {
  name = "${var.project_name}-sfn-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "sfn" {
  name = "${var.project_name}-sfn-policy"
  role = aws_iam_role.sfn.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = [
          var.lambda_arn,
          "${var.lambda_arn}:*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:RunTask"
        ]
        Resource = [
          var.task_definition_arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = [
          var.ecs_execution_role_arn,
          var.ecs_task_role_arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "events:PutTargets",
          "events:PutRule",
          "events:DescribeRule"
        ]
        Resource = "arn:aws:events:*:*:rule/StepFunctionsGetEventsForECSTaskRule"
      }
    ]
  })
}

resource "aws_sfn_state_machine" "this" {
  name     = "${var.project_name}-workflow"
  role_arn = aws_iam_role.sfn.arn
  definition = jsonencode({
    Comment = "Hello workflow for Lambda and Fargate"
    StartAt = "InvokeLambda"
    States = {
      InvokeLambda = {
        Type     = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = var.lambda_arn
          "Payload.$"  = "$"
        }
        Next = "RunFargateTask"
      }
      RunFargateTask = {
        Type     = "Task"
        Resource = "arn:aws:states:::ecs:runTask.sync"
        Parameters = {
          LaunchType     = "FARGATE"
          Cluster        = var.cluster_arn
          TaskDefinition = var.task_definition_arn
          NetworkConfiguration = {
            AwsvpcConfiguration = {
              Subnets        = var.subnet_ids
              SecurityGroups = var.security_group_ids
              AssignPublicIp = "ENABLED"
            }
          }
        }
        End = true
      }
    }
  })
}
