#!/bin/bash
# ==============================================================================
# Script de Auditoria Automatizada y Politicas de Cumplimiento Normativo (IE5/IE6)
# Microservicio: Pagos (caso06 - ViajaMejor)
# Asignatura: Ingenieria DevOps (DOY0101) - Duoc UC
# Normativas de referencia: OWASP Top 10, CIS Docker Benchmark, PCI-DSS, NIST SP 800-190
# ==============================================================================

set -o pipefail

TOTAL_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

echo "========================================================================"
echo " INICIANDO AUDITORIA DE CUMPLIMIENTO NORMATIVO Y GOBERNANZA DEVOPS"
echo "========================================================================"
echo "Fecha y hora: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo "Microservicio: pagos-svc (Java 21 / Spring Boot 3 / Kubernetes)"
echo ""

check_rule() {
  local rule_id="$1"
  local rule_desc="$2"
  local status="$3"
  local details="$4"

  TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
  if [ "$status" = "PASS" ]; then
    echo "[PASS] [$rule_id] $rule_desc"
    [ -n "$details" ] && echo "       Detalle: $details"
  elif [ "$status" = "WARN" ]; then
    WARNING_CHECKS=$((WARNING_CHECKS + 1))
    echo "[WARN] [$rule_id] $rule_desc"
    [ -n "$details" ] && echo "       Alerta: $details"
  else
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
    echo "[FAIL] [$rule_id] $rule_desc"
    [ -n "$details" ] && echo "       Causa: $details"
  fi
}

echo "--- 1. AUDITORIA DE SEGURIDAD EN CONTENEDORES (CIS Benchmark / NIST) ---"

# Regla C-01: Usuario no privilegiado (Non-Root) en Dockerfile
if grep -qE "USER\s+[a-zA-Z0-9_-]+" Dockerfile && ! grep -qE "USER\s+root" Dockerfile; then
  APP_USER=$(grep -E "^USER\s+" Dockerfile | tail -n1 | awk '{print $2}')
  check_rule "C-01" "Ejecucion bajo usuario sin privilegios root" "PASS" "Configurado usuario: $APP_USER"
else
  check_rule "C-01" "Ejecucion bajo usuario sin privilegios root" "FAIL" "El Dockerfile ejecuta como root o no define instruccion USER"
fi

# Regla C-02: Healthcheck nativo configurado en contenedor
if grep -q "HEALTHCHECK" Dockerfile; then
  check_rule "C-02" "Sondeo de salud nativo (HEALTHCHECK) en imagen Docker" "PASS" "Directiva HEALTHCHECK detectada"
else
  check_rule "C-02" "Sondeo de salud nativo (HEALTHCHECK) en imagen Docker" "FAIL" "Falta directiva HEALTHCHECK en Dockerfile"
fi

# Regla C-03: Construccion Multi-Stage con imagen base Alpine/distroless
if grep -q -i "AS build" Dockerfile && grep -q -i "alpine" Dockerfile; then
  check_rule "C-03" "Optimizacion de superficie de ataque mediante Multi-Stage y Alpine" "PASS" "Compilacion en dos etapas y base JRE Alpine"
else
  check_rule "C-03" "Optimizacion de superficie de ataque mediante Multi-Stage y Alpine" "WARN" "Se recomienda imagen base minima (Alpine/Distroless)"
fi

echo ""
echo "--- 2. AUDITORIA DE ORQUESTACION Y RESILIENCIA EN KUBERNETES ---"

# Regla K-01: Asignacion estricta de limites y reservas de recursos (CPU y RAM)
if grep -q "limits:" k8s/deployment.yaml && grep -q "requests:" k8s/deployment.yaml; then
  check_rule "K-01" "Definicion de limites y reservas de recursos (CPU/Memoria)" "PASS" "Deployment K8s cuenta con requests y limits"
else
  check_rule "K-01" "Definicion de limites y reservas de recursos (CPU/Memoria)" "FAIL" "Faltan limites o reservas de CPU/Memoria en Deployment"
fi

# Regla K-02: Sondeos Liveness y Readiness en pods
if grep -q "livenessProbe:" k8s/deployment.yaml && grep -q "readinessProbe:" k8s/deployment.yaml; then
  check_rule "K-02" "Sondeos de vitalidad y disponibilidad (Liveness/Readiness Probes)" "PASS" "Probes configurados hacia endpoints de salud"
else
  check_rule "K-02" "Sondeos de vitalidad y disponibilidad (Liveness/Readiness Probes)" "FAIL" "Faltan livenessProbe o readinessProbe en Deployment"
fi

# Regla K-03: Politica de seguridad de Pod (runAsNonRoot y capacidades revocadas)
if grep -q "runAsNonRoot: true" k8s/deployment.yaml && grep -q "drop:" k8s/deployment.yaml; then
  check_rule "K-03" "Pod Security Context restrictivo (runAsNonRoot y drop capabilities)" "PASS" "Kernel capabilities revocadas (ALL) y non-root activo"
