# Pagos — Despliegue, Orquestación y Operación

Este documento detalla las estrategias de contenerización, orquestación y despliegue continuo (CD) para el microservicio de **Pagos (caso06 - ViajaMejor)**, cumpliendo con los estándares de rendimiento, gobernanza y alta disponibilidad evaluados en la **Evaluación Parcial N°2 (DOY0101)**.

---

## 1. Requisitos del Entorno

- **Java Development Kit:** JDK 21 (Eclipse Temurin recomendado).
- **Herramienta de Construcción:** Maven 3.9+.
- **Motor de Contenedores:** Docker 24.0+ / Docker Compose v2+.
- **Orquestador (Opcional local / Simulado CI):** Kubernetes v1.28+ (`kubectl`, `minikube` o `kind`).

---

## 2. Ejecución Local (Desarrollo)

```bash
mvn spring-boot:run
```

El servicio estará disponible en `http://localhost:8080`:

| Recurso | URL | Descripción |
|---|---|---|
| **Página de bienvenida** | `/` | Documentación interactiva y accesos rápidos |
| **Swagger UI** | `/swagger-ui/index.html` | Explorador interactivo de endpoints OpenAPI |
| **Especificación OpenAPI** | `/v3/api-docs` | Contrato técnico en formato JSON |
| **ReDoc** | `/redoc.html` | Documentación estructurada de la API |
| **Consola H2** | `/h2-console` | Gestor de base de datos en memoria (`jdbc:h2:mem:pagosdb`) |
| **API Base** | `/api/pagos` | Endpoint de operaciones CRUD del microservicio |

---

## 3. Contenerización Eficiente con Docker (IE1)

El `Dockerfile` implementa una estrategia de construcción en múltiples etapas (**Multi-stage build**):

1. **Etapa de Build (`maven:3.9-eclipse-temurin-21-alpine`):**
   - Aprovecha la caché de capas descargando las dependencias (`pom.xml`) antes de copiar el código fuente.
   - Compila y empaqueta el artefacto `.jar` optimizado.
2. **Etapa de Runtime (`eclipse-temurin:21-jre-alpine`):**
   - Imagen final ultraligera basada en Alpine Linux, reduciendo la superficie de ataque y el peso total (<180 MB).
   - **Gobernanza y Seguridad (IE3):** Ejecución bajo el usuario y grupo sin privilegios `appuser:appgroup` (UID/GID 10001), previniendo ataques de escalamiento de privilegios root.
   - **Optimización de Memoria:** Flags JVM `-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0`.
   - **Healthcheck Integrado:** Verificación nativa mediante sondeo HTTP a `/v3/api-docs`.

### Comandos de Construcción y Ejecución Docker:

```bash
# Construcción de la imagen
docker build -t duoc/jv0101-caso06-pagos:1.0.0 .

# Ejecución en contenedor aislado
docker run -d --name pagos-svc -p 8080:8080 duoc/jv0101-caso06-pagos:1.0.0

# Verificar logs y estado de salud
docker ps
docker logs -f pagos-svc
```

---

## 4. Orquestación con Docker Compose (IE5)

El archivo `docker-compose.yml` permite levantar el microservicio con políticas de tolerancia a fallos, monitoreo de salud y límites de recursos:

- **Límites de Recursos:**
  - Límite máximo: `1.0 CPU` / `512 MB RAM`.
  - Reserva mínima: `0.25 CPU` / `256 MB RAM`.
- **Healthcheck:** Consulta automatizada cada 15 segundos con política de reintentos y tolerancia de arranque de 25 segundos.
- **Red Aislada:** Conexión mediante la red bridge dedicada `pagos-net`.

```bash
# Iniciar microservicio en segundo plano
docker compose up -d --build

# Comprobar estado y healthcheck
docker compose ps

# Ver registros en tiempo real
docker compose logs -f

# Detener y remover contenedores y redes
docker compose down
```

---

## 5. Orquestación Avanzada con Kubernetes (K8s) (IE5)

En la carpeta [`k8s/`](../k8s/) se estructuran los manifiestos declarativos para un despliegue cloud-native de alta resiliencia y escalabilidad:

### Componentes de la Arquitectura K8s:

1. **`namespace.yaml`:** Aislamiento multi-tenant bajo el espacio de nombres `pagos-system`.
2. **`configmap.yaml`:** Variables de entorno y perfil activo (`SPRING_PROFILES_ACTIVE=prod`).
3. **`deployment.yaml`:**
   - **Alta Disponibilidad:** 2 réplicas mínimas.
   - **Zero-Downtime:** Estrategia `RollingUpdate` (`maxSurge: 1`, `maxUnavailable: 0`).
   - **Seguridad (IE3):** `runAsNonRoot: true`, `readOnlyRootFilesystem: false`, capacidades del kernel revocadas (`drop: ["ALL"]`).
   - **Sondeos de Salud:** `livenessProbe` (detecta y reinicia pods caídos) y `readinessProbe` (enruta tráfico solo cuando la aplicación está 100% lista).
4. **`service.yaml`:** Servicio interno de tipo `ClusterIP` exponiendo el puerto 80 hacia el puerto 8080 del contenedor.
5. **`hpa.yaml` (Horizontal Pod Autoscaler):**
   - **Escalabilidad Elástica (IE3 / IE5):** Escala automáticamente entre **2 y 5 réplicas** en función de la carga de CPU (umbral: 70%) y Memoria (umbral: 80%).
6. **`kustomization.yaml`:** Gestión declarativa unificada de todos los manifiestos.

### Despliegue en Clúster Kubernetes:

```bash
# Aplicar todos los manifiestos mediante Kustomize
kubectl apply -k k8s/

# Verificar el estado del despliegue y pods
kubectl get all -n pagos-system

# Verificar el autoescalado HPA
kubectl get hpa -n pagos-system

# Acceso local vía port-forwarding (para pruebas de laboratorio)
kubectl port-forward -n pagos-system svc/pagos-svc 8080:80
```

---

## 6. Despliegue Continuo Simulado en el Pipeline CI/CD (IE4)

Dentro del pipeline de **GitHub Actions** (`.github/workflows/ci-cd.yml`), el job `deploy-simulation` ejecuta un despliegue automatizado completo:

1. Recupera la imagen Docker generada en etapas previas.
2. Despliega el contenedor mediante `docker compose up -d`.
3. Ejecuta un bucle de comprobación de salud hasta confirmar el estado `healthy`.
4. Ejecuta una suite automatizada de **Smoke Tests**:
   - `GET /api/pagos` (Valida código HTTP 200).
   - `GET /v3/api-docs` (Valida disponibilidad de OpenAPI).
   - `POST /api/pagos` (Valida creación transaccional HTTP 201).
5. Valida la conformidad y sintaxis de los manifiestos de Kubernetes mediante `kubectl apply --dry-run=client -k k8s/`.
6. Publica un informe detallado con la matriz de trazabilidad y métricas en el `$GITHUB_STEP_SUMMARY`.
