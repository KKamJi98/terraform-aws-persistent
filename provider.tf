terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0" # 원하는 버전 명시
    }
  }
}

provider "aws" {
  region = "us-east-1"
}