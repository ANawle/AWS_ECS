provider "aws" {
  region = "ap-south-1"  # Adjust your region
}
resource "aws_ecs_cluster" "example" {
  name = "example-cluster"
}

resource "aws_ecs_task_definition" "example" {
  family                   = "example-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "arn:aws:iam::992382549591:role/ecsTaskExecutionRoleAvinash" # Replace with your ECS execution role ARN

  container_definitions = jsonencode([{
    name      = "example-container"
    image     = "nginx:latest" # Replace with your container image
    essential = true
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
  }])
}

resource "aws_ecs_service" "example" {
  name            = "example-service"
  cluster         = aws_ecs_cluster.example.id
  task_definition = aws_ecs_task_definition.example.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = ["subnet-12345678"]  # Replace with your subnet IDs
    security_groups = ["subnet-0096e4805ecebb1f8"]  # Replace with your security group ID
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = "arn:aws:elasticloadbalancing:ap-south-1:992382549591:targetgroup/Avitg/76d56b76b4fd56a6"  # Replace with your ALB Target Group ARN
    container_name   = "example-container"
    container_port   = 80
  }
}

resource "spacelift_stack" "example" {
  name     = "example-stack"
  workspace = "my-spacelift-workspace"

  terraform {
    version = "latest"  # Specify your desired Terraform version
    settings {
      backend = "s3"
      config = {
        bucket = "your-terraform-backend-bucket"
        key    = "example/terraform.tfstate"
        region = "ap-south-1"
      }
    }
  }

  applies_to = [aws_ecs_service.example]

  trigger {
    on_change = true
  }

  lifecycle {
    ignore_changes = [
      # List attributes to ignore during Terraform plan and apply
      aws_ecs_service.example.desired_count
    ]
  }
}
