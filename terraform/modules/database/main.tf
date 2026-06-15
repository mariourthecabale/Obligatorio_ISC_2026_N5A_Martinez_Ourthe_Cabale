## RDS MySQL

resource "aws_db_instance" "rds" {

  identifier = "db-${lower(var.name)}"
 
  engine         = var.db_engine

  engine_version = var.db_engine_version

  instance_class = var.db_instance_class
 
  allocated_storage     = var.allocated_storage

  max_allocated_storage = var.max_allocated_storage

  storage_type          = var.storage_type

  storage_encrypted     = true
 
  db_name  = var.db_name

  username = var.db_username

  password = var.db_password
 
  port = var.db_port
 
  db_subnet_group_name   = aws_db_subnet_group.rds.name

  vpc_security_group_ids = [var.rds_security_group_id]
 
  publicly_accessible = false

  multi_az            = var.multi_az
 
  backup_retention_period = var.backup_retention_period

  backup_window           = var.backup_window

  maintenance_window      = var.maintenance_window
 
  skip_final_snapshot       = var.skip_final_snapshot

  final_snapshot_identifier = var.skip_final_snapshot ? null : "final-snapshot-${lower(var.name)}"
 
  deletion_protection = var.deletion_protection
 
  auto_minor_version_upgrade = true
 
  tags = {

    Name = "AWS-${var.name}-RDS"

  }

}
 

resource "aws_db_subnet_group" "rds" {

  name = "db-subnet-group-${lower(var.name)}"

  subnet_ids = var.private_db_subnet_ids

  tags = {
    Name = "AWS-${var.name}-DBSubnetGroup"
  }

}