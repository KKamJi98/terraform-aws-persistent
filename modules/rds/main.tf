#rds subnet group 생성
resource "aws_db_subnet_group" "this" {
  name       = var.subnet_group_name
  subnet_ids = var.subnet_ids
}

#rds instance 생성
resource "aws_db_instance" "this" {
  identifier             = var.identifier
  allocated_storage      = 10
  engine                 = "mysql"
  instance_class         = "db.t4g.micro"
  username               = local.rds_username
  password               = local.rds_password
  availability_zone      = var.availability_zone
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.vpc_security_group_ids
  skip_final_snapshot    = var.skip_final_snapshot
  publicly_accessible    = true

}

data "aws_secretsmanager_secret" "rds_login" {
  name = "mysql"
}

data "aws_secretsmanager_secret_version" "rds_password" {
  secret_id = data.aws_secretsmanager_secret.rds_login.id
}

data "aws_secretsmanager_secret_version" "rds_username" {
  secret_id = data.aws_secretsmanager_secret.rds_login.id
}

locals {
  rds_username = jsondecode(data.aws_secretsmanager_secret_version.rds_username.secret_string)["USERNAME"]
  rds_password = jsondecode(data.aws_secretsmanager_secret_version.rds_password.secret_string)["PASSWORD"]
}