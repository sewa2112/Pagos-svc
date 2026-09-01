# Pagos — Microservicio de riesgo pagos

Microservicio correspondiente al **caso caso06 — ViajaMejor** (Reservas de viajes) de la Evaluación Parcial N°1.

| | |
|---|---|
| Asignatura | JVY0101 — Java: Diseño y Construcción de Soluciones Nativas en Nube |
| Stack | Spring Boot 3.3 · Java 21 · Maven · Spring Data JPA · H2 · springdoc-openapi |
| Calidad | JaCoCo cobertura LINE 100% · Cucumber (BDD) alineado a endpoints REST |
| Entrega | Docker / Docker Compose |

## Responsabilidad (SRP)

administra los datos y la lógica del dominio de Pagos del caso caso06 (ViajaMejor). Su base de datos es una **H2 en memoria** (un solo microservicio por base), cumpliendo aislamiento de datos por dominio.

## Página de presentación

Al ejecutar el servicio, `http://localhost:8080/` muestra la página de presentación del microservicio con documentación y enlaces a:

- **Swagger UI**: `/swagger-ui/index.html`
- **OpenAPI (yaml)**: `/v3/api-docs.yaml`
- **ReDoc**: `/redoc.html`
- **H2 Console**: `/h2-console`

## Endpoints

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/api/pagos` | Lista todos los recursos |
| GET | `/api/pagos/{id}` | Obtiene un recurso por id |
| POST | `/api/pagos` | Crea un recurso |
| PUT | `/api/pagos/{id}` | Actualiza un recurso |
| DELETE | `/api/pagos/{id}` | Elimina un recurso |

## Documentación del proyecto

La documentación completa está en la carpeta [`docs/`](docs/):

- [`docs/00_Resumen.md`](docs/00_Resumen.md) — propósito, responsabilidad y tecnologías
- [`docs/01_Arquitectura.md`](docs/01_Arquitectura.md) — componentes, arquitectura y patrones
- [`docs/02_API.md`](docs/02_API.md) — contrato REST y ejemplos curl
- [`docs/03_Pruebas.md`](docs/03_Pruebas.md) — tests unitarios, cobertura y Cucumber
- [`docs/04_Despliegue.md`](docs/04_Despliegue.md)
- [`docs/05_Justificacion.md`](docs/05_Justificacion.md) — justificación del servicio: RF/RNF/seguridad cubiertos, stack y por qué cada tecnología AWS
- [`docs/diagramas/`](docs/diagramas/) — C4 (contexto, contenedores, componentes), secuencia e infraestructura AWS — Docker, Docker Compose e integración

## Cómo ejecutar locmente

```bash
mvn spring-boot:run
```

## Cómo ejecutar con Docker

```bash
docker compose up --build
# http://localhost:8080
```

## Cómo ejecutar las pruebas

```bash
mvn test      # unit tests + Cucumber
mvn verify    # + verificación de cobertura JaCoCo (100% LINE, falla si baja)
```
## Elección y Justificación de ramificación

Como equipo hemos decidido implementar la estrategia GitFlow, siendo concientes de que en casos como estos desarrollos "pequeños y de cortos periodos de desarrollo para arreglos y funciones" sería teoricamente correcto usar Trunk-Based, pero existen 2 factores que marcaron el camino a la elección. 

En primer lugar está la experiencia previa al usar GitFlow, desde nuestros primeros proyectos en conjunto, lo hicimos usando esta estrategia, pero no solo porque nos lo enseñó nuestro profe, sino porque facilita y hace el desarrollo en conjunto más seguro. 

El segundo punto sería que precisamente por las dimenciones del proyecto y del equipo de desarrollo, se mitigan las principales carencias de la estrategia, como lo serían la alta dificultad al gestionar las ramas y los conflictos de fusión masivos con las ramas feature demasiado longevas.

Para dar conclusión a este apartado sintetizaremos la respuesta a que de tratarse de un proyecto serio y de tener un personal más abundante, la respuesta sería escojer Trunk-based, la cual favorece el desarrollo y entrega de feedback de manera agil. Pero en nuestro caso es más bien lo contrario, teniendo un equipo de solo 2 personas y un proyecto pequeño, por lo que nos resulta optimo usar GitFlow para el searrollo de este proyecto.

# Convenciones y Buenas Prácticas del Proyecto

## 1. Flujo de Trabajo (Git Workflow)
* **`main`:** Código principal o mejor conocido como ""producción"". Solo puede mezclarsen con las ramas  `develop` y o `hotfix/`.
* **`develop`:** Rama de desarrollo para integrar nuevas funciones o cambios de la rama main para la próxima versión.
* **Nomenclatura de ramas:**
  * `feature/ID-descripcion` (ej. `feature/JIRA-123-login`)
  * `bugfix/ID-descripcion`
  * `hotfix/ID-descripcion`

## 2. Convenciones de Commits
Seguimos el estándar de Conventional Commits:
* `feat:` Nueva función funcionalidades.
* `fix:` Correción del código.
* `docs:` Cambios o adiciones de la documentación.
* `chore:` Todo lo que tenga que ver con el mantenimiento del código y en nuestro caso para agrtegar el workflow del hola mundo.


## 3. Proceso de Revisión de Código y Pull Requests
* Ningún desarrollador debe hacer push directo a `develop` o `main`.
* Todo PR requiere al menos 1 revisor asignado.
* Eliminar la rama temporal inmediatamente después del merge.