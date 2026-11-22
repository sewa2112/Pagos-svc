# Observabilidad, Monitoreo y Gobernanza DevOps — Microservicio Pagos

Este documento técnico detalla la arquitectura de **observabilidad, monitoreo en tiempo real, auditoría de cumplimiento normativo y mecanismos de interrupción automatizada** implementados para el microservicio de **Pagos (caso06 - ViajaMejor)** en el marco de la **Evaluación Parcial N°3 (DOY0101 — Ingeniería DevOps)**.

---

## 1. Arquitectura de Observabilidad del Microservicio (IE1 & IE2)

La solución adopta el estándar de la industria para observabilidad nativa en nube (*Cloud-Native Observability*), articulando métricas, registros estructurados (*logging*), sondeos de salud y visualización centralizada.

```
+---------------------------------------------------------------------------------------+
|                                ENTORNO PRODUCTIVO SIMULADO                            |
|                                                                                       |
|  +---------------------------------------------------------------------------------+  |
|  | Microservicio Pagos (Spring Boot 3.3.5 / Java 21)                               |  |
|  | - Port: 8080                                                                    |  |
|  | - Actuator Endpoints: /actuator/health, /actuator/metrics, /actuator/prometheus |  |
|  | - Logging Estructurado con Contexto de Trazabilidad (traceId, spanId)         |  |
|  +---------------------------------------------------------------------------------+  |
|               ^                                                                       |
|               | Scrape HTTP cada 5s (PULL)                                           |
|  +---------------------------------------------------------------------------------+  |
|  | Servidor Prometheus (v2.54.1)                                                   |  |
|  | - Port: 9090                                                                    |  |
|  | - TSDB Storage & Engine de Alertas (alerts.yml)                                 |  |
|  +---------------------------------------------------------------------------------+  |
|               ^                                                                       |
|               | Data Source Proxy (PromQL)                                            |
|  +---------------------------------------------------------------------------------+  |
|  | Grafana Dashboard (v11.2.0)                                                     |  |
|  | - Port: 3000 (Credenciales: admin/admin)                                        |  |
|  | - Dashboard Provisionado: pagos-metrics-dashboard.json                          |  |
|  +---------------------------------------------------------------------------------+  |
+---------------------------------------------------------------------------------------+
```

### Componentes Técnicos Implementados:

1. **Spring Boot Actuator & Micrometer Prometheus (`pom.xml` & `application.yml`):**
   - Expone métricas en formato estándar de Prometheus en `/actuator/prometheus`.
   - Proporciona sondeos de estado de salud granular en `/actuator/health/liveness` y `/actuator/health/readiness`.
   - Incluye histogramas de percentiles para distribución de latencia (`http.server.requests`).

2. **Servidor Prometheus (`monitoring/prometheus/prometheus.yml`):**
   - Monitoreo activo recolectando métricas cada 5 segundos.
   - Definición de reglas de alerta proactivas en `monitoring/prometheus/alerts.yml`.

3. **Panel de Control Grafana (`monitoring/grafana/`):**
   - Aprovisionamiento automatizado de fuente de datos (`prometheus-datasource.yml`).
   - Tablero integral de observabilidad (`pagos-metrics-dashboard.json`) con refresco en vivo.

4. **Integración con Kubernetes (Cloud Orchestrated - IE2):**
   - Anotaciones declarativas en `k8s/deployment.yaml` y `k8s/service.yaml`:
     ```yaml
     annotations:
       prometheus.io/scrape: "true"
       prometheus.io/path: "/actuator/prometheus"
       prometheus.io/port: "8080"
     ```
   - Sondeos de salud configurados nativamente hacia Actuator:
     - `livenessProbe`: `/actuator/health/liveness` (autorecuperación ante fallos).
     - `readinessProbe`: `/actuator/health/readiness` (aislamiento de tráfico no preparado).

---

## 2. Métricas Clave de Desempeño y Calidad (IE3)

El tablero de control en Grafana y el Step Summary del pipeline CI/CD visualizan y analizan continuamente las cuatro dimensiones requeridas:

