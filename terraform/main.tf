## Definición del proveedor de AWS
provider "aws" {
  region = var.aws_region
}

### Módulo de Networking donde se crean VPC, Subnets, Internet Gateway, NAT Gateway y Route Tables contemplando alta disponibilidad con dos AZs
module "networking" {
  source = "./modules/networking"

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

module "ec2_asg" {

  source = "../../modules/ec2_asg"

  name = var.name

  ami_id = var.ami_id

  private_subnet_ids = module.vpc.private_app_subnet_ids

  ec2_security_group_id = module.security_groups.ec2_sg_id

  target_group_arn = module.alb.target_group_arn
}