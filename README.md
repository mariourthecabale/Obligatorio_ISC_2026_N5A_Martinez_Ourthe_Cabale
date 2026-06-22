## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_alb"></a> [alb](#module\_alb) | git::ssh://git@github.com/ISC-2026-Martinez-Ourthe-Cabale/module-alb.git | n/a |
| <a name="module_database"></a> [database](#module\_database) | git::ssh://git@github.com/ISC-2026-Martinez-Ourthe-Cabale/module-database.git | n/a |
| <a name="module_db_storage"></a> [db\_storage](#module\_db\_storage) | git::ssh://git@github.com/ISC-2026-Martinez-Ourthe-Cabale/storage-backup | n/a |
| <a name="module_ec2-tmp"></a> [ec2-tmp](#module\_ec2-tmp) | git::ssh://git@github.com/ISC-2026-Martinez-Ourthe-Cabale/modules-ec2-tmp.git | n/a |
| <a name="module_ec2_asg"></a> [ec2\_asg](#module\_ec2\_asg) | git::ssh://git@github.com/ISC-2026-Martinez-Ourthe-Cabale/module-asg.git | n/a |
| <a name="module_networking"></a> [networking](#module\_networking) | git::ssh://git@github.com/ISC-2026-Martinez-Ourthe-Cabale/module-networking.git | n/a |
| <a name="module_scripts"></a> [scripts](#module\_scripts) | git::ssh://git@github.com/ISC-2026-Martinez-Ourthe-Cabale/scripts.git | n/a |
| <a name="module_security_groups"></a> [security\_groups](#module\_security\_groups) | git::ssh://git@github.com/ISC-2026-Martinez-Ourthe-Cabale/module-security-groups.git | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_alb_ingress_cidr_blocks"></a> [alb\_ingress\_cidr\_blocks](#input\_alb\_ingress\_cidr\_blocks) | CIDR blocks permitidos al ALB. | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_alb_ingress_port"></a> [alb\_ingress\_port](#input\_alb\_ingress\_port) | Puerto de ingreso permitido al ALB. | `number` | `80` | no |
| <a name="input_alb_ingress_protocol"></a> [alb\_ingress\_protocol](#input\_alb\_ingress\_protocol) | Protocolo de ingreso permitido al ALB. | `string` | `"tcp"` | no |
| <a name="input_alb_name"></a> [alb\_name](#input\_alb\_name) | Variable para el nombre del ALB | `string` | n/a | yes |
| <a name="input_allocated_storage"></a> [allocated\_storage](#input\_allocated\_storage) | Storage inicial en GB | `number` | `20` | no |
| <a name="input_ami"></a> [ami](#input\_ami) | Variable para eleccion de la ami | `string` | n/a | yes |
| <a name="input_app_port"></a> [app\_port](#input\_app\_port) | Puerto para el tráfico de la aplicación | `number` | `80` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Variable para la region | `string` | n/a | yes |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | Días de retención de backups automáticos | `number` | `7` | no |
| <a name="input_backup_window"></a> [backup\_window](#input\_backup\_window) | Ventana horaria para backups automáticos | `string` | `"03:00-04:00"` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | n/a | `string` | n/a | yes |
| <a name="input_db_engine"></a> [db\_engine](#input\_db\_engine) | Motor de base de datos | `string` | `"mysql"` | no |
| <a name="input_db_engine_version"></a> [db\_engine\_version](#input\_db\_engine\_version) | Versión del motor MySQL | `string` | `"8.0"` | no |
| <a name="input_db_instance_class"></a> [db\_instance\_class](#input\_db\_instance\_class) | Tipo de instancia RDS | `string` | `"db.t3.micro"` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | Nombre de la base de datos inicial | `string` | `"ecommerce"` | no |
| <a name="input_db_password"></a> [db\_password](#input\_db\_password) | Contraseña del usuario administrador | `string` | n/a | yes |
| <a name="input_db_port"></a> [db\_port](#input\_db\_port) | Puerto para el tráfico de la base de datos | `number` | `3306` | no |
| <a name="input_db_username"></a> [db\_username](#input\_db\_username) | Usuario administrador de la base | `string` | n/a | yes |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Protección contra borrado accidental | `bool` | `false` | no |
| <a name="input_gitlab_token"></a> [gitlab\_token](#input\_gitlab\_token) | n/a | `any` | n/a | yes |
| <a name="input_health_check_enabled"></a> [health\_check\_enabled](#input\_health\_check\_enabled) | Variable para habilitar o deshabilitar el health check del Target Group | `bool` | n/a | yes |
| <a name="input_health_check_healthy_threshold"></a> [health\_check\_healthy\_threshold](#input\_health\_check\_healthy\_threshold) | Variable para el umbral de healthy del health check del Target Group | `number` | n/a | yes |
| <a name="input_health_check_interval"></a> [health\_check\_interval](#input\_health\_check\_interval) | Variable para el intervalo del health check del Target Group | `number` | n/a | yes |
| <a name="input_health_check_matcher"></a> [health\_check\_matcher](#input\_health\_check\_matcher) | Variable para el matcher del health check del Target Group | `string` | n/a | yes |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | Variable para el path del health check del Target Group | `string` | n/a | yes |
| <a name="input_health_check_protocol"></a> [health\_check\_protocol](#input\_health\_check\_protocol) | Variable para el protocolo del health check del Target Group | `string` | n/a | yes |
| <a name="input_health_check_timeout"></a> [health\_check\_timeout](#input\_health\_check\_timeout) | Variable para el timeout del health check del Target Group | `number` | n/a | yes |
| <a name="input_health_check_unhealthy_threshold"></a> [health\_check\_unhealthy\_threshold](#input\_health\_check\_unhealthy\_threshold) | Variable para el umbral de unhealthy del health check del Target Group | `number` | n/a | yes |
| <a name="input_listener_port"></a> [listener\_port](#input\_listener\_port) | Variable para el puerto del Listener | `number` | n/a | yes |
| <a name="input_listener_protocol"></a> [listener\_protocol](#input\_listener\_protocol) | Variable para el protocolo del Listener | `string` | n/a | yes |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | Ventana de mantenimiento | `string` | `"sun:04:00-sun:05:00"` | no |
| <a name="input_max_allocated_storage"></a> [max\_allocated\_storage](#input\_max\_allocated\_storage) | Storage máximo para autoscaling en GB | `number` | `100` | no |
| <a name="input_multi_az"></a> [multi\_az](#input\_multi\_az) | Habilita RDS Multi-AZ | `bool` | `false` | no |
| <a name="input_private_subnet_APP"></a> [private\_subnet\_APP](#input\_private\_subnet\_APP) | Variable para la subnet privada de la APP | `string` | n/a | yes |
| <a name="input_private_subnet_APP_2"></a> [private\_subnet\_APP\_2](#input\_private\_subnet\_APP\_2) | Subnet privada APP en segunda AZ | `string` | n/a | yes |
| <a name="input_private_subnet_DB"></a> [private\_subnet\_DB](#input\_private\_subnet\_DB) | Variable para la subnet privada de la Base de Datos | `string` | n/a | yes |
| <a name="input_private_subnet_DB_2"></a> [private\_subnet\_DB\_2](#input\_private\_subnet\_DB\_2) | Subnet privada DB en segunda AZ | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Nombre del proyecto para taggear los recursos | `string` | `"Obligatorio"` | no |
| <a name="input_public_subnet"></a> [public\_subnet](#input\_public\_subnet) | Variable para la subnet publica | `string` | n/a | yes |
| <a name="input_public_subnet_2"></a> [public\_subnet\_2](#input\_public\_subnet\_2) | Subnet publica en segunda AZ | `string` | n/a | yes |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Define si se omite el snapshot final al destruir la DB | `bool` | `false` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | Tipo de storage | `string` | `"gp3"` | no |
| <a name="input_target_group_port"></a> [target\_group\_port](#input\_target\_group\_port) | Variable para el puerto del Target Group | `number` | n/a | yes |
| <a name="input_target_group_protocol"></a> [target\_group\_protocol](#input\_target\_group\_protocol) | Variable para el protocolo del Target Group | `string` | n/a | yes |
| <a name="input_vpc_aws_az"></a> [vpc\_aws\_az](#input\_vpc\_aws\_az) | Variable para la az | `string` | n/a | yes |
| <a name="input_vpc_aws_az_2"></a> [vpc\_aws\_az\_2](#input\_vpc\_aws\_az\_2) | Segunda AZ para alta disponibilidad | `string` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | Variable para el CIDR block | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | DNS público del Application Load Balancer |
