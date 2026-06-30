# Utilización de IA en el proyecto

> Proyecto Obligatorio ISC 2026 — N5A | Martínez, Ourthe-Cabalé

Este documento detalla en qué partes del proyecto se utilizó inteligencia artificial como herramienta de apoyo, qué se le solicitó explícitamente, qué dudas se le consultaron durante el desarrollo y qué dificultades surgieron en el proceso.

---

## 1. Funciones Lambda generadas por IA

Se solicitó explícitamente a la IA que generara las funciones Lambda para automatizar el backup de la base de datos RDS. El pedido original fue:

> "Crear funciones lambda para realizar backup de la base de datos: la primera a las 2am debía levantar una instancia EC2 y realizar el backup, la segunda a las 5am debía apagar esa instancia."

A partir de ese pedido, la IA generó:

- **`start_backup`** (Lambda en Python/boto3): lanza una instancia EC2 temporal vía `ec2.run_instances`, con un `user_data` que instala el cliente de MySQL, espera a que la base esté disponible, ejecuta `mysqldump` y sube el resultado comprimido a S3 (prefijo `bkp-rds/`). La instancia se autotermina al finalizar.
- **`stop_backup`**: red de seguridad que, si la instancia de backup quedó colgada o tardó más de lo esperado, la termina por la fuerza a las 5am.
- El scheduling de ambas (horario 2am/5am hora Uruguay) vía EventBridge, y los permisos de invocación necesarios.
- Reutilización del `LabRole` existente del Learner Lab para la ejecución de ambas Lambdas (no se crearon roles IAM nuevos, dado que la cuenta de AWS Academy no permite `iam:CreateRole`).

Todo el código de estas Lambdas (`module-db-backup`) fue generado por la IA a partir de esa solicitud, incluyendo el módulo de Terraform que las despliega.

---

## 2. Cómo estresar la CPU de las instancias EC2 (prueba de autoescalado)

**Consulta:** cómo generar carga de CPU en las instancias del Auto Scaling Group para validar que la política de autoescalado (target tracking al 70% de CPU) efectivamente dispara un scale-out.

Paso a paso:

1. **Conectarse a una instancia sin bastión ni SSH directo.** Las instancias están en una subnet privada sin IP pública. Como `LabInstanceProfile` incluye permisos de SSM, se puede entrar vía **Session Manager** sin necesidad de claves SSH ni un bastion host:
   ```
      aws ssm start-session --target i-xxxxxxxxxxxxxxxxx
   ```

2. **Generar carga de CPU**, una de dos formas:
   - Con una herramienta dedicada (más control sobre duración/intensidad):
     ```bash
     sudo dnf install -y stress-ng
     stress-ng --cpu $(nproc) --cpu-load 90 --timeout 300s
     ```

## 3. GitLab Container Registry y por qué hizo falta un token

**Consulta:** cómo funciona el GitLab Container Registry y por qué fue necesario crear un token para poder leerlo.

GitLab incluye, por cada proyecto/grupo, un **registry de imágenes Docker privado** (equivalente a Docker Hub, pero integrado al control de acceso del propio repositorio GitLab). La imagen de la aplicación de este proyecto se publica ahí: `registry.gitlab.com/mourthecabalediaz/app:1.0`.

Al ser un registry **privado**, cualquier `docker pull`/`docker login` contra él necesita autenticarse — a diferencia de una imagen pública, que cualquiera puede descargar sin credenciales. Para eso GitLab ofrece **Deploy Tokens**: credenciales de alcance acotado (en este caso, solo lectura del registry — `read_registry`), pensadas específicamente para procesos automatizados de despliegue, en lugar de usar la contraseña o un token personal de una cuenta de usuario real. Ventajas de usar un deploy token en vez de credenciales de usuario:

- Se puede revocar o rotar sin afectar ninguna cuenta de persona.
- Su alcance es mínimo (solo puede leer el registry, no puede modificar código, ni pipelines, ni nada más).
- No depende de que una persona puntual del equipo siga teniendo acceso al proyecto.

