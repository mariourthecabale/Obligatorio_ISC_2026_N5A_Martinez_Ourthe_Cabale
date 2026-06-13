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