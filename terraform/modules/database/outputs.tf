## Outputs para el módulo de base de datos RDS.
## Output para el endpoint de la base de datos RDS.

output "db_instance_id" {
  value = aws_db_instance.rds.id
}
 
output "db_endpoint" {
  value = aws_db_instance.rds.endpoint
}
 
output "db_address" {
  value = aws_db_instance.rds.address
}
 
output "db_port" {
  value = aws_db_instance.rds.port
}
 
output "db_name" {
  value = aws_db_instance.rds.db_name
}
 
output "db_subnet_group_name" {
  value = aws_db_subnet_group.rds.name
}