| Métrica Requerida | Indicador / Expresión PromQL | Umbral Operacional | Propósito Técnico |
|---|---|---|---|
| **1. Tiempo de Despliegue** | Duración del pipeline en GitHub Actions / `process_uptime_seconds` | < 180 segundos | Mide la eficiencia y agilidad de la entrega continua (Lead Time for Changes - DORA). |
| **2. Cobertura de Pruebas** | JaCoCo `COVEREDRATIO` en `pom.xml` (Líneas de código cubiertas) | 100% estricto | Garantiza que no exista código productivo sin respaldo de pruebas unitarias o BDD. |
| **3. Uso de CPU y Memoria** | `process_cpu_usage` y `jvm_memory_used_bytes{area="heap"}` | CPU < 70%, Heap < 85% | Previene saturación de recursos, *throttling* y caídas por OutOfMemory (OOMKilled). |
| **4. Errores Registrados** | `rate(http_server_requests_seconds_count{status=~"[45].."}[1m])` | 0% en despliegue / < 5% operacional | Detecta anomalías funcionales, fallos de contrato (4xx) o errores internos de servidor (5xx). |

---

## 3. Toma de Decisiones Técnicas Informadas (IE4)

La observabilidad no es únicamente visualización; es el motor que fundamenta las decisiones de arquitectura, escalabilidad y operación continua.

### Matriz de Decisiones Técnicas Basadas en Métricas (Panel -> Decisión -> Acción):

| Panel / Métrica | Condición Observada | Decisión Técnica | Acción Operacional Ejecutada |
|---|---|---|---|
| **Tiempo de Despliegue** | Duración del pipeline supera los 180 segundos en GitHub Actions. | Optimizar el proceso de empaquetado y cacheo de capas. | Se habilita caché en capas Docker, dependencias Maven pre-descargadas y paralelización de validaciones. |
| **Cobertura de Pruebas** | Cobertura JaCoCo cae por debajo del 100% de líneas requeridas. | Bloquear la promoción a producción e impedir merges no testeados. | El Quality Gate de JaCoCo en `pom.xml` finaliza con error (fail-fast) y detiene el pipeline en la etapa de test. |
| **Uso de CPU y Memoria** | Uso sostenido de CPU > 70% o Memoria JVM Heap > 80% durante más de 60 segundos. | Escalar horizontalmente pods del microservicio y recolectar diagnósticos. | El Horizontal Pod Autoscaler (HPA) en Kubernetes incrementa de 2 a hasta 5 réplicas; se programa heap dump si persiste. |
| **Errores Registrados (HTTP 5xx)** | Tasa de errores HTTP 5xx supera el 1% o fallan los Smoke Tests de despliegue. | Aislar el pod no saludable y realizar rollback automático preventivo. | Kubernetes retira el pod mediante Readiness Probe; el pipeline de CI/CD marca el job como fallido y aborta el despliegue. |

---

## 4. Políticas de Cumplimiento, Gobernanza y Auditoría Automatizada (IE5)

Se establecen controles automatizados para garantizar la conformidad con normativas del sector (CIS Docker Benchmark, NIST SP 800-190, OWASP y PCI-DSS para servicios de pagos).

### Matriz de Gobernanza y Verificación (Política -> Herramienta -> Verificación):

| Política Normativa | Herramienta | Verificación Automatizada |
|---|---|---|
| **Seguridad de Contenedores y Mínimo Privilegio** | `audit/compliance-audit.sh` (CIS Benchmark) | Valida que Dockerfile ejecute como usuario no-root (`appuser`), incluya `HEALTHCHECK` nativo y utilice base Alpine multi-stage. |
| **Orquestación Segura y Resiliencia Cloud** | `kubectl kustomize` + Script de Auditoría | Verifica que los manifiestos K8s definan `requests/limits`, `liveness/readiness probes`, `runAsNonRoot: true`, `drop: [ALL]` y HPA. |
| **Observabilidad y Monitoreo Obligatorio** | Script de Auditoría + Spring Boot Actuator | Valida la presencia de anotaciones `prometheus.io/scrape` en K8s, dependencias Micrometer y reglas de alertas en Prometheus. |
| **Calidad de Código y Quality Gate Centralizado** | SonarQube / SonarCloud (`sonar-project.properties`) | Inspecciona bugs, vulnerabilidades, *code smells*, duplicación de código y exige umbrales mínimos antes de liberar la versión. |
| **Control de Cambios y Trazabilidad en Repositorio** | GitHub Branch Protection Rules (`main`/`develop`) | Exige Pull Requests obligatorios, aprobación de revisores y paso exitoso de checks de estado (pruebas unitarias, auditoría y seguridad). |
| **Detección Preventiva de Fugas de Secretos** | Script de Auditoría (`audit/compliance-audit.sh`) | Escaneo regex estricto contra tokens, claves RSA privadas y contraseñas expuestas en texto claro antes de compilar. |

