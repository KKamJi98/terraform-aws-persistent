# SSM Parameter Store에서 비밀번호를 가져옴
data "aws_ssm_parameter" "user_password" {
  name            = "exam_master_iam_user_password"
  with_decryption = true
}

module "dev_group" {
  source          = "./modules/iam_group_membership"
  group_name      = "dev-group"
  membership_name = "dev-group-membership"
  user_names      = ["ksm", "usm", "jsc"]
  user_path       = "/exam-master/dev/"
}

module "infra_group" {
  source          = "./modules/iam_group_membership"
  group_name      = "infra-group"
  membership_name = "infra-group-membership"
  user_names      = ["ktj", "csb", "asm"]
  user_path       = "/exam-master/infra/"
}

# AWS CLI를 사용하여 비밀번호를 설정하는 null_resource
resource "null_resource" "set_passwords" {
  provisioner "local-exec" {
    command = <<EOT
      aws iam create-login-profile --user-name ksm --password '${data.aws_ssm_parameter.user_password.value}' --password-reset-required
      aws iam create-login-profile --user-name usm --password '${data.aws_ssm_parameter.user_password.value}' --password-reset-required
      aws iam create-login-profile --user-name jsc --password '${data.aws_ssm_parameter.user_password.value}' --password-reset-required
      aws iam create-login-profile --user-name asm --password '${data.aws_ssm_parameter.user_password.value}' --password-reset-required
      aws iam create-login-profile --user-name ktj --password '${data.aws_ssm_parameter.user_password.value}' --password-reset-required
      aws iam create-login-profile --user-name csb --password '${data.aws_ssm_parameter.user_password.value}' --password-reset-required
    EOT
  }
  depends_on = [module.dev_group, module.infra_group]
}

resource "null_resource" "delete_login_profiles" {
  triggers = {
    always_run = "${timestamp()}"
  }

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