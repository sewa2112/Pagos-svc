# Configuracion y Politicas de Quality Gate con SonarQube — IE5

El analisis de codigo estatico, seguridad y deuda tecnica se gestiona mediante la integracion de **SonarQube / SonarCloud**, gobernado por el archivo de configuracion [`sonar-project.properties`](../sonar-project.properties).

---

## 1. Parametros de Configuracion del Proyecto

```properties
sonar.projectKey=sewa2112_Pagos-svc
sonar.projectName=Pagos | Microservicio Pagos (caso06 - ViajaMejor)
sonar.projectVersion=1.0.0
sonar.sourceEncoding=UTF-8
sonar.sources=src/main/java
sonar.tests=src/test/java
sonar.java.binaries=target/classes
sonar.java.test.binaries=target/test-classes
sonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
sonar.junit.reportPaths=target/surefire-reports
sonar.exclusions=**/*Application.java,**/config/**
sonar.coverage.exclusions=**/*Application.java,**/config/**
sonar.qualitygate.wait=true
```

---

## 2. Umbrales del Quality Gate de SonarQube (IE5 & IE6)

Para que una rama o Pull Request obtenga la certificacion de calidad de SonarQube, debe cumplir obligatoriamente con los siguientes umbrales:

| Metrica Evaluada | Condicion de Calidad | Comportamiento ante Incumplimiento |
|---|---|---|
| **Coverage on New Code** | $\ge 80.0\%$ (Internamente exigido 100% por JaCoCo) | Falla Quality Gate $\rightarrow$ Detiene pipeline (exit code 1) |
| **Duplicated Lines on New Code** | $\le 3.0\%$ | Falla Quality Gate |
| **Maintainability Rating** | Grado A (Technical Debt Ratio $< 5\%$) | Falla Quality Gate |
| **Reliability Rating (Bugs)** | Grado A (0 Bugs criticos o mayores) | Falla Quality Gate $\rightarrow$ Bloquea despliegue |
| **Security Rating (Vulnerabilities)** | Grado A (0 Vulnerabilidades abiertas) | Falla Quality Gate $\rightarrow$ Bloquea despliegue |
| **Security Hotspots Reviewed** | $100\%$ revisados y aprobados | Falla Quality Gate |
