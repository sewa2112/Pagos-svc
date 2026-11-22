# Modulo de Cumplimiento Normativo y Auditoria — Carpeta audit/ (IE5)

Esta carpeta centraliza los artefactos, scripts y politicas de gobernanza exigidos en la **Evaluacion Parcial N°3 (DOY0101)**, estructurados en tres vias complementarias:

---

## Estructura del Modulo \`audit/\`

```
audit/
├── compliance-audit.sh        # Script automatizado de auditoria normativa (12 reglas CIS/OWASP)
├── branch-protection.md       # Politica formal de proteccion de ramas y Code Review (GitHub)
├── sonar-quality-gate.md      # Especificacion de metricas y compuertas de calidad SonarQube
└── README.md                  # Indice del modulo de cumplimiento y trazabilidad
```

---

## Las Tres Vias de Cumplimiento (IE5)

1. **Via 1: Quality Gate Automatizado (SonarQube & JaCoCo):**
   - Cobertura de codigo estricta (100% LINE).
   - Bloqueo automatico ante deuda tecnica, code smells o vulnerabilidades.
2. **Via 2: Reglas de Branch Protection en GitHub:**
   - Prohibicion de pushes directos a \`main\` y \`develop\`.
   - Obligatoriedad de revision de pares (minimo 1 aprobacion).
   - Aprobacion forzosa de los status checks de CI/CD antes del merge.
3. **Via 3: Auditoria Propia con Script Automatizado (\`compliance-audit.sh\`):**
   - Evalua 12 reglas de estandares CIS Docker Benchmark, NIST SP 800-190 y OWASP.
   - Detiene el pipeline con \`exit 1\` ante secretos en texto plano, contenedores root o falta de limites de recursos en Kubernetes (IE6).
