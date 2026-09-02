# Pagos — Despliegue y operación

## Requisitos

- Java 21, Maven 3.9 (build local)
- Docker + Docker Compose (despliegue)

## Ejecución local

```bash
mvn spring-boot:run
```

URLs en `http://localhost:8080`:

| Recurso | URL |
|---------|-----|
| Página de presentación | `/` |
| Swagger UI | `/swagger-ui/index.html` |
| OpenAPI yaml | `/v3/api-docs.yaml` |
| ReDoc | `/redoc.html` |
| H2 Console | `/h2-console` |
| API base | `/api/pagos` |

## Docker

```bash
docker build -t duoc/jv0101-caso06-pagos:1.0.0 .
docker run -p 8080:8080 duoc/jv0101-caso06-pagos:1.0.0
```

## Docker Compose

```bash
docker compose up --build
PORT=9090 docker compose up --build   # cambiar puerto host
```

## Base de datos

H2 en memoria (se pierde al detener el contenedor), configurable en `src/main/resources/application.yml`. Consola web en `/h2-console` (JDBC URL, usuario `sa`, sin clave).

## Variables de entorno

| Variable | Defecto | Descripción |
|----------|---------|-------------|
| `PORT` | `8080` | Puerto del servidor y mapeo del contenedor |
