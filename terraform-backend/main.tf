terraform {
	backend "s3" {
		# 이전에 생성한 버킷 이름으로 변경
		bucket 	 = "terraform-up-and-running-state-kkoon9" 
		key 	   = "global/s3/terraform.tfstate"
	  region   = "ap-northeast-2"

		# 이전에 생성한 다이나모DB 테이블 이름으로 변경
		dynamodb_table = "terraform-up-and-running-locks"
		encrypt 			 = true
	}
}

provider "aws" {
  region  = "ap-northeast-2"
}

resource "aws_s3_bucket" "terraform_state" {
	bucket = "terraform-up-and-running-state-kkoon9"

	# 실수로 S3 버킷을 삭제하는 것을 방지합니다.
	lifecycle {
		prevent_destroy = true
	}
	
	# 코드 이력을 관리하기 위해 상태 파일의 버전 관리를 활성화합니다.
	versioning {
		enabled = true
	}

	# 서버 측 암호화를 활성화합니다.
	server_side_encryption_configuration {
		rule {
			apply_server_side_encryption_by_default {
				sse_algorithm = "AES256"
			}
		}
	}
}

resource "aws_dynamodb_table" "terraform_locks" {
	name 				 = "terraform-up-and-running-locks"
	billing_mode = "PAY_PER_REQUEST"
	hash_key 		 = "LockID"

	attribute {
		name = "LockID"
		type = "S"
	}
}

output "s3_bucket_arn" {
	value 			= aws_s3_bucket.terraform_state.arn
	description = "The ARN of the S3 bucket"
}

output "dynamodb_table_name" {
	value 			= aws_dynamodb_table.terraform_locks.name
	description = "The name of the DynamoDB table"	
}