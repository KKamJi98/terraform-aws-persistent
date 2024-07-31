data "terraform_remote_state" "dynamic" {
  backend = "s3"

  config = {
    bucket = "terraform-state-weasel"
    key    = "dynamic/terraform.tfstate"
    region = "us-east-1"
  }
}

# network 생성
module "network" {
  source                  = "./modules/network"
  vpc_availability_zones  = ["us-east-1a", "us-east-1b", "us-east-1c"]
  name                    = "weasel"
  vpc_cidr                = "10.10.0.0/16"
  vpc_name                = "weasel-vpc"
  public_subnet_suffix    = "weasel-public-subnet"
  public_subnets_cidr     = ["10.10.100.0/24", "10.10.110.0/24", "10.10.120.0/24"]
  private_subnet_suffix   = "weasel-private-subnet"
  private_subnets_cidr    = ["10.10.200.0/24", "10.10.210.0/24", "10.10.220.0/24"]
  map_public_ip_on_launch = true
  enable_dns_support      = true
  enable_dns_hostnames    = true
  enable_nat_instance     = true
  nat_instance_network_interface_id = data.terraform_remote_state.dynamic.outputs.bastion_host_network_interface_id
}


# IAM User, User Group 생성
module "dev_group" {
  source          = "./modules/iam_group_membership"
  group_name      = "weasel-dev-group"
  membership_name = "weasel-dev-group-membership"
  user_names      = ["ksm", "ysm", "jsc"]
  user_path       = "/weasel/dev/"
  pgp_key         = var.pgp_key
  policy_file     = "${path.module}/template/dev-policy.json"
}

module "infra_group" {
  source          = "./modules/iam_group_membership"
  group_name      = "weasel-infra-group"
  membership_name = "weasel-infra-group-membership"
  user_names      = ["ktj", "csb", "asm"]
  user_path       = "/weasel/infra/"
  pgp_key         = var.pgp_key
  policy_file     = "${path.module}/template/infra-policy.json"
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

module "weasel_backend_ecr" {
  source = "./modules/ecr"
  name   = "weasel-backend"
}

module "weasel_frontend_ecr" {
  source = "./modules/ecr"
  name   = "weasel-frontend"
}

# security group 생성
module "bastion_security_group" {
  source                     = "./modules/security_group"
  security_group_name        = "weasel-bastion-sg"
  security_group_description = "Security group for the bastion host"
  vpc_id                     = module.network.vpc_id
  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  # tags = {
  #   Environment = "development"
  # }
}

module "web_security_group" {
  source                     = "./modules/security_group"
  security_group_name        = "weasel-web-sg"
  security_group_description = "Security group for the web"
  vpc_id                     = module.network.vpc_id
  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

module "rds_security_group" {
  source                     = "./modules/security_group"
  security_group_name        = "weasel-rds-sg"
  security_group_description = "security group for rds"
  vpc_id                     = module.network.vpc_id
  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 53306
      to_port     = 53306
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

}

# RDS 생성
module "weasel_rds" {
  source                 = "./modules/rds"
  identifier             = "weasel-rds"
  vpc_security_group_ids = [module.rds_security_group.security_group_id]
  subnet_group_name      = "db-subnet-group"
  subnet_ids             = module.network.private_subnet_ids
  skip_final_snapshot    = true
  availability_zone      = "us-east-1a"
}


# data "aws_ssm_parameter" "user_password" {
#   name            = "exam_master_iam_user_password"
#   with_decryption = true
# }
