locals {
  # 변수 사용
  # zipmap -> https://developer.hashicorp.com/terraform/language/functions/zipmap
  public_subnet_cidrs  = var.public_subnets_cidr
  private_subnet_cidrs = var.private_subnets_cidr
  public_subnet_names  = zipmap(local.public_subnet_cidrs, [for i in range(length(local.public_subnet_cidrs)) : "${var.public_subnet_suffix}-${i + 1}"])
  private_subnet_names = zipmap(local.private_subnet_cidrs, [for i in range(length(local.private_subnet_cidrs)) : "${var.private_subnet_suffix}-${i + 1}"])
  # public_subnet_cidrs = [
  #   "10.10.100.0/24",
  #   "10.10.110.0/24",
  #   "10.10.120.0/24"
  # ]

  # private_subnet_cidrs = [
  #   "10.10.200.0/24",
  #   "10.10.210.0/24",
  #   "10.10.220.0/24"
  # ]
}

###############################################################
# vpc
###############################################################
resource "aws_vpc" "this" {
  # 재사용이 가능 하도록 하기 위해 cidr 변수 선언
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = {
    Name = var.vpc_name
  }
}

###############################################################
# Subnets
###############################################################

# public_subnet -> public (의미 중복 피함)
resource "aws_subnet" "public" {
  for_each                = { for idx, cidr in local.public_subnet_cidrs : idx => cidr }
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = element(var.vpc_availability_zones, each.key % length(var.vpc_availability_zones))
  map_public_ip_on_launch = var.map_public_ip_on_launch
  tags = {
    Name = "${var.public_subnet_suffix}-${each.key + 1}"
  }
}

resource "aws_subnet" "private" {
  for_each          = { for idx, cidr in local.private_subnet_cidrs : idx => cidr }
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = element(var.vpc_availability_zones, each.key % length(var.vpc_availability_zones))
  tags = {
    Name = "${var.private_subnet_suffix}-${each.key + 1}"
  }
}

###############################################################
# EIP
###############################################################
resource "aws_eip" "nat" {
  domain = "vpc"

  depends_on = [aws_internet_gateway.this]
}
###############################################################
# Internet_Gateway & NAT_Gateway
###############################################################

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.name}-internet-gateway"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = values(aws_subnet.public)[0].id # 첫 번째 퍼블릭 서브넷에 NAT Gateway 생성

  tags = {
    Name = "${var.name}-nat-gateway"
  }

  depends_on = [aws_internet_gateway.this]
}

###############################################################
# route_talbe
###############################################################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.public_subnet_suffix}-route-table"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name = "${var.private_subnet_suffix}-route-table"
  }
}

resource "aws_route_table_association" "public_route_table_association" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_route_table_association" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}