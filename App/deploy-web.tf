provider "aws" {
    profile = "default"
    region = "ap-south-1"
}

variable "image_name" {
  type = string
  description = "Image Name to Deploy"
}

data "aws_ecs_cluster" "ecs_cluster" {
  cluster_name = "cluster1"
}

resource "aws_ecs_task_definition" "web_task" {
  family = "webtask"
  requires_compatibilities = ["FARGATE"]
  memory = 1024
  cpu = 512
  network_mode = "awsvpc"
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

data "aws_vpc" "default" {
  filter {
    name = "isDefault"
    values = ["true"]
  }
}

data "aws_subnet_ids" "subnets" {
  vpc_id = data.aws_vpc.default.id
}

resource "aws_security_group" "alb_sg" {
  name = "ecs-lb-sg"
  description = "Security Group for ALB for ECS Service"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "web_lb" {
  name = "ecs-web-lb"
  subnets = data.aws_subnet_ids.subnets.ids
  security_groups = [aws_security_group.alb_sg.id]
}

resource "aws_lb_target_group" "web_lb_tg" {
  name = "ecs-web-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default.id
  target_type = "ip"

  health_check {
    healthy_threshold = "3"
    interval = "30"
    protocol = "HTTP"
    matcher = "200"
    timeout = "3"
    path = "/index.html"
    unhealthy_threshold = "2"
  }
}

resource "aws_lb_listener" "web_lb_listener" {
  load_balancer_arn = aws_lb.web_lb.id
  port = 80
  protocol = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.web_lb_tg.id
    type = "forward"
  }
}

resource "aws_ecs_service" "web_svc" {
  name            = "webservice"
  launch_type = "FARGATE"
  cluster         = data.aws_ecs_cluster.ecs_cluster.arn
  task_definition = aws_ecs_task_definition.web_task.arn
  desired_count   = 3

  load_balancer {
    target_group_arn = aws_lb_target_group.web_lb_tg.id
    container_name   = "httpd"
    container_port   = 80
  }
}
