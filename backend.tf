terraform {
  backend "s3" {
    bucket         = "terraform-state-exam-master"
    key            = "iam_group_membership/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}
