output "policy_id" {
  value = aws_iam_policy.policy.id
  description = "The ID of the policy"
}

output "policy_arn" {
  value = aws_iam_policy.policy.arn
  description = "The ARN of the policy"
}

output "policy_name" {
  value = aws_iam_policy.policy.name
  description = "The name of the policy"
}

output "policy" {
  value = aws_iam_policy.policy.policy
  description = "The policy document"
}