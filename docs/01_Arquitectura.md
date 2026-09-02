# Pagos — Arquitectura del microservicio

## Componentes

| Componente | Rol |
|---|---|
| `PagoApplication` | Punto de entrada Spring Boot |
| `controller/PagoController.java` | API REST expuesta en `/api/pagos` |
| `service/PagoService.java` | Lógica de negocio y transacciones |
| `repository/PagoRepository.java` | Acceso JPA a H2 |
| `model/Pago.java` | Entidad persistida en tablas H2 |
| `config/OpenApiConfig.java` | Metadata OpenAPI del servicio |
| `static/index.html` | Página de presentación en `/` |
| `static/redoc.html` | Referencia ReDoc de la API |

## Principios aplicados

- **Responsabilidad Única (SRP)**: un dominio por servicio.
- **Bajo acoplamiento**: interactúa con otros microservicios por API/eventos, nunca por tablas compartidas.
- **Alta cohesión**: todas sus capacidades pertenecen al mismo dominio de negocio.
- **Disponibilidad/mantenibilidad local**: código, tests y despliegue independientes.

## Patrones de diseño (en el contexto del diagrama EP01)

En el diagrama general del caso este microservicio participa de:

- **API Gateway**: única puerta de entrada a todos los microservicios.
- **Service Registry**: descubrimiento dinámico de instancias.
- **Circuit Breaker**: aislamiento ante la caída de dependencias externas (pagos, integraciones).
- **Colas (AWS SQS)**: comunicación asíncrona de eventos entre servicios.
- **Funciones serverless (AWS Lambda)**: procesamiento eventual (notificaciones, reportes, analítica).

## Diagrama de la API (flujo)

`Cliente/Sistema → API Gateway → PagoController → PagoService → PagoRepository → H2`
