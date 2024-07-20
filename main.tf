# IAM User, User Group 생성
data "aws_ssm_parameter" "user_password" {
  name            = "exam_master_iam_user_password"
  with_decryption = true
}

module "dev_group" {
  source          = "./modules/iam_group_membership"
  group_name      = "weasel-dev-group"
  membership_name = "weasel-dev-group-membership"
  user_names      = ["ksm", "ysm", "jsc"]
  user_path       = "/weasel/dev/"
  pgp_key         = var.pgp_key
}

module "infra_group" {
  source          = "./modules/iam_group_membership"
  group_name      = "weasel-infra-group"
  membership_name = "weasel-infra-group-membership"
  user_names      = ["ktj", "csb", "asm"]
  user_path       = "/weasel/infra/"
  pgp_key         = var.pgp_key
}

# AWS CLI를 사용하여 ssm에 저장되어있는 비밀번호를 설정
# resource "null_resource" "set_passwords" {
#   provisioner "local-exec" {
#     command = <<EOT
#       aws iam create-login-profile --user-name ksm --password '${data.aws_ssm_parameter.user_password.value}' --password-reset-required
#       aws iam create-login-profile --user-name ysm --password '${data.aws_ssm_parameter.user_password.value}' --password-reset-required
#       aws iam create-login-profile --user-name jsc --password '${data.aws_ssm_parameter.user_password.value}' --password-reset-required
#       aws iam create-login-profile --user-name asm --password '${data.aws_ssm_parameter.user_password.value}' --password-reset-required
#       aws iam create-login-profile --user-name ktj --password '${data.aws_ssm_parameter.user_password.value}' --password-reset-required
#       aws iam create-login-profile --user-name csb --password '${data.aws_ssm_parameter.user_password.value}' --password-reset-required
#     EOT
#   }
#   depends_on = [module.dev_group, module.infra_group]
# }

resource "null_resource" "delete_login_profiles" {
  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      aws iam delete-login-profile --user-name ksm || true
      aws iam delete-login-profile --user-name usm || true
      aws iam delete-login-profile --user-name jsc || true
      aws iam delete-login-profile --user-name asm || true
      aws iam delete-login-profile --user-name ktj || true
      aws iam delete-login-profile --user-name csb || true
    EOT
  }
}

# s3 bucket 생성
module "weasel_images_bucket" {
  source                      = "./modules/s3-bucket"
  bucket_name                 = "weasel-images"
  public_access_block_enabled = true
  bucket_policy               = "" # 정책 없음
  enable_website              = false
  tags = {
    Project = "weasel"
  }
}

module "weasel_frontend_bucket" {
  source                      = "./modules/s3-bucket"
  bucket_name                 = "weasel-frontend"
  public_access_block_enabled = true
  bucket_policy = jsonencode({
    "Version" : "2008-10-17",
    "Id" : "PolicyForCloudFrontPrivateContent",
    "Statement" : [
      {
        "Sid" : "AllowCloudFrontServicePrincipal",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudfront.amazonaws.com"
        },
        "Action" : "s3:GetObject",
        "Resource" : "arn:aws:s3:::weasel-frontend/*",
        "Condition" : {
          "StringEquals" : {
            "AWS:SourceArn" : "arn:aws:cloudfront::393035689023:distribution/EBDDD040I1O72"
          }
        }
      }
    ]
  })
  enable_website = true
  index_document = "index.html"
  error_document = "error.html"
  tags = {
    Project = "weasel"
  }
}
