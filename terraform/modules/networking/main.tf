## Creamos VPC
resource "aws_vpc" "TF-VPC-Obligatorio" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "AWS-${var.name}-VPC"
  }
}

## Creamos Internet Gateway para salir a internet
resource "aws_internet_gateway" "TF-IGW-Obligatorio" {
  vpc_id = aws_vpc.TF-VPC-Obligatorio.id

  tags = {
    Name = "AWS-${var.name}-IGW"
  }
}

## Creamos Subnet Pública que utilizará el Load Balancer y el NAT Gateway
resource "aws_subnet" "TF-Subnet-Public" {
  count = length(var.azs)

  vpc_id                  = aws_vpc.TF-VPC-Obligatorio.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "AWS-${var.name}-Public-${var.azs[count.index]}"
  }
}

## Creamos Subnet Privada para la APP
resource "aws_subnet" "TF-Private-APP" {
  count = length(var.azs)

  vpc_id                  = aws_vpc.TF-VPC-Obligatorio.id
  cidr_block              = var.private_app_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "AWS-${var.name}-Private-APP-${var.azs[count.index]}"
  }
}

## Creamos Subnet Privada para la DB
resource "aws_subnet" "TF-Private-DB" {
  count = length(var.azs)

  vpc_id                  = aws_vpc.TF-VPC-Obligatorio.id
  cidr_block              = var.private_db_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "AWS-${var.name}-Private-DB-${var.azs[count.index]}"
  }
}

## Creamos EIP para el NAT Gateway
resource "aws_eip" "nat" {
  count = length(var.azs)

  domain = "vpc"

  tags = {
    Name = "AWS-${var.name}-NAT-EIP-${var.azs[count.index]}"
  }
}

## Creamos NAT Gateway en la Subnet Pública
resource "aws_nat_gateway" "TF-NAT-GW-Obligatorio" {
  count = length(var.azs)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.TF-Subnet-Public[count.index].id

  tags = {
    Name = "AWS-${var.name}-NAT-${var.azs[count.index]}"
  }

  depends_on = [aws_internet_gateway.TF-IGW-Obligatorio]
}

## Creamos Route Table para la Subnet Pública
resource "aws_route_table" "TF-RT-Public" {
  vpc_id = aws_vpc.TF-VPC-Obligatorio.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.TF-IGW-Obligatorio.id
  }

  tags = {
    Name = "AWS-${var.name}-RT-Public"
  }
}

## Asociamos Route Table para la Subnet Pública
resource "aws_route_table_association" "TF-RT-Public" {
  count = length(var.azs)

  subnet_id      = aws_subnet.TF-Subnet-Public[count.index].id
  route_table_id = aws_route_table.TF-RT-Public.id
}

## Creamos Route Table para la Subnet Privada
resource "aws_route_table" "TF-RT-Private" {
  count = length(var.azs)

  vpc_id = aws_vpc.TF-VPC-Obligatorio.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.TF-NAT-GW-Obligatorio[count.index].id
  }

  tags = {
    Name = "AWS-${var.name}-RT-Private-${var.azs[count.index]}"
  }
}

## Asociamos Route Table para la Subnet Privada de la APP
resource "aws_route_table_association" "TF-RT-Private-APP" {
  count = length(var.azs)

  subnet_id      = aws_subnet.TF-Private-APP[count.index].id
  route_table_id = aws_route_table.TF-RT-Private[count.index].id
}

## Asociamos Route Table para la Subnet Privada de la DB
resource "aws_route_table_association" "TF-RT-Private-DB" {
  count = length(var.azs)

  subnet_id      = aws_subnet.TF-Private-DB[count.index].id
  route_table_id = aws_route_table.TF-RT-Private[count.index].id
}