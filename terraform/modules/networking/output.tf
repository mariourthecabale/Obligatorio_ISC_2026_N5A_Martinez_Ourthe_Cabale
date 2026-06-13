## Outputs del módulo de Networking
## Outputs de la VPC
output "vpc_id" {
  value = aws_vpc.TF-VPC-Obligatorio.id
}

## Outputs de las Subnets
output "public_subnet_ids" {
  value = aws_subnet.TF-Subnet-Public[*].id
}

output "private_app_subnet_ids" {
  value = aws_subnet.TF-Private-APP[*].id
}

output "private_db_subnet_ids" {
  value = aws_subnet.TF-Private-DB[*].id
}

## Output del NAT Gateway
output "nat_gateway_ids" {
  value = aws_nat_gateway.TF-NAT-GW-Obligatorio[*].id
}