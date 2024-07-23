output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC."
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "A list of IDs for the public subnets."
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnet_ids" {
  description = "A list of IDs for the private subnets."
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway."
  value       = aws_internet_gateway.this.id
}

output "public_route_table_id" {
  description = "The ID of the public route table."
  value       = aws_route_table.public.id
}