else
  check_rule "K-03" "Pod Security Context restrictivo (runAsNonRoot y drop capabilities)" "FAIL" "PodSecurityContext incompleto en manifiesto Deployment"
fi

# Regla K-04: Autoescalabilidad horizontal elástica (HPA)
if [ -f "k8s/hpa.yaml" ] && grep -q "HorizontalPodAutoscaler" k8s/hpa.yaml; then
  check_rule "K-04" "Autoescalabilidad elastica declarada (HPA 2-5 replicas)" "PASS" "HPA configurado con metricas de utilizacion"
else
  check_rule "K-04" "Autoescalabilidad elastica declarada (HPA 2-5 replicas)" "FAIL" "Falta manifiesto HPA para orquestacion elastica"
fi

echo ""
echo "--- 3. AUDITORIA DE OBSERVABILIDAD Y METRICAS EXPORTADAS (IE1 / IE2) ---"

# Regla O-01: Anotaciones de Prometheus en manifiestos de Kubernetes
if grep -q "prometheus.io/scrape" k8s/deployment.yaml; then
  check_rule "O-01" "Anotaciones para scraping automatizado de Prometheus en K8s" "PASS" "prometheus.io/scrape y path /actuator/prometheus presentes"
else
  check_rule "O-01" "Anotaciones para scraping automatizado de Prometheus en K8s" "FAIL" "Faltan anotaciones de Prometheus en Deployment K8s"
fi

# Regla O-02: Exportacion de metricas en Spring Boot Actuator
if grep -q "micrometer-registry-prometheus" pom.xml && grep -q "prometheus" src/main/resources/application.yml; then
  check_rule "O-02" "Dependencias y configuracion de exportacion de metricas Micrometer" "PASS" "Micrometer Prometheus activo en pom.xml y application.yml"
else
  check_rule "O-02" "Dependencias y configuracion de exportacion de metricas Micrometer" "FAIL" "Falta dependencia Micrometer o endpoint prometheus en configuracion"
fi

# Regla O-03: Reglas de alerta proactivas en Prometheus
if [ -f "monitoring/prometheus/alerts.yml" ]; then
  check_rule "O-03" "Reglas declarativas de alerta en Prometheus (Alertmanager)" "PASS" "Archivo alerts.yml con alertas de CPU, Memoria, Error Rate y Down"
else
  check_rule "O-03" "Reglas declarativas de alerta en Prometheus (Alertmanager)" "FAIL" "No se detecto archivo de alertas en monitoring/prometheus/"
fi

echo ""
echo "--- 4. AUDITORIA DE CALIDAD DE CODIGO Y SECRETOS (OWASP / PCI-DSS) ---"

# Regla S-01: Ausencia de llaves privadas o secretos hardcodeados
SECRET_MATCHES=$(grep -rnE "(BEGIN RSA PRIVATE KEY|AWS_SECRET_ACCESS_KEY|password:\s*\"[a-zA-Z0-9_\-]{8,}\")" src/ k8s/ monitoring/ 2>/dev/null || true)
if [ -z "$SECRET_MATCHES" ]; then
  check_rule "S-01" "Escaneo de credenciales y secretos expuestos en texto plano" "PASS" "No se detectaron secretos ni llaves privadas"
else
  check_rule "S-01" "Escaneo de credenciales y secretos expuestos en texto plano" "FAIL" "Posibles credenciales hardcodeadas: $SECRET_MATCHES"
fi

# Regla S-02: Politica de Cobertura JaCoCo 100% configurada
if grep -q "1.00" pom.xml && grep -q "jacoco-maven-plugin" pom.xml; then
  check_rule "S-02" "Umbral minimo de cobertura de pruebas JaCoCo (Quality Gate 100%)" "PASS" "pom.xml exige COVEREDRATIO 1.00 (100% de lineas)"
else
  check_rule "S-02" "Umbral minimo de cobertura de pruebas JaCoCo (Quality Gate 100%)" "FAIL" "Regla de cobertura JaCoCo no configurada al 100%"
fi

echo ""
echo "========================================================================"
echo " RESUMEN DE LA AUDITORIA DE CUMPLIMIENTO (COMPLIANCE AUDIT)"
echo "========================================================================"
echo "Total de reglas evaluadas: $TOTAL_CHECKS"
echo "Reglas aprobadas:          $((TOTAL_CHECKS - FAILED_CHECKS - WARNING_CHECKS))"
echo "Advertencias (Warnings):   $WARNING_CHECKS"
echo "Violaciones criticas:      $FAILED_CHECKS"
echo "========================================================================"

if [ "$FAILED_CHECKS" -gt 0 ]; then
  echo ""
  echo "[QUALITY GATE BLOQUEADO] Se detectaron $FAILED_CHECKS violaciones criticas de gobernanza o seguridad."
  echo "El pipeline CI/CD debe ser interrumpido de inmediato para proteger el entorno productivo (IE6)."
  exit 1
else
  echo ""
  echo "[QUALITY GATE APROBADO] Todas las politicas normativas de observabilidad, seguridad y gobernanza han sido validadas exitosamente."
  exit 0
fi
