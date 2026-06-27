# 📦 Obligatorio ISC 2026 — N5A | Martínez · Ourthe · Cabalé

> Infraestructura como Código (IaC) sobre AWS usando Terraform modular.  
> Repositorio principal: \\\[`mariourthecabale/Obligatorio\\\_ISC\\\_2026\\\_N5A\\\_Martinez\\\_Ourthe\\\_Cabale`](https://github.com/mariourthecabale/Obligatorio\\\_ISC\\\_2026\\\_N5A\\\_Martinez\\\_Ourthe\\\_Cabale)  
> Organización de módulos: \\\[`ISC-2026-Martinez-Ourthe-Cabale`](https://github.com/ISC-2026-Martinez-Ourthe-Cabale)

\---

## Tabla de contenidos

1. [Descripción general](#descripcion-general)
2. [Diagrama de arquitectura](#diagrama-de-arquitectura)
3. [Servicios de AWS utilizados](#servicios-de-aws-utilizados)
4. [Datos de la infraestructura](#datos-de-la-infraestructura)
5. [Firewalling / Security Groups](#firewalling--security-groups)
6. [Módulos Terraform](#modulos-terraform)
7. [Requisitos y dependencias](#requisitos-y-dependencias)
8. [Estructura del repositorio](#estructura-del-repositorio)
9. [Instructivo de uso](#instructivo-de-uso)
10. [Variables de entrada](#variables-de-entrada)
11. [Outputs](#outputs)
12. [Consideraciones de seguridad](#consideraciones-de-seguridad)

\---

## Descripción general

Este proyecto despliega una aplicación web de e-commerce en alta disponibilidad sobre AWS, completamente definida como código con Terraform.  
La arquitectura está distribuida en **dos Availability Zones**, con separación de capas (pública / aplicación / base de datos), balanceo de carga automático, auto escalado de instancias EC2, base de datos MySQL administrada (RDS), y almacenamiento de backups en S3.

La aplicación corre en contenedores Docker sobre instancias EC2, la imagen se obtiene desde **GitLab Container Registry** (`registry.gitlab.com/mourthecabalediaz/app:1.0`).

\---

## Diagrama de arquitectura

![Diagrama de arquitectura](./imagenes-doc/diagrama.png)

**Flujo de tráfico:**

1. El usuario accede al DNS público del ALB por HTTP (puerto 80).
2. El ALB distribuye el tráfico hacia las instancias EC2 del Auto Scaling Group ubicadas en las subnets privadas de APP.
3. Las instancias EC2 se conectan a la base de datos RDS MySQL a través de la subnet privada de DB (puerto 3306).
4. Las instancias tienen salida a Internet únicamente a través del NAT Gateway (para descargar la imagen Docker desde GitLab Registry y actualizaciones del SO).

\---

## Servicios de AWS utilizados

|Servicio|Uso|
|-|-|
|**VPC**|Red virtual privada que contiene toda la infraestructura|
|**Subnets**|2 públicas (ALB/NAT), 2 privadas APP (EC2), 2 privadas DB (RDS) — una por AZ|
|**Internet Gateway**|Salida a Internet desde subnets públicas|
|**NAT Gateway**|Salida a Internet desde subnets privadas (una por AZ)|
|**Elastic IP**|IPs estáticas para los NAT Gateways|
|**Route Tables**|Tablas de ruteo separadas para subnets públicas y privadas|
|**Application Load Balancer (ALB)**|Balanceo de carga HTTP entre instancias EC2|
|**Target Group**|Grupo de destino del ALB con health checks|
|**Auto Scaling Group (ASG)**|Escalado automático de instancias EC2 (mín 2, máx 4)|
|**Launch Template**|Configuración de las instancias EC2 (AMI, tipo, user data)|
|**EC2**|Instancias que ejecutan la aplicación en contenedores Docker|
|**RDS (MySQL 8.0)**|Base de datos relacional administrada|
|**DB Subnet Group**|Grupo de subnets privadas para RDS|
|**S3**|Almacenamiento de backups y archivos|
|**Security Groups**|Firewall a nivel de instancia para ALB, EC2 y RDS|
|**IAM Instance Profile**|Perfil `LabInstanceProfile` para permisos de las instancias|

\---

## Datos de la infraestructura

### Red (VPC y Subnets)

|Recurso|Variable|Valor típico / Descripción|
|-|-|-|
|VPC CIDR|`vpc\\\_cidr`|Configurable por el operador (ej: `10.0.0.0/16`)|
|Availability Zones|`vpc\\\_aws\\\_az` / `vpc\\\_aws\\\_az\\\_2`|Ej: `us-east-1a` / `us-east-1b`|
|Subnet Pública AZ1|`public\\\_subnet`|CIDR pasado al módulo networking|
|Subnet Pública AZ2|`public\\\_subnet\\\_2`|CIDR pasado al módulo networking|
|Subnet Privada APP AZ1|`private\\\_subnet\\\_APP`|CIDR pasado al módulo networking|
|Subnet Privada APP AZ2|`private\\\_subnet\\\_APP\\\_2`|CIDR pasado al módulo networking|
|Subnet Privada DB AZ1|`private\\\_subnet\\\_DB`|CIDR pasado al módulo networking|
|Subnet Privada DB AZ2|`private\\\_subnet\\\_DB\\\_2`|CIDR pasado al módulo networking|

> Los CIDRs exactos deben definirse en el archivo `terraform.tfvars` al momento del despliegue.

### Cómputo (EC2 / ASG)

|Parámetro|Valor|
|-|-|
|AMI|Configurable (`ami` variable) — recomendada Amazon Linux 2023|
|Tipo de instancia|Configurable (`instance\\\_type` en módulo ASG)|
|Capacidad mínima ASG|2 instancias|
|Capacidad máxima ASG|4 instancias|
|Capacidad deseada|2 instancias|
|IAM Instance Profile|`LabInstanceProfile`|
|Health check type|ELB|
|Ubicación|Subnets privadas APP (ambas AZs)|
|Software|Docker, Git, mariadb105 (cliente)|
|Imagen de la app|`registry.gitlab.com/mourthecabalediaz/app:1.0`|

### Base de datos (RDS)

|Parámetro|Valor por defecto|
|-|-|
|Motor|MySQL|
|Versión|8.0|
|Tipo de instancia|`db.t3.micro`|
|Almacenamiento inicial|20 GB|
|Almacenamiento máximo (autoscaling)|100 GB|
|Tipo de almacenamiento|`gp3`|
|Nombre de la base de datos|`ecommerce`|
|Puerto|`3306`|
|Acceso público|No (`publicly\\\_accessible = false`)|
|Cifrado en reposo|Sí (`storage\\\_encrypted = true`)|
|Multi-AZ|Configurable (por defecto `false`)|
|Backup automático|7 días de retención|
|Ventana de backup|`03:00–04:00` UTC|
|Ventana de mantenimiento|`sun:04:00–sun:05:00` UTC|
|Protección contra borrado|Configurable (por defecto `false`)|
|Actualizaciones menores automáticas|Sí|

### Load Balancer (ALB)

|Parámetro|Valor / Variable|
|-|-|
|Tipo|Application Load Balancer|
|Protocolo Listener|`listener\\\_protocol` (ej: `HTTP`)|
|Puerto Listener|`listener\\\_port` (ej: `80`)|
|Puerto Target Group|`target\\\_group\\\_port`|
|Protocolo Target Group|`target\\\_group\\\_protocol`|
|Health Check habilitado|`health\\\_check\\\_enabled`|
|Health Check path|`health\\\_check\\\_path`|
|Health Check protocol|`health\\\_check\\\_protocol`|
|Healthy threshold|`health\\\_check\\\_healthy\\\_threshold`|
|Unhealthy threshold|`health\\\_check\\\_unhealthy\\\_threshold`|
|Intervalo|`health\\\_check\\\_interval`|
|Timeout|`health\\\_check\\\_timeout`|
|Matcher (HTTP status)|`health\\\_check\\\_matcher`|

### Almacenamiento (S3)

|Parámetro|Valor|
|-|-|
|Nombre del bucket|`bucket\\\_name` (variable requerida)|
|Propósito|Backup y almacenamiento de archivos|

\---

## Firewalling / Security Groups

La arquitectura implementa **tres Security Groups** con una cadena de acceso estricta:

### SG-ALB (Application Load Balancer)

|Dirección|Puerto|Protocolo|Origen|
|-|-|-|-|
|Ingress|80 (configurable)|TCP (configurable)|`0.0.0.0/0` (Internet)|
|Egress|Todo|Todos|`0.0.0.0/0`|

### SG-EC2 (Instancias del ASG)

|Dirección|Puerto|Protocolo|Origen|
|-|-|-|-|
|Ingress|80 (configurable vía `app\\\_port`)|TCP|Solo desde **SG-ALB**|
|Egress|Todo|Todos|`0.0.0.0/0`|

> Las instancias EC2 \\\*\\\*no son accesibles directamente desde Internet\\\*\\\*. El único ingreso permitido proviene del ALB.

### SG-RDS (Base de datos MySQL)

|Dirección|Puerto|Protocolo|Origen|
|-|-|-|-|
|Ingress|3306 (configurable vía `db\\\_port`)|TCP|Solo desde **SG-EC2**|
|Egress|Todo|Todos|`0.0.0.0/0`|

> La base de datos \\\*\\\*no es accesible ni desde Internet ni desde el ALB\\\*\\\*, únicamente desde las instancias de aplicación.

**Resumen del modelo de seguridad:**

```
Internet → \\\[SG-ALB] → ALB → \\\[SG-EC2] → EC2 → \\\[SG-RDS] → RDS
```

\---

## Módulos Terraform

Este repositorio actúa como **orquestador** que consume módulos alojados en la organización [`ISC-2026-Martinez-Ourthe-Cabale`](https://github.com/ISC-2026-Martinez-Ourthe-Cabale).

|Nombre del módulo|Repositorio fuente|Descripción|
|-|-|-|
|`networking`|`ISC-2026-Martinez-Ourthe-Cabale/module-networking`|VPC, subnets, IGW, NAT GW, route tables|
|`security\\\_groups`|`ISC-2026-Martinez-Ourthe-Cabale/module-security-groups`|SG para ALB, EC2 y RDS|
|`alb`|`ISC-2026-Martinez-Ourthe-Cabale/module-alb`|ALB, Target Group, Listener|
|`ec2\\\_asg`|`ISC-2026-Martinez-Ourthe-Cabale/module-asg`|Launch Template + Auto Scaling Group|
|`database`|`ISC-2026-Martinez-Ourthe-Cabale/module-database`|RDS MySQL + DB Subnet Group|
|`db\\\_storage`|`ISC-2026-Martinez-Ourthe-Cabale/storage-backup`|S3 bucket para backups|
|`ec2-tmp`|`ISC-2026-Martinez-Ourthe-Cabale/modules-ec2-tmp`|EC2 temporales (uso durante desarrollo)|
|`scripts`|`ISC-2026-Martinez-Ourthe-Cabale/scripts`|Scripts de ejecución manual|

> Los módulos se referencian vía SSH (`git::ssh://git@github.com/...`). Requieren acceso SSH configurado con permisos a la organización.

\---

## Requisitos y dependencias

### Software local requerido

|Herramienta|Versión mínima recomendada|Instalación|
|-|-|-|
|**Terraform**|`>= 1.3.0`|[terraform.io/downloads](https://developer.hashicorp.com/terraform/downloads)|
|**AWS CLI**|`>= 2.0`|[aws.amazon.com/cli](https://aws.amazon.com/cli/)|
|**Git**|`>= 2.30`|[git-scm.com](https://git-scm.com/)|
|**SSH**|Cualquier versión moderna|Incluido en Linux/macOS; en Windows usar OpenSSH o PuTTY|

### Credenciales y accesos necesarios

|Requisito|Detalle|
|-|-|
|**Cuenta AWS**|Con permisos suficientes para crear VPC, EC2, RDS, S3, ALB, IAM, etc.|
|**AWS credentials**|Configuradas vía `aws configure`, variables de entorno, o perfil de instancia|
|**Clave SSH en GitHub**|Para que Terraform pueda clonar los módulos vía `git::ssh://`|
|**GitLab Token**|Token de despliegue para pull de la imagen Docker (`registry.gitlab.com/mourthecabalediaz/app:1.0`)|
|**IAM Instance Profile**|`LabInstanceProfile` debe existir en la cuenta AWS antes del despliegue|

### Permisos AWS necesarios (mínimos)

El usuario o rol que ejecute Terraform debe tener permisos para gestionar: `ec2:\\\*`, `rds:\\\*`, `elasticloadbalancing:\\\*`, `autoscaling:\\\*`, `s3:\\\*`, `iam:PassRole` (para el Instance Profile).

\---

## Estructura del repositorio

```
Obligatorio\\\_ISC\\\_2026\\\_N5A\\\_Martinez\\\_Ourthe\\\_Cabale/
├── terraform/
│   ├── main.tf           # Orquestación de todos los módulos
│   ├── variables.tf      # Declaración de variables de entrada
│   ├── outputs.tf        # Outputs (ALB DNS)
│   ├── terraform.tfvars  # Valores concretos (NO commitear si tiene secretos)
│   └── providers.tf      # Configuración del provider AWS (si existe)
├── .gitignore
├── LICENSE
└── README.md
```

> \\\*\\\*Nota:\\\*\\\* El directorio `terraform/` contiene el código HCL principal. Todos los comandos deben ejecutarse desde dentro de ese directorio.

\---

## Instructivo de uso

### 1\. Clonar el repositorio

```bash
git clone git@github.com:mariourthecabale/Obligatorio\\\_ISC\\\_2026\\\_N5A\\\_Martinez\\\_Ourthe\\\_Cabale.git
cd Obligatorio\\\_ISC\\\_2026\\\_N5A\\\_Martinez\\\_Ourthe\\\_Cabale/terraform
```

### 2\. Configurar credenciales AWS

```bash
aws configure
# Ingresar: AWS Access Key ID, Secret Access Key, región (ej: us-east-1) y formato (json)
```

O bien, si se trabaja en un entorno con roles de instancia/Lab, las credenciales ya están disponibles.

### 3\. Configurar la clave SSH para GitHub

Asegurarse de que la clave SSH esté registrada en GitHub y agregada al agente SSH:

```bash
eval "$(ssh-agent -s)"
ssh-add \\\~/.ssh/id\\\_rsa   # o la clave correspondiente
ssh -T git@github.com   # verificar acceso
```

### 4\. Crear el archivo de variables

Crear un archivo `terraform.tfvars` en el directorio `terraform/` con todos los valores requeridos:

```hcl
# Región y zonas de disponibilidad
aws\\\_region   = "us-east-1"
vpc\\\_aws\\\_az   = "us-east-1a"
vpc\\\_aws\\\_az\\\_2 = "us-east-1b"

# Red
vpc\\\_cidr             = "10.0.0.0/16"
public\\\_subnet        = "10.0.1.0/24"
public\\\_subnet\\\_2      = "10.0.2.0/24"
private\\\_subnet\\\_APP   = "10.0.10.0/24"
private\\\_subnet\\\_APP\\\_2 = "10.0.11.0/24"
private\\\_subnet\\\_DB    = "10.0.20.0/24"
private\\\_subnet\\\_DB\\\_2  = "10.0.21.0/24"

# Cómputo
ami         = "ami-XXXXXXXXXXXXXXXXX"   # Amazon Linux 2023 en us-east-1

# Base de datos
db\\\_username = "admin"
db\\\_password = "SuperSecreta123!"       # ¡Usar un valor seguro!
db\\\_name     = "ecommerce"

# ALB
alb\\\_name              = "obligatorio-alb"
listener\\\_port         = 80
listener\\\_protocol     = "HTTP"
target\\\_group\\\_port     = 80
target\\\_group\\\_protocol = "HTTP"

health\\\_check\\\_enabled             = true
health\\\_check\\\_path                = "/"
health\\\_check\\\_protocol            = "HTTP"
health\\\_check\\\_matcher             = "200"
health\\\_check\\\_interval            = 30
health\\\_check\\\_timeout             = 5
health\\\_check\\\_healthy\\\_threshold   = 2
health\\\_check\\\_unhealthy\\\_threshold = 3

# S3
bucket\\\_name = "obligatorio-backup-XXXX"   # debe ser globalmente único

# GitLab
gitlab\\\_token = "gldt-XXXXXXXXXXXX"         # Deploy token de GitLab
```

> ⚠️ \\\*\\\*No commitear `terraform.tfvars` si contiene contraseñas o tokens.\\\*\\\* Agregar al `.gitignore`.

### 5\. Inicializar Terraform

Este paso descarga los módulos desde GitHub vía SSH:

```bash
terraform init
```

Si hay errores de clonación de módulos, verificar que la clave SSH tenga acceso a la organización `ISC-2026-Martinez-Ourthe-Cabale`.

### 6\. Revisar el plan de ejecución

```bash
terraform plan
```

Revisar la salida para confirmar los recursos que se crearán antes de aplicar.

### 7\. Aplicar la infraestructura

```bash
terraform apply
```

Escribir `yes` cuando se solicite confirmación. El proceso tarda aproximadamente **10–15 minutos** (la creación de RDS y el NAT Gateway son los recursos más lentos).

### 8\. Obtener el DNS del ALB

Al finalizar, Terraform mostrará el DNS público del ALB:

```
Outputs:
alb\\\_dns\\\_name = "obligatorio-alb-XXXXXXXXXX.us-east-1.elb.amazonaws.com"
```

Acceder a esa URL desde el navegador para verificar que la aplicación responde.

### 9\. Destruir la infraestructura

Cuando ya no se necesite el entorno:

```bash
terraform destroy
```

> ⚠️ Esto eliminará \\\*\\\*todos\\\*\\\* los recursos creados, incluyendo la base de datos. Si `skip\\\_final\\\_snapshot = false`, se creará un snapshot de RDS antes de borrar.

\---

## Variables de entrada

A continuación el detalle completo de todas las variables del módulo raíz:

|Variable|Tipo|Requerida|Default|Descripción|
|-|-|-|-|-|
|`aws\\\_region`|`string`|✅|—|Región AWS donde desplegar|
|`vpc\\\_cidr`|`string`|✅|—|CIDR block de la VPC|
|`vpc\\\_aws\\\_az`|`string`|✅|—|Primera Availability Zone|
|`vpc\\\_aws\\\_az\\\_2`|`string`|✅|—|Segunda Availability Zone|
|`public\\\_subnet`|`string`|✅|—|CIDR subnet pública AZ1|
|`public\\\_subnet\\\_2`|`string`|✅|—|CIDR subnet pública AZ2|
|`private\\\_subnet\\\_APP`|`string`|✅|—|CIDR subnet privada APP AZ1|
|`private\\\_subnet\\\_APP\\\_2`|`string`|✅|—|CIDR subnet privada APP AZ2|
|`private\\\_subnet\\\_DB`|`string`|✅|—|CIDR subnet privada DB AZ1|
|`private\\\_subnet\\\_DB\\\_2`|`string`|✅|—|CIDR subnet privada DB AZ2|
|`ami`|`string`|✅|—|ID de la AMI para las instancias EC2|
|`project\\\_name`|`string`|❌|`"Obligatorio"`|Nombre del proyecto para tags|
|`alb\\\_name`|`string`|✅|—|Nombre del ALB|
|`alb\\\_ingress\\\_cidr\\\_blocks`|`list(string)`|❌|`\\\["0.0.0.0/0"]`|CIDRs permitidos al ALB|
|`alb\\\_ingress\\\_port`|`number`|❌|`80`|Puerto de ingreso al ALB|
|`alb\\\_ingress\\\_protocol`|`string`|❌|`"tcp"`|Protocolo de ingreso al ALB|
|`listener\\\_port`|`number`|✅|—|Puerto del Listener del ALB|
|`listener\\\_protocol`|`string`|✅|—|Protocolo del Listener|
|`target\\\_group\\\_port`|`number`|✅|—|Puerto del Target Group|
|`target\\\_group\\\_protocol`|`string`|✅|—|Protocolo del Target Group|
|`health\\\_check\\\_enabled`|`bool`|✅|—|Habilitar health check|
|`health\\\_check\\\_path`|`string`|✅|—|Path del health check|
|`health\\\_check\\\_protocol`|`string`|✅|—|Protocolo del health check|
|`health\\\_check\\\_matcher`|`string`|✅|—|Código HTTP esperado|
|`health\\\_check\\\_interval`|`number`|✅|—|Intervalo entre checks (seg)|
|`health\\\_check\\\_timeout`|`number`|✅|—|Timeout del check (seg)|
|`health\\\_check\\\_healthy\\\_threshold`|`number`|✅|—|Chequeos OK para marcar healthy|
|`health\\\_check\\\_unhealthy\\\_threshold`|`number`|✅|—|Chequeos fallidos para unhealthy|
|`app\\\_port`|`number`|❌|`80`|Puerto de la aplicación en EC2|
|`db\\\_engine`|`string`|❌|`"mysql"`|Motor de base de datos|
|`db\\\_engine\\\_version`|`string`|❌|`"8.0"`|Versión del motor|
|`db\\\_instance\\\_class`|`string`|❌|`"db.t3.micro"`|Tipo de instancia RDS|
|`db\\\_name`|`string`|❌|`"ecommerce"`|Nombre de la base de datos|
|`db\\\_username`|`string`|✅|—|Usuario admin de la DB|
|`db\\\_password`|`string`|✅|—|Contraseña admin de la DB|
|`db\\\_port`|`number`|❌|`3306`|Puerto de la DB|
|`allocated\\\_storage`|`number`|❌|`20`|Storage inicial en GB|
|`max\\\_allocated\\\_storage`|`number`|❌|`100`|Storage máximo en GB|
|`storage\\\_type`|`string`|❌|`"gp3"`|Tipo de almacenamiento|
|`backup\\\_retention\\\_period`|`number`|❌|`7`|Días de retención de backups|
|`backup\\\_window`|`string`|❌|`"03:00-04:00"`|Ventana de backup|
|`maintenance\\\_window`|`string`|❌|`"sun:04:00-sun:05:00"`|Ventana de mantenimiento|
|`multi\\\_az`|`bool`|❌|`false`|Habilitar RDS Multi-AZ|
|`skip\\\_final\\\_snapshot`|`bool`|❌|`false`|Omitir snapshot al destruir|
|`deletion\\\_protection`|`bool`|❌|`false`|Proteger DB contra borrado|
|`bucket\\\_name`|`string`|✅|—|Nombre del bucket S3|
|`gitlab\\\_token`|`any`|✅|—|Token de despliegue de GitLab|

\---

## Outputs

|Output|Descripción|
|-|-|
|`alb\\\_dns\\\_name`|DNS público del Application Load Balancer para acceder a la aplicación|

\---

## Consideraciones de seguridad

* **Secretos:** Las variables `db\\\_password` y `gitlab\\\_token` son sensibles. No commitearlas en texto plano. Usar variables de entorno (`TF\\\_VAR\\\_db\\\_password`) o un gestor de secretos como AWS Secrets Manager.
* **State file:** El estado de Terraform (`terraform.tfstate`) contiene valores sensibles. Configurar un backend remoto (ej: S3 + DynamoDB) para entornos compartidos.
* **RDS no público:** La base de datos no tiene acceso público. El único acceso es desde las instancias EC2 del ASG.
* **NAT Gateway por AZ:** Cada AZ tiene su propio NAT Gateway, garantizando que la salida a Internet de las instancias privadas no dependa de una única AZ.
* **Cifrado RDS:** El almacenamiento de la base de datos está cifrado en reposo (`storage\\\_encrypted = true`).

\---

*Proyecto académico — ISC 2026 — N5A | Martínez, Ourthe, Cabalé*



