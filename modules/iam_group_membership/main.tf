resource "aws_iam_group" "group" {
  name = var.group_name
}

resource "aws_iam_user" "user" {
  for_each = toset(var.user_names)
  name     = each.value
  path     = var.user_path
}

resource "aws_iam_group_membership" "group_membership" {
  name  = var.membership_name
  users = [for user in aws_iam_user.user : user.name]
  group = aws_iam_group.group.name
}

resource "aws_iam_policy_attachment" "group_policy_attachment" {
  name       = "${var.group_name}-admin-policy-attachment"
  groups     = [aws_iam_group.group.name]
  policy_arn = "arn:aws:iam::393035689023:policy/exam-master-user-policy"
}