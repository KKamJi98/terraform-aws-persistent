variable "identifier" {
  description = "name for rds"
  type        = string
}


variable "vpc_security_group_ids" {
  description = "vpc_sg for using rds"
  type        = set(string)
}



variable "name" {
  type        = string
  description = "name for rds db_subnet_group"
}


variable "skip_final_snapshot" {
  type        = bool
  description = "choose maintain snapshot or not"
}

variable "subnet_ids" {
  type        = list(string)
  description = "private subnet for rds"
}

variable "availability_zone" {
  type        = string
  description = "availability_zone for rds"
}