### A. Script de Auditoría Automatizada (`audit/compliance-audit.sh`)
El pipeline ejecuta una suite de verificación de 12 reglas que auditan:
- **Seguridad en Contenedores:** Usuario sin privilegios root (`appuser:appgroup`), sondeo nativo `HEALTHCHECK` y base ligera Alpine.
- **Seguridad en Kubernetes:** `runAsNonRoot: true`, revocación de capacidades del kernel (`capabilities.drop: ["ALL"]`), límites y reservas de recursos obligatorios, y HPA configurado.
- **Observabilidad:** Anotaciones de scrape de Prometheus presentes en el despliegue y endpoints Actuator expuestos.
- **Secretos y Calidad:** Escaneo preventivo de llaves privadas hardcodeadas y validación de cobertura JaCoCo al 100%.

### B. Análisis Estático y Quality Gates con SonarQube (`sonar-project.properties`)
Configuración lista para SonarQube / SonarCloud que valida:
- Integración de reportes de cobertura JaCoCo XML (`target/site/jacoco/jacoco.xml`).
- Detección de *code smells*, deuda técnica, duplicación de código y *vulnerabilidades de seguridad (hotspots)*.
- Política de Quality Gate que bloquea el avance ante no conformidades de confiabilidad o seguridad.

### C. Políticas de Protección de Ramas en GitHub (Branch Protection Rules)
Para las ramas productivas (`main` y `develop`) se definen las siguientes reglas de gobernanza:
- **Restricción de Push Directo:** Ningún desarrollador puede hacer push directo; todo cambio debe ingresar mediante Pull Request.
- **Revisión de Código Obligatoria:** Mínimo un aprobador calificado antes de permitir la fusión.
- **Comprobaciones de Estado Requeridas (Required Status Checks):**
  - `test-and-coverage` (Pruebas unitarias, BDD y JaCoCo 100% aprobadas).
  - `compliance-and-security` (Auditoría normativa y escaneo de vulnerabilidades aprobados).
- **Resolución de Conversaciones:** Todos los hilos de revisión en el PR deben marcarse como resueltos.

---

## 5. Mecanismo de Interrupción Automatizada ante Fallas Críticas (IE6)

El pipeline de CI/CD incorpora múltiples compuertas de calidad (*Quality Gates*) con política de fallo inmediato (*fail-fast* con código de salida `exit 1`):

```
[Código / PR]
      |
      v
+------------------------------------+
| 1. Quality Gate: Pruebas y JaCoCo  | ----> ¿Cobertura < 100% o Test Falla? ----> [DETENER PIPELINE] (IE6)
+------------------------------------+
      | Aprobado
      v
+------------------------------------+
| 2. Quality Gate: Auditoría Normat. | ----> ¿Violación CIS / Non-Root / Secretos? -> [DETENER PIPELINE] (IE6)
+------------------------------------+
      | Aprobado
      v
+------------------------------------+
| 3. Quality Gate: Seguridad (Snyk)  | ----> ¿Vulnerabilidad CRITICAL / HIGH? -----> [DETENER PIPELINE] (IE6)
+------------------------------------+
      | Aprobado
      v
+------------------------------------+
| 4. Quality Gate: Despliegue/Salud  | ----> ¿Healthcheck != UP o Smoke Test != 200? -> [DETENER PIPELINE] (IE6)
+------------------------------------+
      | Aprobado
      v
[Promoción Exitosa a Producción]
```

### Casos de Prueba que Demuestran la Interrupción del Pipeline:
1. **Falla por Cobertura Insuficiente:** Si un nuevo endpoint se agrega sin prueba unitaria o la cobertura baja de 100%, JaCoCo falla en la fase `verify` y el pipeline aborta en la Etapa 1.
2. **Falla por Incumplimiento Normativo:** Si un desarrollador omite la directiva `USER appuser` en el Dockerfile o retira los límites de memoria en Kubernetes, `scripts/compliance-audit.sh` finaliza con código 1 y aborta en la Etapa 2.
3. **Falla por Salud en Despliegue:** Si la base de datos o el microservicio no inician y el endpoint `/actuator/health` no responde `{"status":"UP"}`, los Smoke Tests fallan con código 1 y el pipeline aborta inmediatamente en la Etapa 4, protegiendo el entorno productivo.
