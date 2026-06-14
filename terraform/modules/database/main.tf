## Main para crear la base de datos RDS utilizando el módulo database.
module "database" {
  source = "./modules/database"

  name = "Obligatorio"

  private_db_subnet_ids = module.networking.private_db_subnet_ids
  rds_security_group_id = module.security_groups.rds_security_group_id

  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password

  db_instance_class = "db.t3.micro"
  allocated_storage = 20

  multi_az = false

  backup_retention_period = 7
  skip_final_snapshot     = false
  deletion_protection     = false
}