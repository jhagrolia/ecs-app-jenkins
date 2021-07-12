provider "aws" {
    profile = "default"
    region = "ap-south-1"
}

data "aws_ecs_cluster" "ecs_cluster" {
  cluster_name = "cluster1"
}

resource "aws_ecs_task_definition" "web_cont" {
  family = "webcont"
  container_definitions = jsonencode([
    {
      name      = "httpd"
      image     = "${var.image_name}"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    },
  ])
}

resource "aws_ecs_service" "web_svc" {
  name            = "webservice"
  cluster         = data.aws_ecs_cluster.ecs_cluster.arn
  task_definition = aws_ecs_task_definition.web_cont.arn
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.foo.arn
    container_name   = "httpd"
    container_port   = 80
  }
}