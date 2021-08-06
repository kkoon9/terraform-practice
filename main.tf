terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

data "aws_vpc" "default" {
	default = true
}

data "aws_subnet_ids" "default" {
	vpc_id = data.aws_vpc.default.id
}

provider "aws" {
  profile = "default"
  region  = "ap-northeast-2"
}

resource "aws_security_group" "instance" {
	name = "terraform-example-instacne"

	ingress {
		from_port = var.server_port
		to_port = var.server_port
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
}
resource "aws_instance" "example" {
	ami               = "ami-0ba5cd124d7a79612"
	instance_type     = "t2.micro"
	vpc_security_group_ids = [aws_security_group.instance.id]
	user_data = <<-EOF
								#!/bin/bash
								echo "Hello, World" > index.html
								nohup busybox httpd -f -p ${var.server_port} &
								EOF

	tags = {
		Name = "terraform-example"
	}
}

resource "aws_launch_configuration" "example" {
	image_id           = "ami-0ba5cd124d7a79612"
	instance_type			 = "t2.micro"

	security_groups    = [aws_security_group.instance.id]
	
	user_data = <<-EOF
								#!/bin/bash
								echo "Hello, World" > index.html
								nohup busybox httpd -f -p ${var.server_port} &
								EOF	

	# ASG에서 시작 구성을 사용할 때 필요합니다.
	lifecycle {
		create_before_destroy = true
	}							
}

resource "aws_autoscaling_group" "example" {
	launch_configuration = aws_launch_configuration.example.name
	vpc_zone_identifier      = data.aws_subnet_ids.default.ids

	min_size = 2
	max_size = 10

	tag {
		key 								= "Name"
		value 							= "terraform-asg-example"
		propagate_at_launch = true
	}
}

resource "aws_lb" "example" {
		name 							 = "terraform-alb-example"
		load_balancer_type = "application"
		subnets 					 = data.aws_subnet_ids.default.ids
}

output "public_ip" {
  value       = aws_instance.example.public_ip
  description = "The public IP address of the web server" 
}