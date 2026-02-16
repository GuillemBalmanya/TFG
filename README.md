### TFG
## Author: Guillem Balmanya Bocigas (1671206@uab.cat)
## Tutor: Antonio Espinosa Morales (AntonioMiguel.Espinosa@uab.cat) i Rafa Alarcón

Aquest repositori conté el desenvolupament del Treball Final de Grau (TFG) consistent en el disseny i implementació d’un pipeline de dades per integrar informació procedent d’una plataforma d’investigació cap al Data Warehouse Oracle de la UAB.

El projecte contempla:

Ingestió de dades en format XML i JSON

Validació mitjançant esquemes (XSD / JSON Schema)

Transformació i normalització segons el model del DW

Càrrega controlada i auditable a Oracle

Arquitectura modular i escalable

Preparació de conjunts de dades “AI-ready”

Documentació tècnica i especificació formal (SRS)

L’objectiu és construir una solució robusta, mantenible i extensible que pugui evolucionar cap a funcionalitats avançades com millores d’infraestructura o integracions futures.

# 🎯 Objectius tècnics

Garantir integritat i qualitat de dades

Permetre reprocessat idempotent

Facilitar monitoratge i traçabilitat

Assegurar compatibilitat amb l’ecosistema Oracle

Proporcionar base per a futurs desenvolupaments analítics

# 🏗 Arquitectura general

El projecte segueix una arquitectura modular:

Ingestor – Connexió amb la plataforma origen

Validador – Comprovació d’esquemes

Transformador – Mapatge i conversió XML→JSON si cal

Staging – Zona intermèdia de càrrega

Loader – Inserció/actualització al DW Oracle

Monitoratge – Logs i control d’execució

# 📁 Estructura del repositori
tfg_pipeline_repo/
│
├── docs/            # Documentació (SRS i annexos)
├── scripts/         # Scripts d’ingesta, transformació i càrrega
├── src/             # Mòduls reutilitzables del pipeline
├── tests/           # Tests unitaris i d’integració
├── requirements.txt # Dependències
├── .gitignore
└── README.md

# 🔐 Consideracions de seguretat

No s’inclouen credencials reals

Gestió de secrets mitjançant variables d’entorn

Compliment de bones pràctiques de seguretat

# 🚀 Estat del projecte

🔹 Fase actual: Definició d'objectius
🔹 Pendent: Validació d'objectius

📄 Documentació associada

Especificació SRS (document formal)

# Guia d’ús i configuració

# Informe de viabilitat tecnològica
