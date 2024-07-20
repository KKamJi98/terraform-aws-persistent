resource "aws_iam_group" "example" {
  name = var.group_name

  lifecycle {
    ignore_changes = [name]
  }
}

resource "aws_iam_user" "example" {
  for_each      = toset(var.user_names)
  name          = each.value
  force_destroy = true
  path          = var.user_path
}

resource "aws_iam_group_membership" "example" {
  name  = var.membership_name
  users = [for user in aws_iam_user.example : user.name]
  group = aws_iam_group.example.name
}

resource "aws_iam_policy_attachment" "example" {
  name       = "${var.group_name}-admin-policy-attachment"
  groups     = [aws_iam_group.example.name]
  policy_arn = "arn:aws:iam::393035689023:policy/exam-master-user-policy"
}

resource "aws_iam_user_login_profile" "example" {
  for_each                = aws_iam_user.example
  user                    = each.key
  pgp_key                 = var.pgp_key
  password_reset_required = true
}

locals {
  encrypted_password_map        = { for user, profile in aws_iam_user_login_profile.example : user => profile.encrypted_password }
  encrypted_password            = join("", values(local.encrypted_password_map))
  pgp_key_is_keybase            = length(regexall("keybase:", var.pgp_key)) > 0 ? true : false
  formatted_decrypted_passwords = { for user, pass in local.encrypted_password_map : user => "echo ${pass} | base64 --decode | keybase pgp decrypt" }
}
