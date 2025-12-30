resource "aws_ecs_cluster" "cluster" {
  name = "assignment-cluster"
}

resource "aws_cloudwatch_log_group" "app" {
  name = "/ecs/assignment"
  retention_in_days = 14
}

resource "aws_security_group" "ecs_sg" {
  name = "ecs-sg-assignment"
  vpc_id = data.aws_vpc.default.id
  description = "SG for Fargate tasks - allow egress"
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = []
  }
}

# Task Definition - note: image will be set via var in the second terraform apply
variable "ecr_image" {
  type = string
  default = ""
}

resource "aws_ecs_task_definition" "task" {
  family = "assignment-processor"
  cpu = "256"
  memory = "512"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  task_role_arn = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([{
    name  = "processor"
    image = var.ecr_image
    essential = true
    environment = [
      { name = "RAW_BUCKET", value = aws_s3_bucket.raw.bucket },
      { name = "REPORT_BUCKET", value = aws_s3_bucket.reports.bucket },
      { name = "AWS_REGION", value = var.aws_region }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group = aws_cloudwatch_log_group.app.name
        awslogs-region = var.aws_region
        awslogs-stream-prefix = "processor"
      }
    }
  }])
}
