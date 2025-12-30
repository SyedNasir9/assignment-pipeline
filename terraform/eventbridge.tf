resource "aws_iam_role" "eventbridge" {
  name = "eventbridge-invoke-ecs"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "events.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy" "eventbridge_policy" {
  name = "eventbridge-ecs-runpolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:RunTask",
          "iam:PassRole",
          "ecs:StopTask"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_event" {
  role = aws_iam_role.eventbridge.name
  policy_arn = aws_iam_policy.eventbridge_policy.arn
}

resource "aws_cloudwatch_event_rule" "daily" {
  name = "assignment-daily-run"
  schedule_expression = "rate(1 day)"   # runs once every 24 hours
  description = "Daily trigger for ECS task to generate report"
}

resource "aws_cloudwatch_event_target" "run_task" {
  rule = aws_cloudwatch_event_rule.daily.name
  role_arn = aws_iam_role.eventbridge.arn
  arn = aws_ecs_cluster.cluster.arn

  ecs_target {
    task_definition_arn = aws_ecs_task_definition.task.arn
    task_count = 1
    launch_type = "FARGATE"
    network_configuration {
      subnets = data.aws_subnet_ids.default.ids
      security_groups = [aws_security_group.ecs_sg.id]
      assign_public_ip = true
    }
    platform_version = "LATEST"
  }
}
