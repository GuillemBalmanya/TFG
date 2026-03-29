# Context de Sessió — Ingesta Pure API (JSON) via ODI/Jython

**Última actualització**: 28 de març de 2026
**Projecte**: TFG — Migració d'Ingesta XML a JSON (EGRETA/Pure API)
**Autor del TFG**: Guillem (UAB — Oficina de Govern de les Dades)

---

## 1. Objectiu del Projecte

Migrar el procés actual d'ingesta de dades del sistema CRIS **EGRETA** (Elsevier Pure) que utilitza l'API XML cap a una nova implementació basada en l'**API JSON (v5.30+)**, executant-se dins d'**Oracle Data Integrator (ODI)** mitjançant scripts Jython en procediments ODI.

El primer endpoint objectiu és **`/awards`** (~43.193 registres). El patró resultant ha de ser adaptable a altres endpoints (persons, projects, research-outputs, etc.).

---

## 2. Infraestructura i Restriccions Crítiques

### 2.1 ODI i Jython

| Restricció | Detall |
|---|---|
| **Versió Jython** | **2.5.x** (Python 2.5 sobre JVM). NO és Python 3, ni Jython 2.7 |
| **Sense mòdul `json`** | El mòdul `json` es va afegir a Python 2.6; no existeix a Jython 2.5 |
| **Sense `with` statement** | No suportat. Cal usar `try/finally` per gestionar recursos |
| **Sense f-strings** | Cal usar `%` formatting o `str.format()` (preferir `%`) |
| **Sintaxi except** | `except Exception, e:` (coma), NO `except Exception as e:` |
| **`print` és statement** | `print "text"`, NO `print("text")` |
| **Sense llibreries CPython** | `requests`, `cx_Oracle`, `pandas`, etc. són incompatibles amb JVM |
| **HTTPS amb urllib2 falla** | Jython 2.5 té problemes amb SSL via urllib2; cal usar `java.net.HttpURLConnection` |
| **Connexió BD via JDBC** | Únic mètode: `java.sql.DriverManager.getConnection()` |
| **Límit 100.000 caràcters** | Cada command d'un ODI Procedure té aquest límit; workaround: `execfile()` |
| **Substitució de variables ODI** | Sintaxi `'#GLOBAL.VAR_NAME'` (case-sensitive, strings necessiten cometes externes) |
| **Certificats SSL** | Pot caldre importar el certificat d'EGRETA al JVM truststore amb `keytool` |

### 2.2 Pure API (EGRETA)

| Aspecte | Detall |
|---|---|
| **Autenticació** | Header `api-key` (NO query parameter) |
| **Paginació** | Paràmetres `offset` i `size`; màxim `size=1000` |
| **Versió API** | v5.30+ (JSON) |
| **Base URL** | Definida a la configuració del script (variable `PURE_BASE_URL`) |
| **Endpoint Awards** | `GET /awards?size=1000&offset=0` |
| **Cerca incremental** | `POST /awards/search` amb filtre `modifiedDate` al body JSON |
| **Resposta** | JSON amb camp `items` (array de registres) i `count` (total) |

### 2.3 Estructura de Dades Awards

**Taula pare** (camps escalars i 1:1):
- `uuid`, `pureId`, `externalId`
- `title` (localitzat: `_CA`, `_ES`, `_EN`)
- `type.uri`, `type.term` (localitzat)
- `status`, `workflow`
- `startDate`, `endDate`, `awardDate`
- `amount.value`, `amount.currencyCode`
- `managingOrganisation.uuid`, `.name`
- `createdDate`, `modifiedDate`
- `peerReviewed` (booleà)

**Taules filles** (relacions 1:N):
- **awardHolders**: `person.uuid`, `person.name`, `role`, `organisationalUnit.uuid`
- **fundings**: `fundingSource`, `fundingBody`, `amount`, `currency`
- **identifiers**: `type`, `value` (inclou "ID FENIX" important per la UAB)

**Localització**: Camps de text es desnormalitzen amb sufixos `_CA`, `_ES`, `_EN` (cardinalitat fixa: 3 idiomes UAB).

---

## 3. Decisions de Disseny Documentades

### 3.1 Sistema de Parsing JSON en 3 Nivells (Fallback Automàtic)

1. **Tier 1: `javax.json.*`** — Disponible si l'agent ODI corre sobre WebLogic 12c (Java EE). Parser streaming robust.
2. **Tier 2: `org.json.*`** — Disponible si es col·loca el JAR `json-20231013.jar` a `<ODI_HOME>/oracledi/agent/drivers/`. API senzilla.
3. **Tier 3: `eval()` amb substitucions** — Sempre disponible. Transforma `true→True`, `false→False`, `null→None` i fa `eval()` del string JSON. Funcional però menys robust.

