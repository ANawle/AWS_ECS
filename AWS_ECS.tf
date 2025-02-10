terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.86.0"
    }
    spacelift = {
      source = "spacelift-io/spacelift"
    }
  }
}

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
  execution_role_arn       = "arn:aws:iam::992382549591:role/ecsTaskExecutionRoleAvinash"  # Replace with your ECS execution role ARN

  container_definitions = jsonencode([{
    name      = "example-container"
    image     = "nginx:latest"  # Replace with your container image
    essential = true
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
  }])
}

resource "aws_lb_target_group" "example" {
  name     = "Avitg1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-0b25f7ef0f18ee5ef"  # Replace with your VPC ID
  target_type = "ip"  # Ensure this is set to 'ip' for Fargate

  health_check {
    path = "/"
    port = "traffic-port"
    protocol = "HTTP"
  }
}

resource "aws_ecs_service" "example" {
  name            = "example-service"
  cluster         = aws_ecs_cluster.example.id
  task_definition = aws_ecs_task_definition.example.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = ["subnet-05850df941d39044a"]  # Replace with your subnet IDs
    security_groups = ["sg-0d988d042b4944b58"]  # Replace with your security group ID
    assign_public_ip = true
  }
  # Ensure the GitHub App has proper access to the repository.
}
