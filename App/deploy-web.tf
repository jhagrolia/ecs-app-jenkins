data "aws_ecs_cluster" "ecs_cluster" {
  cluster_name = var.cluster_name
}

resource "aws_ecs_task_definition" "web_task" {
  family = var.task_family
  requires_compatibilities = ["FARGATE"]
  memory = var.task_mem
  cpu = var.task_cpu
  network_mode = "awsvpc"
  container_definitions = jsonencode([
    {
      name      = "${var.task_family}Cont"
      image     = "${var.image_name}"
      essential = true
      portMappings = [
        {
          containerPort = "${var.port}"
          hostPort      = "${var.port}"
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
  vpc_id = var.vpc_id == null ? data.aws_vpc.default.id : var.vpc_id
}

resource "aws_security_group" "alb_sg" {
  name = "ecs-lb-sg"
  description = "Security Group for ALB for ECS Service"
  vpc_id = var.vpc_id == null ? data.aws_vpc.default.id : var.vpc_id

  ingress {
    from_port = var.port
    to_port = var.port
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

resource "aws_security_group" "service_sg" {
  name = "ecs-service-sg"
  description = "Security Group for ECS Service"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port = var.port
    to_port = var.port
    protocol = "tcp" 
    security_groups = [aws_security_group.alb_sg.id]
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
  port = var.port
  protocol = var.lb_protocol
  vpc_id = var.vpc_id == null ? data.aws_vpc.default.id : var.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold = "3"
    interval = "30"
    protocol = var.lb_protocol
    matcher = "200"
    timeout = "3"
    path = "/index.html"
    unhealthy_threshold = "2"
  }
}

resource "aws_lb_listener" "web_lb_listener" {
  load_balancer_arn = aws_lb.web_lb.id
  port = var.port
  protocol = var.lb_protocol

  default_action {
    target_group_arn = aws_lb_target_group.web_lb_tg.id
    type = "forward"
  }
}

resource "aws_ecs_service" "web_svc" {
  name            = "webservice"
  launch_type     = "FARGATE"
  cluster         = data.aws_ecs_cluster.ecs_cluster.arn
  task_definition = aws_ecs_task_definition.web_task.arn
  desired_count   = var.desired_count

  network_configuration {
    security_groups = [aws_security_group.service_sg.id]
    subnets = data.aws_subnet_ids.subnets.ids
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.web_lb_tg.id
    container_name   = "${var.task_family}Cont"
    container_port   = var.port
  }
}
