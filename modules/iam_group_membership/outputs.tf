output "group_name" {
  value = aws_iam_group.group.name
}

output "user_names" {
  value = [for user in aws_iam_user.user : user.name]
}
