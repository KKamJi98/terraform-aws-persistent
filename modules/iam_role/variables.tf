variable "role_name" {
  description = "The name of the IAM role"
  type        = string
}

variable "assume_role_policy" {
  description = "The assume role policy document"
  type        = string
}

variable "policy_arns" {
  description = "A list of policy ARNs to attach to the role"
  type        = list(string)
  default     = []
}