El script detecta automàticament quin tier està disponible a l'inici.

### 3.2 Dual Mode: JDBC Directe vs CSV Intermedi

- **Mode JDBC**: Insert directe via `PreparedStatement` amb batch (commit cada N registres). Més eficient, menys passes.
- **Mode CSV**: Genera fitxers CSV intermedis que després es carreguen amb `SQL*Loader` o un ODI mapping. Útil si l'entorn té restriccions de permisos JDBC o per debugging.

### 3.3 HTTP via Java Nativa

- Usa `java.net.URL` i `java.net.HttpURLConnection` per les crides HTTP (no urllib2).
- Headers: `api-key`, `Accept: application/json`.
- Retry amb backoff exponencial per errors transitoris (429, 5xx).
- Timeout configurable (connexió i lectura).

### 3.4 Paginació i Retry

- Bucle de paginació amb `offset` incremental.
- Retry configurable (per defecte 3 intents) amb backoff exponencial.
- Gestió d'errors HTTP amb missatges descriptius.

---

## 4. Fitxers Generats

### 4.1 `ingesta_awards_odi.py` (1.440 línies)

Script Jython 2.5.x complet organitzat en 4 seccions:

| Secció | Línies aprox. | Contingut |
|---|---|---|
| **1. Configuració** | 1-80 | Variables de connexió (Pure API, Oracle JDBC), noms de taules, paràmetres |
| **2. Imports i Detecció de Tier** | 81-160 | Imports Java, detecció automàtica del parser JSON disponible |
| **3. Funcions Helper** | 161-900 | 21 funcions: HTTP, parsing, aplanament, JDBC, CSV, logging |
| **4. Execució Principal** | 901-1440 | Flux main: paginació → parsing → flatten → insert/CSV → estadístiques |

**Funcions principals**:
- `log_msg(msg)` — Logging amb timestamp
- `fer_peticio_http(url)` — Petició HTTP amb retry/backoff
- `parsejar_json_tier1/2/3(text)` — Parsers per cada tier
- `parsejar_json(text)` — Dispatcher automàtic
- `obtenir_valor(obj, path)` — Accés a camps niuats amb notació punt
- `obtenir_localitzat(obj, camp)` — Extreu _CA/_ES/_EN d'un camp localitzat
- `aplanar_award(award)` — Converteix un award JSON a dict pla per la taula pare
- `extreure_fills_holders/fundings/identifiers(award)` — Extreu registres de taules filles
- `inserir_batch_jdbc(conn, taula, columnes, registres)` — Insert batch via PreparedStatement
- `escriure_csv(filepath, columnes, registres)` — Genera CSV
- `executar_ingesta()` — Funció principal d'orquestració

### 4.2 `guia_ingesta_python_odi.md` (1.529 línies)

Guia completa en català amb 11 seccions:

| Secció | Contingut |
|---|---|
| **1. Introducció** | Context del TFG, objectius, abast |
| **2. Prerequisits** | Software, accesos, JARs necessaris |
| **3. Decisions de Disseny** | Justificació tècnica de cada elecció |
| **4. Pas a Pas ODI Studio** | Instruccions UI exactes per a principiants (menús, pestanyes, botons) |
| **5. Documentació del Codi** | Explicació detallada de cada funció, signatura, objectiu, raonament |
| **6. Mode JDBC** | Configuració i ús del mode d'inserció directa |
| **7. Mode CSV** | Configuració i ús del mode de generació de fitxers |
| **8. Càrrega Incremental** | Disseny per Phase 4 (POST /awards/search + MERGE) — plantejament teòric |
| **9. Troubleshooting** | 11 problemes comuns amb diagnòstic i solució |
| **10. Validació SQL** | Queries per verificar la ingesta |
| **11. Referències** | Documentació Pure API, ODI, Jython |

### 4.3 `context.md.txt` (818 línies)

Document original de context del TFG proporcionat per l'usuari. Conté:
- Descripció de la infraestructura UAB
- Documentació de l'API Pure
- Disseny del pipeline XML actual
- Objectius i metodologia del TFG
- Exemples de respostes JSON

### 4.4 `response.json`

Fitxer d'exemple de resposta JSON de l'API Pure (endpoint awards). Usat com a referència per l'estructura de dades.

---

## 5. Estat Actual i Pròxims Passos