En este proyecto, el token se pasa como variable sensible (`gitlab_token`) y se usa dentro del `user_data` de las instancias EC2 (módulo `module-asg`) para autenticar el `docker login` antes de bajar y correr la imagen:

```bash
docker login registry.gitlab.com -u deploy-token -p ${var.gitlab_token}
docker run -d -p 80:80 ... registry.gitlab.com/mourthecabalediaz/app:1.0
```

---

## 4. Dudas y consultas realizadas a la IA durante el desarrollo

- Cómo armar las dos Lambdas de backup automático de RDS (2am / 5am) y cómo programarlas.
- Cómo convertir el módulo `ec2-tmp` para que la inicialización de la base de datos sea idempotente (que no repueble si ya tiene datos).
- Decisión posterior: en vez de migrar esa lógica a una Lambda, agregar un `if` simple dentro del `user_data` de la instancia EC2 ya existente.
- Cómo cargar las imágenes de los productos en la base de datos y servirlas correctamente desde la aplicación (formato serializado de PHP que espera el código, y de dónde tienen que salir los archivos físicos).
- Si convenía servir esas imágenes desde S3 en vez de incluirlas en la imagen Docker, y qué arquitectura convenía.
- Por qué crear un bucket de S3 separado para las imágenes en vez de reusar el bucket de backups ya existente.
- Diferencia entre `terraform init` y `terraform init -migrate-state`, y si hacía falta usar específicamente ese segundo comando.
- Cuáles son los pasos correctos para desplegar todos los cambios de la sesión sobre infraestructura que ya estaba desplegada en AWS.
- Cómo invocar manualmente desde AWS las Lambdas de backup para probarlas sin esperar al horario programado.
- Dónde ubicar correctamente en el diagrama servicios regionales como Lambda, EventBridge, CloudWatch Logs y S3, diferenciándolos de los recursos desplegados dentro de la VPC, subnets y Availability Zones (Se utilizó diagrama para solución detallada).
- Qué métricas, alarmas y dashboards de CloudWatch convenía implementar para monitorear ALB, EC2/ASG, RDS, Lambdas de backup y notificaciones mediante SNS.
---

## 5. Dificultades encontradas

- **Incompatibilidad entre módulos detectada recién en `validate`/`apply`:** el módulo de monitoreo había evolucionado para pedir `alb_arn_suffix`/`target_group_arn_suffix` en lugar de los ARN completos, pero el orquestador todavía le pasaba los nombres viejos — error que no aparece hasta ejecutar Terraform.
- **Conflicto de git por trabajo en paralelo:** un compañero de equipo corrigió ese mismo bug al mismo tiempo en otro entorno, generando un conflicto de merge real en `main.tf` al sincronizar.
- **Error que solo aparece en `apply`, no en `validate`:** el dashboard de CloudWatch fallaba al aplicarlo en AWS porque a cada widget le faltaba la propiedad `region` — un error de la API de AWS, no de sintaxis de Terraform, por lo que `terraform validate` nunca lo detectó.
- **`.gitignore` faltante en un módulo nuevo:** el módulo de backend remoto (`module-tfstate-backend`) terminó en GitHub sin su `.gitignore`, dejando el riesgo de versionar accidentalmente el `terraform.tfstate` real (con los IDs de los recursos de AWS) si alguien corría un `git add` sin revisar.
- **State de Terraform divergente entre integrantes del equipo:** cada persona tenía su propio `terraform.tfstate` local (nunca compartido), lo que podía llevar a infraestructura duplicada o corrupción de state si dos personas aplicaban al mismo tiempo — motivo principal por el que se migró a un backend remoto S3 + DynamoDB.
- **Dependencia oculta entre repos:** el orquestador ya hacía referencia a variables de autoescalado (`min_size`, `cpu_target_value`, etc.) que dependían de cambios en `module-asg` todavía no subidos a GitHub por un compañero — de no detectarse antes de un `terraform init`, el despliegue habría fallado al traer ese módulo.

