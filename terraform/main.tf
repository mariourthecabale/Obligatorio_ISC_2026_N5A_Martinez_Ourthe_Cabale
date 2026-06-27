## Definición del proveedor de AWS
provider "aws" {
  region = var.aws_region
}

### Módulo de Networking donde se crean VPC, Subnets, Internet Gateway, NAT Gateway y Route Tables contemplando alta disponibilidad con dos AZs
module "networking" {
  source = "git::ssh://git@github.com/ISC-2026-Martinez-Ourthe-Cabale/module-networking.git"

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
  source = "git::ssh://git@github.com/ISC-2026-Martinez-Ourthe-Cabale/module-security-groups.git"

  project_name = var.project_name
  vpc_id       = module.networking.vpc_id
  app_port     = var.app_port
  db_port      = var.db_port
}

### Módulo de ALB donde se crea el Application Load Balancer, su Target Group y su Listener
module "alb" {
  source = "git::ssh://git@github.com/ISC-2026-Martinez-Ourthe-Cabale/module-alb.git"

  name                  = "Obligatorio"
  vpc_id                = module.networking.vpc_id
  public_subnet_ids     = module.networking.public_subnet_ids
  alb_security_group_id = module.security_groups.alb_sg_id
}


module "database" {
  source = "git::ssh://git@github.com/ISC-2026-Martinez-Ourthe-Cabale/module-database.git"

  name                    = "Obligatorio"
  private_db_subnet_ids   = module.networking.private_db_subnet_ids
  rds_security_group_id   = module.security_groups.rds_sg_id
  db_name                 = var.db_name
  db_username             = var.db_username
  db_password             = var.db_password
  db_instance_class       = "db.t3.micro"
  allocated_storage       = 20
  multi_az                = false
  backup_retention_period = 7
  skip_final_snapshot     = false
  deletion_protection     = false
}

## Módulo de ASG donde se crea el Auto Scaling Group y su Launch Template, utilizando la AMI y el tipo de instancia definidos en las variables, además de asociar el ASG al Target Group del ALB y al SG de EC2
module "ec2_asg" {

  source = "git::ssh://git@github.com/ISC-2026-Martinez-Ourthe-Cabale/module-asg.git"

  db_host               = module.database.db_endpoint
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = var.db_password
  name                  = var.project_name
  ami                   = var.ami
  private_subnet_ids    = module.networking.private_app_subnet_ids
  ec2_security_group_id = module.security_groups.ec2_sg_id
  target_group_arn      = module.alb.target_group_arn
  gitlab_token          = var.gitlab_token
}

locals {
  app_ready_url = "${var.app_ready_check_scheme}://${module.alb.alb_dns_name}${var.app_ready_check_path}"
}

resource "null_resource" "Esperando_por_APP" {
  depends_on = [
    module.alb,
    module.ec2_asg,
  ]

  provisioner "local-exec" {
    command = <<-EOT
      for i in $(seq 1 ${var.app_ready_check_attempts}); do
        if curl --max-time ${var.app_ready_check_curl_timeout} -fsS "${local.app_ready_url}" >/dev/null 2>&1; then
          echo "App disponible en ${local.app_ready_url}"
          exit 0
        fi
        echo "Esperando por la aplicación... intento $i/${var.app_ready_check_attempts}"
        sleep ${var.app_ready_check_sleep_seconds}
      done
      echo "ERROR: APP todavia no esta disponible" >&2
      exit 1
    EOT
  }
}

##Modulo para creacion de S3
module "db_storage" {
  source = "git::ssh://git@github.com/ISC-2026-Martinez-Ourthe-Cabale/storage-backup"
  bucket_name = var.bucket_name
}

module "scripts" {
  source = "git::ssh://git@github.com/ISC-2026-Martinez-Ourthe-Cabale/scripts.git"
}

module "ec2-tmp" {
  source = "git::ssh://git@github.com/ISC-2026-Martinez-Ourthe-Cabale/modules-ec2-tmp.git"
  db_host               = module.database.db_address
  db_name               = var.db_name
  db_port               = var.db_port
  db_username           = var.db_username
  db_password           = var.db_password
  ami                   = var.ami
  private_subnet_ids    = module.networking.private_app_subnet_ids
  ec2_security_group_id = module.security_groups.ec2_sg_id
  bucket_name           = var.bucket_name

  depends_on = [
    module.db_storage
  ]
}