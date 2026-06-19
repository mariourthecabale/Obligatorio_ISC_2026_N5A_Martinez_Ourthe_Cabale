## Definición del proveedor de AWS
provider "aws" {
  region = var.aws_region
}

### Módulo de Networking donde se crean VPC, Subnets, Internet Gateway, NAT Gateway y Route Tables contemplando alta disponibilidad con dos AZs
module "networking" {
  source = "git::https://github.com/ISC-2026-Martinez-Ourthe-Cabale/module-networking.git"
  
  name     = "Obligatorio"
  vpc_cidr = var.vpc_cidr
  azs = [
    var.vpc_aws_az,
    var.vpc_aws_az_2
  ]
  public_subnet_cidrs = [
    var.public_subnet,
    var.public_subnet_2
  ]
  private_app_subnet_cidrs = [
    var.private_subnet_APP,
    var.private_subnet_APP_2
  ]
  private_db_subnet_cidrs = [
    var.private_subnet_DB,
    var.private_subnet_DB_2
  ]
}

## Modulo donde se crean los SG para el ALB, EC2 y RDS
module "security_groups" {
  source = "git::https://github.com/ISC-2026-Martinez-Ourthe-Cabale/module-security-groups.git"
  
  project_name   = var.project_name
  vpc_id = module.networking.vpc_id
  app_port = var.app_port
  db_port  = var.db_port
}

### Módulo de ALB donde se crea el Application Load Balancer, su Target Group y su Listener
module "alb" {
  source                = "git::https://github.com/ISC-2026-Martinez-Ourthe-Cabale/module-alb.git"
  
  name                  = "Obligatorio"
  vpc_id                = module.networking.vpc_id
  public_subnet_ids     = module.networking.public_subnet_ids
  alb_security_group_id = module.security_groups.alb_sg_id
}

## Módulo de ASG donde se crea el Auto Scaling Group y su Launch Template, utilizando la AMI y el tipo de instancia definidos en las variables, además de asociar el ASG al Target Group del ALB y al SG de EC2
module "ec2_asg" {

  source = "git::https://github.com/ISC-2026-Martinez-Ourthe-Cabale/module-asg.git"

  name = var.project_name
  ami = var.ami
  private_subnet_ids = module.networking.private_app_subnet_ids
  ec2_security_group_id = module.security_groups.ec2_sg_id
  target_group_arn = module.alb.target_group_arn
}


module "database" {
  source = "git::https://github.com/ISC-2026-Martinez-Ourthe-Cabale/module-database.git"

  name = "Obligatorio"
  private_db_subnet_ids = module.networking.private_db_subnet_ids
  rds_security_group_id = module.security_groups.rds_sg_id
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