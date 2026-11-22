# Politica de Proteccion de Ramas (Branch Protection Rules) — IE5

En cumplimiento con los estandares de gobernanza de software y el modelo GitFlow del proyecto **Pagos (caso06 - ViajaMejor)**, se establecen reglas estrictas de proteccion para las ramas principales (`main` y `develop`).

---

## 1. Reglas Configuradas en el Repositorio de GitHub

| Regla de Proteccion | Rama \`main\` (Produccion) | Rama \`develop\` (Staging/Dev) | Proposito de Gobernanza |
|---|---|---|---|
| **Require a pull request before merging** | Activado | Activado | Impide que cualquier desarrollador realice commits o \`git push\` directos. Todo cambio debe ser trazable a un PR. |
| **Require approvals** | Minimo 1 aprobador | Minimo 1 aprobador | Garantiza la revision cruzada de codigo (Code Review) entre integrantes del equipo. |
| **Dismiss stale pull request approvals** | Activado | Activado | Invalida aprobaciones previas si se empujan nuevos commits a la rama del PR. |
| **Require status checks to pass before merging** | Activado | Activado | El PR solo puede fusionarse si todos los Quality Gates de CI/CD terminan en verde. |
| **Status checks obligatorios requeridos** | \`test-and-coverage\`, \`compliance-and-security\` | \`test-and-coverage\`, \`compliance-and-security\` | Bloquea la integracion si fallan pruebas (JaCoCo 100%), auditoria normativa o escaneo de seguridad. |
| **Require conversation resolution before merging** | Activado | Activado | Obliga a resolver todos los comentarios y observaciones de auditoria en el PR. |
| **Do not allow bypassing the above settings** | Activado (incluye administradores) | Activado | Gobernanza estricta sin privilegios de bypass. |

---

## 2. Flujo de Trabajo Protegido

```
[Desarrollador en feature/ID]
             |
             | git push
             v
[Pull Request en GitHub]
             |
             +---> Ejecuta CI/CD Pipeline (4 etapas)
             |     - Pruebas + JaCoCo 100%
             |     - Auditoria scripts/compliance-audit.sh
             |     - Escaneo Snyk / Trivy
             |
             +---> Requiere Revision de Par (1 Reviewer)
             |
             v
¿Todos los Checks en Verde y PR Aprobado?
  |-- NO  --> [BLOQUEADO / MERGE DISABLED]
  \-- SI  --> [MERGE PERMITIDO hacia develop / main]
```
