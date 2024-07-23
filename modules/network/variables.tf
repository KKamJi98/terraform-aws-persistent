variable "name" {
  type        = string
  description = "project name"
  default     = ""
}

variable "vpc_availability_zones" {
  type        = list(string)
  description = "Availability Zones"
  default     = ["us-east-1a"]
}

variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC"
  default     = "10.10.0.0/16"
}

variable "vpc_name" {
  type        = string
  description = "The name of the VPC"
  default     = ""
}

variable "public_subnet_suffix" {
  description = "Explicit values to use in the Name tag on public subnets. If empty, Name tags are generated"
  type        = string
  default     = ""
}

variable "public_subnets_cidr" {
  description = "A list of public subnet CIDR blocks for the VPC."
  type        = list(string)
  default     = []
}

variable "private_subnet_suffix" {
  description = "Explicit values to use in the Name tag on public subnets. If empty, Name tags are generated"
  type        = string
  default     = ""
}

variable "private_subnets_cidr" {
  description = "A list of public subnet CIDR blocks for the VPC."
  type        = list(string)
  default     = []
}

variable "map_public_ip_on_launch" {
  description = "Set to ture to assign a public IP to instance in the subent"
  type        = bool
  default     = false
}



variable "enable_dns_support" {
  description = "Set to true to enable DNS support for the VPC."
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Set to true to enable DNS hostnames for instances in the VPC."
  type        = bool
  default     = true
}