### ✅ Completat
- [x] Lectura i anàlisi del document de context (`context.md.txt`)
- [x] Investigació de restriccions ODI/Jython (versions, limitacions, workarounds)
- [x] Investigació de l'API Pure (autenticació, paginació, estructura de resposta)
- [x] Creació del script Jython complet (`ingesta_awards_odi.py`)
- [x] Creació de la guia completa en català (`guia_ingesta_python_odi.md`)
- [x] Verificació de consistència entre script i guia

### 🔲 Pendent (per pròximes sessions)
- [ ] **Adaptar a l'esquema BCK real**: Quan l'usuari proporcioni els noms reals de columnes i taules BCK, actualitzar els mappings del script
- [ ] **Càrrega incremental (Phase 4)**: Implementar el variant amb `POST /awards/search` + filtre `modifiedDate` + lògica MERGE/UPSERT
- [ ] **Adaptar a altres endpoints**: Crear scripts per persons, projects, research-outputs (cal conèixer l'estructura JSON de cada un)
- [ ] **Test en entorn ODI real**: L'usuari provarà el script en el seu entorn ODI i reportarà errors o ajustos necessaris
- [ ] **Benchmark de rendiment**: Comparar temps d'execució amb el pipeline XML actual
- [ ] **Gestió de certificats SSL**: Documentar el procés exacte d'importació del certificat EGRETA al truststore JVM de l'entorn ODI concret

---

## 6. Notes per a Futures Sessions

### Com reprendre el treball:
1. Llegir aquest fitxer (`session_context.md`) per recuperar tot el context
2. Els fitxers generats estan a `/home/guillem/Downloads/`
3. El document original del TFG és `context.md.txt`

### Instruccions de l'usuari:
- **Idioma**: Tota la documentació ha de ser en **català**. Comentaris del codi també en català.
- **Context d'execució**: El script s'executa dins d'ODI com a pas de Procediment Jython (no standalone)
- **Nivell de l'usuari**: Mai ha usat ODI abans; incloure passos UI exactes
- **Modes de càrrega**: Documentar tant JDBC directe com CSV intermedi
- **Esquema de taules**: L'usuari té taules BCK existents; proporcionar plantilla adaptable, no DDL fix

### Possibles problemes a l'entorn real:
1. **Quin tier JSON està disponible?** — L'usuari haurà de provar i reportar
2. **Permisos JDBC** — Pot necessitar credencials específiques per les taules BCK
3. **Ruta del fitxer script** — Cal decidir on desplegar `ingesta_awards_odi.py` al servidor ODI (per `execfile()`)
4. **Certificat SSL** — Quasi segur que caldrà importar-lo; depèn de l'entorn concret
5. **Nom exacte de les taules BCK** — Caldrà actualitzar la configuració del script amb els noms reals

---

## 7. Investigació Tècnica Detallada

### 7.1 Per què Jython 2.5 i no una versió més nova?

ODI 11g i 12c inclouen Jython 2.5.x com a motor d'scripting integrat. Actualitzar-lo no és trivial ni suportat per Oracle. L'agent ODI carrega el JAR de Jython al seu classpath i no es pot substituir fàcilment.

### 7.2 Per què `java.net.HttpURLConnection` i no `urllib2`?

Jython 2.5 té problemes amb la gestió de certificats SSL quan usa `urllib2`. La implementació Java nativa (`HttpURLConnection`) utilitza el truststore JVM estàndard i funciona correctament amb HTTPS si el certificat és vàlid o s'ha importat.

### 7.3 Per què batch inserts amb PreparedStatement?

- `Statement` amb SQL concatenat és vulnerable a SQL injection i problemes d'encoding
- `PreparedStatement` gestiona correctament tipus NULL, caràcters especials, i dates
- `addBatch()` + `executeBatch()` redueix round-trips a la BD significativament
- Commit cada N registres (configurable) equilibra rendiment i ús de memòria

### 7.4 Per què desnormalitzar idiomes amb sufixos _CA/_ES/_EN?

L'esquema BCK actual utilitza aquest patró (heretat del pipeline XML). Mantenir la mateixa estructura facilita la migració i la compatibilitat amb processos downstream existents. Si en el futur es vol normalitzar, es pot crear una taula de traduccions, però no és l'objectiu d'aquest TFG.

### 7.5 Sobre el límit de 100.000 caràcters

Cada "Command" dins d'un ODI Procedure Step té un límit de ~100.000 caràcters. El nostre script (1.440 línies) supera aquest límit si es pega directament. La solució és:
1. Desar el fitxer `.py` al servidor de l'agent ODI
2. Al command ODI, posar només: `execfile('/ruta/al/servidor/ingesta_awards_odi.py')`
3. Això carrega i executa el fitxer extern sense limitació de mida

---

*Fi del document de context de sessió*
