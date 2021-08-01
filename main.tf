terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "ap-northeast-2"
}

resource "aws_instance" "example" {
	ami               = "ami-0ba5cd124d7a79612"
	instance_type     = "t2.micro"

	tags = {
		Name = "terraform-example"
	}
}