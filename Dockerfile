# syntax=docker/dockerfile:1
# =========================================================
# Etapa 1: Construcción y compilación con Maven (Java 21)
# =========================================================
FROM maven:3.9-eclipse-temurin-21-alpine AS build
WORKDIR /app

# Aprovechamiento de caché de capas copiando únicamente pom.xml primero
COPY pom.xml ./
RUN mvn -B -q dependency:go-offline

# Copiar código fuente y empaquetar artefacto
COPY src ./src
RUN mvn -B -q clean package -DskipTests

# =========================================================
# Etapa 2: Imagen final de ejecución (Runtime JRE 21 Alpine)
# =========================================================
FROM eclipse-temurin:21-jre-alpine AS runtime
WORKDIR /app

# Parámetro de seguridad y gobernanza (IE1 / IE3): Usuario sin privilegios root
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copiar el binario compilado asignando permisos al usuario no root
COPY --from=build --chown=appuser:appgroup /app/target/*.jar app.jar

# Variables de entorno JVM para optimizar consumo de memoria en contenedores
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -Djava.security.egd=file:/dev/./urandom"

# Ejecutar como usuario no privilegiado
USER appuser:appgroup

# Puerto expuesto por el microservicio Spring Boot
EXPOSE 8080

# Verificación de salud integrada (Healthcheck nativo)
HEALTHCHECK --interval=30s --timeout=5s --start-period=25s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/v3/api-docs || exit 1

# Comando de inicio asegurando paso de flags de memoria y soporte de señales
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
