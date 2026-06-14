## Creamos VPC
resource "aws_vpc" "VPC-Obligatorio" {
  cidr_block           = var.vpc_cidr ##Bloque CIDR pasado por variable.
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "AWS-VPC-Obligatorio"
  }
}

## Creamos Subnet Privada
resource "aws_subnet" "Terraform-Subnet-Private-1" {
  vpc_id                  = aws_vpc.VPC-Obligatorio.id #Asociamos un recurso creado con terraform
  cidr_block              = var.private_subnet_1 ## Notar la variable para el cidr block de la subnet
  availability_zone       = var.vpc_aws_az_1 ## Notar la variable para la AZ asignada a la subnet
  map_public_ip_on_launch = "false"  ## Definimos que no tenga IP Pública
  tags = {
    Name = var.tag_subnet_1
  }
}

## Creamos Subnet Privada
resource "aws_subnet" "Terraform-Subnet-Private-2" {
  vpc_id                  = aws_vpc.VPC-Obligatorio.id #Asociamos un recurso creado con terraform
  cidr_block              = var.private_subnet_2 ## Notar la variable para el cidr block de la subnet
  availability_zone       = var.vpc_aws_az_2 ## Notar la variable para la AZ asignada a la subnet
  map_public_ip_on_launch = "false"  ## Definimos que no tenga IP Pública
  tags = {
    Name = var.tag_subnet_1
  }
}



## Creamos Subnet Pública
resource "aws_subnet" "Terraform-Subnet-Public" {
  vpc_id                  = aws_vpc.VPC-Obligatorio.id 
  cidr_block              = var.public_subnet 
  availability_zone       = var.vpc_aws_az_1 
  map_public_ip_on_launch = "true"  ## Habilitamos la opción de IP Pública
  tags = {
    Name = var.tag_subnet_pub
  }
}

## Creamos Internet Gateway
resource "aws_internet_gateway" "Terraform-IG" {
  vpc_id = aws_vpc.VPC-Obligatorio.id

  tags = {
    Name = var.tag_igw
  }
}

## Generamos un Elastic IP para mi NAT Gateway ya que es un requisito necesario
resource "aws_eip" "NAT_EIP" {
  domain = "vpc" ##Solo se debe definir que el dominio será un VPC, no se debe indicar cual
}

## Asociamos NAT GW a Subnet Privada
resource "aws_nat_gateway" "Nat_GW_Para_mi_Private_Subnet" {
  allocation_id = aws_eip.NAT_EIP.id
  subnet_id = aws_subnet.Terraform-Subnet-Private.id

  tags = {
    Name = "AWS-NAT-GW" 
  }
}

## Asociamos Route Table
resource "aws_default_route_table" "Route_Table_Private" {
  default_route_table_id = aws_vpc.VPC-Obligatorio.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.Nat_GW_Para_mi_Private_Subnet.id
  }

  tags = {
    Name = "RT-Private"
  }
}

## Creamos Route Table para Subnet Pública
resource "aws_route_table" "Route_Table_para_SB_Public" {
  vpc_id = aws_vpc.VPC-Obligatorio.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Terraform-IG.id
  }

  tags = {
    Name = "RT-Public"
  }
}
 