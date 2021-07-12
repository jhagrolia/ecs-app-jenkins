provider "aws" {
    profile = "default"
    region = "ap-south-1"
}

variable "cluster_name" {
    type = string
    description = "ECS Cluster Name"
    default = "cluster1"
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.cluster_name
}