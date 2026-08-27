# language: es
Característica: Servicio Pagos (microservicio pagos del caso caso06)
  Los escenarios validan el contrato REST del microservicio alineado a sus endpoints.

  Escenario: el listado del recurso responde 200
    Dado el servicio "Pagos" está disponible
    Cuando consulto el listado de "pagos"
    Entonces el listado responde con código 200

  Escenario: ciclo de vida completo del recurso
    Dado un nuevo "pago" con nombre "hola-cucumber"
    Cuando consulto el "pago" recién creado
    Entonces el recurso tiene nombre "hola-cucumber" y código 200
    Cuando actualizo el "pago" con nombre "cucumber-actualizado"
    Entonces el recurso queda con nombre "cucumber-actualizado" y código 200
    Cuando elimino el "pago"
    Entonces la eliminación responde con código 204
    Y al consultar el "pago" eliminado responde 404
