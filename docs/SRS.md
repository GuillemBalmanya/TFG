
# SRS - Pipeline de Dades per a Data Warehouse Oracle

**Promotor:** Departament de Govern de la Dada (UAB)

**Autor:** Estudiant (TFG)

**Data:** 16/02/2026

## 1. Propòsit i objectius
Dissenyar i implementar un pipeline que extregui dades d'una plataforma d'investigació, les transformi (XML->JSON si cal), les validi i les carregui al DW Oracle. Ha de ser auditable i preparar conjunts per a ús AI.

## 2. Abast
Inclou prototip funcional i informe de viabilitat ORI/alternatives. Exclou desplegament complet de producció.

## 3. Requisits (resum)
- Ingesta: suport XML i JSON, detecció automàtica.
- Validació: XSD / JSON Schema.
- Transformació: mapatge i normalització.
- Càrrega: staging i updates a Oracle.
- Monitoratge i alertes.

## 4. Preguntes clau per als responsables
1. Nom i tecnologia de la plataforma origen.
2. Accés i dades disponibles (esquemes, volums, freqüència).
3. Claus d'accés i permisos.
4. Programar reunió tècnica.

