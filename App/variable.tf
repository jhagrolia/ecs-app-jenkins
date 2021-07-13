variable "vpc_id" {
    type = string
    description = "(optional) describe your variable"
    default = null
}

variable "cluster_name" {
  type = string
  description = "ECS Cluster Name"
  default = "cluster1"
}

variable "task_family" {
    type = string
    description = "ECS Task Family Name"
    default = "webtask"
}

variable "image_name" {
  type = string
  description = "Image Name to Deploy"
}

variable "port" {
    type = number
    description = "Exposed Container Port, Loadbalancer/Service port"
    default = 80
}

variable "lb_protocol" {
    type = string
    description = "Loadbalancer Protocol"
    default = "HTTP"
}

variable "task_mem" {
    type = number
    description = "Memory for Task"
    default = 2048
}

variable "task_cpu" {
    type = number
    description = "CPU for Task"
    default = 1024
}

variable "desired_count" {
    type = number
    description = "Desired Replicas of Task to run"
    default = 3
}
