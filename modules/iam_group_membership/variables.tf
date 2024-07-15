variable "group_name" {
  description = "The name of the IAM group."
  type        = string
}

variable "membership_name" {
  description = "The name of the IAM group membership."
  type        = string
}

variable "user_names" {
  description = "A list of IAM user names."
  type        = list(string)
}

variable "user_path" {
  description = "The path for IAM users."
  type        = string
  default     = "/"
}