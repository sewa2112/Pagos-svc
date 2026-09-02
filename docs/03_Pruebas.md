# Pagos — Estrategia de pruebas

## Pruebas unitarias (cobertura JaCoCo 100% LINE)

- **`PagoServiceTest`** — prueba de servicio con Mockito: listar, obtener, crear, actualizar (presente y ausente) y eliminar (presente y ausente).
- **`PagoControllerTest`** — prueba del contrato HTTP con `MockMvc`: 200/404/201/201·400/204 en todas las ramas.
- **`OpenApiConfigTest`** — verifica la metadata OpenAPI.

## BDD con Cucumber (alineado a endpoints)

- **Features**: `src/test/resources/cucumber/pagos.feature`
- **Runner**: `cucumber/CucumberRunnerTest` (JUnit Platform)
- **Contexto**: `cucumber/CucumberSpringConfiguration` (arranca el servidor en puerto aleatorio)
- **Steps**: `cucumber/PagoSteps` — llama a los endpoints reales vía `TestRestTemplate`

Escenarios:

1. El listado del recurso responde 200.
2. Ciclo de vida completo: crear (201) → consultar (200) → actualizar (200) → eliminar (204) → consultar eliminado (404).

## Comandos

```bash
mvn test -q                 # ejecuta unit tests + Cucumber
mvn verify -q               # además verifica cobertura JaCoCo (100% LINE, fracasa si baja)
open target/site/jacoco/index.html
open target/cucumber/cucumber.html   # reporte Cucumber
```
