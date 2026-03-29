# Guia d'Ingesta de Dades d'Awards amb Python (Jython) dins d'ODI

**Projecte:** TFG — Universitat Autonoma de Barcelona  
**Context:** Oficina de Govern de les Dades — Migracio XML a JSON  
**Endpoint:** Pure API (EGRETA) — `/awards`  
**Fitxer de codi:** `ingesta_awards_odi.py`  
**Data:** Marc 2026

---

## Taula de Continguts

1. [Introduccio](#1-introduccio)
2. [Prerequisits](#2-prerequisits)
3. [Decisions de Disseny i Limitacions de la Infraestructura](#3-decisions-de-disseny-i-limitacions-de-la-infraestructura)
4. [Pas a Pas: Configuracio a ODI](#4-pas-a-pas-configuracio-a-odi)
5. [Documentacio Detallada del Codi](#5-documentacio-detallada-del-codi)
6. [Opcio A: Insercio Directa a BCK via JDBC](#6-opcio-a-insercio-directa-a-bck-via-jdbc)
7. [Opcio B: Generacio CSV + Carrega amb LKM](#7-opcio-b-generacio-csv-carrega-amb-lkm)
8. [Carrega Incremental](#8-carrega-incremental)
9. [Problemes Comuns i Solucions](#9-problemes-comuns-i-solucions)
10. [Validacio](#10-validacio)
11. [Referències](#11-referencies)

---

## 1. Introduccio

### 1.1 Context

Aquest document acompanya el fitxer `ingesta_awards_odi.py` i forma part del Treball de Final de Grau desenvolupat a la UAB en el marc de l'Oficina de Govern de les Dades.

L'any 2021, la Universitat va unificar els seus projectes de recerca sota el CRIS d'Elsevier (EGRETA). Actualment, la ingesta de dades de recerca al Data Warehouse (DW) es realitza mitjancant:

1. Crides a la Pure API (que retorna XML)
2. Transformacio XML -> CSV amb Saxon (XSLT)
3. Carrega a les taules de staging (BCK) amb ODI

Elsevier ha anunciat que en un futur les dades **nomes estaran disponibles en format JSON** (context.md, linia 37). Per tant, cal adaptar el proces d'ingesta.

### 1.2 Per que Python (Jython) dins d'ODI?

El context.md (linies 624-676) identifica quatre possibles solucions:

| Opcio | Eines externes | Complexitat | Dependencia |
|-------|---------------|-------------|-------------|
| 1. Saxon XSLT 3.0 | Saxon | Baixa (modifica plantilles) | Mante Saxon |
| 2. ODI natiu (nXSD) | Cap | Alta (driver nXSD complex) | Nomes ODI |
| **3. Python/Jython dins ODI** | **Cap** | **Mitjana** | **Nomes ODI** |
| 4. jq (linia de comandes) | jq | Baixa | Afegeix jq |

**L'opcio 3 es la escollida** per aquest template perque:
- **No requereix eines externes**: el codi s'executa dins de l'agent ODI existent
- **Flexibilitat**: Python/Jython permet gestionar JSON complex amb logica programatica
- **Mantenibilitat**: el codi es llegible i modificable per qualsevol desenvolupador
- **Eliminacio de Saxon**: redueix la dependencia d'eines externes (objectiu del TFG)
- **Dualitat JDBC/CSV**: suporta insercio directa o generacio de fitxers intermedis

### 1.3 Que fa aquest template?

El script `ingesta_awards_odi.py`:

1. **Connecta** a la Pure API (EGRETA) amb autenticacio per API key
2. **Descarrega** tots els awards amb paginacio automatica (1000 per pagina)
3. **Parseja** el JSON amb deteccio automatica de la biblioteca disponible
4. **Aplana** l'estructura niada en files per a taules relacionals:
   - Taula pare: `BCK_PURE_AWARD` (1 fila per award)
   - Taula filla: `BCK_PURE_AWARD_HOLDER` (titulars de l'ajut)
   - Taula filla: `BCK_PURE_AWARD_FUNDING` (financaments)
   - Taula filla: `BCK_PURE_AWARD_IDENTIFIER` (identificadors, incl. ID FENIX)
5. **Carrega** les dades a Oracle via JDBC (mode JDBC) o genera fitxers CSV (mode CSV)
6. **Registra** el progres, errors i metriques al log de sessio d'ODI

---

## 2. Prerequisits

### 2.1 API Key de Pure

- **Obtencio**: contactar l'administrador de Pure/EGRETA a la UAB
- **Tipus**: string alfanumeric (ex: `271e580b-4073-463f-a91a-65f625783275`)
- **Autenticacio**: s'envia com a **header HTTP** `api-key` (no com a query parameter)
- **Permisos necessaris**: lectura (GET) a l'endpoint `/awards`
- **Referencia**: https://api.elsevierpure.com/ws/api/documentation/index.html (Security)

**Verificacio rapida** amb Postman o curl:
```
curl -H "api-key: LA_TEVA_API_KEY" \
     -H "Accept: application/json" \
     "https://egreta.uab.cat/ws/api/awards?size=1&offset=0"
```
Si retorna un JSON amb `"count": 43193`, la clau funciona correctament.

### 2.2 ODI Studio i Agent

- **Versio**: ODI 12c (12.2.1.4) o ODI 14c
- **Components necessaris**:
  - ODI Studio (per crear procediments, paquets i variables)
  - Agent ODI en execucio (Standalone o Java EE sobre WebLogic)
- **Connectivitat de xarxa**: l'agent ha de poder arribar a `egreta.uab.cat` port 443 (HTTPS)
- **Verificacio**: des del servidor de l'agent, executar:
  ```
  curl -I https://egreta.uab.cat/ws/api/awards
  ```
  Ha de retornar `HTTP/1.1 401` o `200` (no connection refused).

### 2.3 Base de Dades Oracle (BCK)

- **Connectivitat JDBC**: URL, usuari, password amb permisos INSERT sobre les taules BCK
- **Format JDBC URL**: `jdbc:oracle:thin:@//hostname:1521/service_name`
- **Permisos necessaris**: INSERT, SELECT, i TRUNCATE sobre les taules de staging
- **Character set**: recomanat `AL32UTF8` per suportar caracters catalans (c, accents)

### 2.4 (Opcional) JAR JSON-java

Si l'agent ODI **no** corre sobre WebLogic (agent standalone pur), pot ser que `javax.json.*` no estigui disponible. En aquest cas:

1. **Descarregar** `json-20231013.jar` (o versio mes recent) des de:
   https://search.maven.org/artifact/org.json/json
2. **Copiar** el JAR a: `<ODI_HOME>/oracledi/agent/drivers/`
3. **Reiniciar** l'agent ODI

**Nota**: El script detecta automaticament quin parser esta disponible. Si cap dels dos (javax.json ni org.json) esta al classpath, usara `eval()` com a fallback (veure seccio 3.3).

---

## 3. Decisions de Disseny i Limitacions de la Infraestructura

Aquesta seccio es **critica** per entendre per que el codi esta escrit d'una manera que pot semblar inusual per a un desenvolupador Python modern. La infraestructura ODI imposa restriccions severes que condicionen totes les decisions tecniques.

### 3.1 Per que Jython 2.5 i no Python 3

**ODI 12c inclou Jython 2.5.x** (concretament 2.5.1 o 2.5.2 segons el patchset). Jython es una implementacio de Python que corre sobre la Java Virtual Machine (JVM).

**Implicacions directes per al codi:**

| Caracteristica | Python 3 | Jython 2.5 (ODI) | Impacte al template |
|----------------|----------|-------------------|---------------------|
| `print` | Funcio: `print("hola")` | Statement: `print "hola"` | Tot el logging usa `print` sense parentesis |
| `with` statement | Disponible | **NO disponible** | Usem `try/finally` per gestionar recursos |
| f-strings | `f"valor: {x}"` | **NO disponible** | Usem `%` formatting: `"valor: %s" % x` |
| Modul `json` | Integrat | **NO existeix** (afegit a 2.6) | Usem classes Java (veure 3.3) |
| `except as` | `except Exception as e:` | `except Exception, e:` | Sintaxi antiga amb coma |
| `str` | Unicode per defecte | Bytes per defecte | Especifiquem UTF-8 explicitament |
| Diccionaris | Ordenats (3.7+) | **NO ordenats** | No depenem de l'ordre de les claus |

**Per que no es pot actualitzar Jython?**  
Jython ve incrustat dins la instal·lacio d'ODI. Actualitzar-lo requeriria modificar fitxers interns d'Oracle, cosa que:
- Invalida el suport oficial d'Oracle
- Podria trencar altres funcionalitats d'ODI
- Es revertida per qualsevol patch o actualitzacio

### 3.2 Per que classes Java i no biblioteques Python

| Necessitat | Solucio Python habitual | Per que no funciona a Jython 2.5 | Solucio al template |
|------------|------------------------|----------------------------------|---------------------|
| Parsejar JSON | `import json` | Modul inexistent (Python 2.5) | `javax.json.*` o `org.json.*` (Java) |
| Peticions HTTP | `import requests` | Paquet CPython, incompatible amb JVM | `java.net.HttpURLConnection` |
| HTTPS segur | `import urllib2` + ssl | urllib2 falla amb HTTPS a Jython 2.5 | `java.net.HttpURLConnection` (Java gestiona SSL) |
| Connexio Oracle | `import cx_Oracle` | Extensio C, incompatible amb JVM | `java.sql.DriverManager` (JDBC) |
| Escriure fitxers | `open("file", "w")` | Funciona pero encoding UTF-8 no fiable | `java.io.BufferedWriter` |

**L'avantatge de Jython**: des de Jython podem importar **qualsevol classe Java** que estigui al classpath de la JVM, com si fos un modul Python. Aixo ens dona acces a tot l'ecosistema Java sense instal·lar res.

### 3.3 Sistema de 3 Tiers per al Parsing JSON

Com que no sabem quin sera l'entorn exacte de l'agent ODI de la UAB, el script implementa un sistema de fallback automatic amb 3 nivells:

```
Inici
  |
  v
Intentar importar javax.json.* ---- Exit --> Tier 1 (javax.json)
  |                                           API estandard Java EE
  | ImportError                               Disponible si agent sobre WebLogic 12c
  v                                           No requereix cap JAR addicional
Intentar importar org.json.* ------ Exit --> Tier 2 (org.json)
  |                                           Biblioteca popular, API senzilla
  | ImportError                               Requereix json-XXXXX.jar al classpath
  v
Tier 3 (eval() fallback)
  Sempre disponible
  Converteix JSON a dict Python via eval()
  Substitucions: true->True, false->False, null->None
  Restriccio builtins per seguretat minima
```

**Com saber quin tier s'esta usant?**  
El log de sessio mostrara a l'inici:
```
[2026-03-28T10:00:00] JSON Parser Tier: 1 - javax.json (JSR 353)
```

**Recomanacio**: si es possible, afegir el JAR `org.json` al classpath (veure 2.4) per garantir el Tier 2 com a minim. El Tier 3 (`eval()`) funciona pero es menys robust amb JSONs que continguin caracters especials en claus.

### 3.4 Model de Dades: Taula Pare + Taules Filles

L'estructura JSON d'un award de Pure es molt niada (objectes dins d'objectes, arrays d'objectes). Per carregar-la a Oracle, hem d'aplanar-la.

**Estrategia d'aplanament:**

| Tipus de relacio | Exemples | Estrategia | Justificacio |
|-----------------|----------|------------|--------------|
| **1:1 simple** | uuid, pureId, awardDate | Columna directa a la taula pare | Camp escalar, trivial |
| **1:1 niat** | managingOrganization, workflow, status | Aplanat a la taula pare amb prefix | Cardinalitat fixa (sempre 0 o 1) |
| **Localitzat** | title, shortTitle | Aplanat amb sufixos _CA, _ES, _EN | Cardinalitat fixa (3 idiomes UAB) |
| **1:N array** | awardHolders[], fundings[], identifiers[] | **Taula filla** amb FK AWARD_UUID | Cardinalitat variable |

**Per que taules filles i no columnes numerades?**

L'alternativa seria crear columnes com `HOLDER_1_UUID`, `HOLDER_2_UUID`, `HOLDER_3_UUID`, etc. Pero:

1. **Cardinalitat desconeguda**: un award pot tenir 1 titular o 20. Quantes columnes creem?
2. **Espai malbaratat**: la majoria d'awards tenen 1-3 holders → les columnes 4-20 serien NULL
3. **Consultes complexes**: `WHERE HOLDER_1_UUID = 'x' OR HOLDER_2_UUID = 'x' OR ...` es feix
4. **Canvis DDL**: si un award te 21 holders, cal ALTER TABLE (canvi d'esquema en produccio)
5. **Viola 1NF**: un model relacional correcte no repeteix grups de columnes

Amb taules filles, una simple `JOIN` resol totes les consultes:
```sql
SELECT a.TITLE_CA, h.PERSON_UUID, h.ACADEMIC_OWNERSHIP_PCT
FROM BCK_PURE_AWARD a
JOIN BCK_PURE_AWARD_HOLDER h ON h.AWARD_UUID = a.AWARD_UUID
WHERE h.ROLE_URI LIKE '%principalInvestigator%'
```

### 3.5 Paginacio i Gestio de Memoria

La Pure API retorna fins a **1000 registres per pagina** (maxim configurable). Amb ~43.193 awards (context.md, linia 363), son ~44 pagines.

**Per que no descarregar-ho tot de cop?**

| Estrategia | Memoria | Recuperabilitat | Risc |
|-----------|---------|-----------------|------|
| Tot de cop | ~200MB+ JSON en un sol string | Si falla, es perd tot | OutOfMemoryError molt probable |
| **Per pagina** | **~5MB per pagina (constant)** | **Si falla la pag. 30, les 0-29 estan commitejades** | **Minim** |

El template processa cada pagina completament (fetch -> parse -> flatten -> insert/write) abans de passar a la seguent. Despres de cada pagina, les dades ja estan a Oracle (commit) o al fitxer CSV (flush), i el garbage collector de Java pot alliberar la memoria de la pagina anterior.

### 3.6 Dues Modalitats de Carrega (JDBC vs CSV)

| Aspecte | Mode JDBC | Mode CSV |
|---------|-----------|----------|
| **Mecanisme** | INSERT directe via PreparedStatement | Genera fitxers .csv |
| **Passes** | 1 (tot en un sol script) | 2 (script + carrega ODI amb LKM) |
| **Depuracio** | Log d'ODI | Pots obrir els CSV i inspeccionar |
| **Rendiment** | Mes rapid (sense I/O a disc) | Mes lent (escriptura + lectura) |
| **Recomanat per a** | **Produccio** | **Proves i desenvolupament** |

Per canviar de mode, simplement canvieu la constant `MODE` a la seccio de configuracio del script:
```python
MODE = 'JDBC'   # o 'CSV'
```

---

## 4. Pas a Pas: Configuracio a ODI

Aquesta seccio esta pensada per a algú que **no ha usat ODI mai**. Cada pas indica el menu, pestanya, camp i boto exacte.

### 4.1 Crear Variables ODI

Les variables ODI permeten parametritzar el script sense modificar el codi. El script referencia les variables amb la sintaxi `'#GLOBAL.NOM_VARIABLE'` que l'agent substitueix pel valor real abans d'executar.

**Navegacio:** ODI Studio > Designer Navigator > **Global Objects** (a la part inferior esquerra) > **Variables** > clic dret > **New Variable**

Crear les seguents 6 variables:

#### Variable 1: PURE_API_URL

| Camp | Valor |
|------|-------|
| **Name** | PURE_API_URL |
| **Datatype** | Alphanumeric |
| **Default Value** | `https://egreta.uab.cat/ws/api/awards` |
| **Keep History** | Latest value |
| **Secure Value** | No (no es dada sensible) |
| **Description** | URL base de l'endpoint Awards de la Pure API |

#### Variable 2: PURE_API_KEY

| Camp | Valor |
|------|-------|
| **Name** | PURE_API_KEY |
| **Datatype** | Alphanumeric |
| **Default Value** | *(la teva API key)* |
| **Keep History** | No History |
| **Secure Value** | **Si** (marcar la casella — evita que aparegui als logs) |
| **Description** | API key per autenticacio a Pure/EGRETA |

#### Variable 3: PURE_PAGE_SIZE

| Camp | Valor |
|------|-------|
| **Name** | PURE_PAGE_SIZE |
| **Datatype** | Numeric |
| **Default Value** | `1000` |
| **Keep History** | Latest value |
| **Description** | Nombre de registres per pagina (max 1000) |

#### Variable 4: BCK_JDBC_URL

| Camp | Valor |
|------|-------|
| **Name** | BCK_JDBC_URL |
| **Datatype** | Alphanumeric |
| **Default Value** | `jdbc:oracle:thin:@//hostname:1521/service_name` |
| **Keep History** | Latest value |
| **Description** | JDBC URL de la base de dades Oracle BCK |

#### Variable 5: BCK_USER

| Camp | Valor |
|------|-------|
| **Name** | BCK_USER |
| **Datatype** | Alphanumeric |
| **Default Value** | *(el teu usuari Oracle)* |
| **Keep History** | Latest value |
| **Description** | Usuari Oracle per a les taules BCK |

#### Variable 6: BCK_PASSWORD

| Camp | Valor |
|------|-------|
| **Name** | BCK_PASSWORD |
| **Datatype** | Alphanumeric |
| **Default Value** | *(el teu password)* |
| **Keep History** | No History |
| **Secure Value** | **Si** |
| **Description** | Password Oracle per a les taules BCK |

**Per cada variable**: despres d'omplir els camps, anar a **File > Save**.

### 4.2 Crear el Procediment

Un procediment ODI es un contenidor de tasques (scripts) que s'executen seqüencialment.

**Pas 1: Crear el procediment**

1. A **Designer Navigator**, expandir el teu projecte
2. Clic dret sobre **Procedures** > **New Procedure**
3. A la pestanya **Definition**:
   - **Name**: `PROC_INGESTA_AWARDS_JSON`
   - **Multi-Connections**: NO marcar (el script gestiona la connexio internament)
4. **File > Save**

**Pas 2: Afegir la tasca Jython**

1. Anar a la pestanya **Tasks**
2. Clic al boto **Add** (icona +). Apareix una nova fila
3. Omplir els camps de la fila:

| Camp | Valor |
|------|-------|
| **Name** | `FETCH_AND_LOAD_AWARDS` |
| **Target Technology** | Seleccionar **Jython** al desplegable |
| **Ignore Errors** | NO (volem que falli si hi ha error greu) |

4. Al camp **Target Command**, fer clic al boto **`...`** (punts suspensius) per obrir l'**Expression Editor** (finestra mes gran per escriure codi)
5. **Copiar i enganxar** tot el contingut del fitxer `ingesta_awards_odi.py`
6. Clic **OK** per tancar l'Expression Editor
7. **File > Save**

**IMPORTANT**: Si el script supera els 100.000 caracters (limit d'ODI), consulteu la seccio 9.7 per a la solucio amb `execfile()`.

### 4.3 Crear el Paquet (Package)

Un paquet ODI organitza l'execucio de variables, procediments i altres passos en seqüencia.

**Pas 1: Crear el paquet**

1. A **Designer Navigator**, expandir el teu projecte
2. Clic dret sobre **Packages** > **New Package**
3. **Name**: `PKG_INGESTA_AWARDS_JSON`
4. Clic **OK**

**Pas 2: Afegir passos al diagrama**

1. Anar a la pestanya **Diagram** (area visual)
2. Des del **Designer Navigator** (panell esquerre), expandir **Global Objects > Variables**
3. **Arrossegar** (drag & drop) cada variable al diagrama:
   - PURE_API_URL
   - PURE_API_KEY
   - BCK_JDBC_URL
   - BCK_USER
   - BCK_PASSWORD
4. Per cada variable arrossegada, al panell **Properties** (inferior):
   - **Type**: seleccionar `Declare Variable`
   - Aixo declara la variable a l'ambit del paquet perque el procediment la pugui usar
5. Des del **Designer Navigator**, expandir **Procedures**
6. **Arrossegar** el procediment `PROC_INGESTA_AWARDS_JSON` al diagrama

**Pas 3: Encadenar els passos**

1. Seleccionar el primer step de variable > **clic dret > First Step**
   - Apareix un simbol especial que indica que es el punt d'inici
2. A la toolbar del diagrama, seleccionar l'eina **Next Step on Success** (icona de fletxa verda)
3. **Arrossegar** una linia des de la primera variable cap a la segona
4. Repetir per encadenar totes les variables en seqüencia
5. Arrossegar una linia des de l'ultima variable cap al procediment `PROC_INGESTA_AWARDS_JSON`
6. **File > Save**

El diagrama resultant ha de tenir aquest aspecte:
```
[Declare PURE_API_URL] --ok--> [Declare PURE_API_KEY] --ok--> [Declare BCK_JDBC_URL]
     --ok--> [Declare BCK_USER] --ok--> [Declare BCK_PASSWORD]
     --ok--> [PROC_INGESTA_AWARDS_JSON]
```

### 4.4 Executar i Verificar

**Pas 1: Executar**

1. Al **Designer Navigator**, seleccionar `PKG_INGESTA_AWARDS_JSON`
2. **Clic dret > Run** (o boto Run a la toolbar)
3. Al dialeg **Run**:
   - **Context**: seleccionar el context del teu entorn (ex: `Development`)
   - **Logical Agent**: seleccionar l'agent ODI configurat
   - **Log Level**: `5` (maxim detall — recomanat per a proves)
4. Clic **OK**
5. Apareix el dialeg **Session Started** > Clic **OK**

**Pas 2: Verificar**

1. Anar a **Operator Navigator** (pestanya a la part inferior esquerra d'ODI Studio)
2. Expandir **Sessions** > seleccionar la sessio mes recent
3. Expandir els passos de la sessio
4. Clic al task `FETCH_AND_LOAD_AWARDS`
5. Pestanya **Task Log**: aqui veureu els prints del script amb timestamps:
   ```
   [2026-03-28T10:00:00] ============================================================
   [2026-03-28T10:00:00] INICI INGESTA AWARDS DES DE PURE API
   [2026-03-28T10:00:00] ============================================================
   [2026-03-28T10:00:00] Mode: JDBC
   [2026-03-28T10:00:00] JSON Parser Tier: 1 - javax.json (JSR 353)
   [2026-03-28T10:00:01] Total awards disponibles a l'API: 43193
   [2026-03-28T10:00:03] Pagina 1/44 completada: 1000 awards, ...
   ...
   ```
6. **Estat**:
   - **Verd (Done)**: execucio correcta
   - **Vermell (Error)**: obrir el task i veure el missatge d'error al log

---

## 5. Documentacio Detallada del Codi

Aquesta seccio explica cada part del fitxer `ingesta_awards_odi.py`: que fa, per que esta dissenyat aixi, quines alternatives existien i com adaptar-lo.

### 5.1 Visio General de l'Arquitectura del Script

```
ingesta_awards_odi.py
|
+-- SECCIO 1: CONFIGURACIO (linies 43-120)
|   Totes les constants modificables en un sol lloc
|
+-- SECCIO 1b: MAPEIG DE COLUMNES (linies 121-195)
|   Definicio de taules i columnes Oracle
|
+-- SECCIO 2: IMPORTS I DETECCIO TIER (linies 196-260)
|   Imports Java + deteccio automatica del parser JSON
|
+-- SECCIO 3: FUNCIONS AUXILIARS (linies 261-580)
|   |
|   +-- 3.1  log()                      Logging amb timestamp
|   +-- 3.2  fetch_page()               HTTP GET amb retry
|   +-- 3.3  parse_json()               Dispatcher de tiers
|   +-- 3.4  safe_str/int/float/obj/arr Acces segur a camps
|   +-- 3.5  extract_localized()        Camps multilingue
|   +-- 3.6  extract_period()           Rangs de dates
|   +-- 3.7  flatten_award()            Aplanar taula pare
|   +-- 3.8  flatten_award_holders()    Generar filles (holders)
|   +-- 3.9  flatten_award_fundings()   Generar filles (fundings)
|   +-- 3.10 flatten_award_identifiers() Generar filles (identifiers)
|   +-- 3.11 build_insert_sql()         Generar SQL INSERT
|   +-- 3.12 insert_batch_jdbc()        Batch INSERT via JDBC
|   +-- 3.13 escape_csv_value()         Escapar valors CSV
|   +-- 3.14 write_csv()                Escriure fitxer CSV
|
+-- SECCIO 4: EXECUCIO PRINCIPAL (linies 581-750)
|   Funcio main() que orquestra tot el proces
|
+-- PUNT D'ENTRADA (linia 751)
    Crida a main()
```

**Diagrama de flux del proces complet:**

```
        INICI
          |
          v
    Detectar Tier JSON
    (javax.json? org.json? eval?)
          |
          v
    Inicialitzar recursos
    (JDBC connexio o CSV fitxers)
          |
          v
    Truncar taules? (si configurat)
          |
          v
    Fetch pagina 0 --> obtenir count total
          |
          v
    +---> offset < total_count? --NO--> Resum final --> FI
    |         |
    |        SI
    |         |
    |         v
    |    Fetch pagina (HTTP GET)
    |         |
    |         v
    |    Parse JSON
    |         |
    |         v
    |    Per cada award en items[]:
    |    +-- flatten_award()       --> fila pare
    |    +-- flatten_holders()     --> files filles
    |    +-- flatten_fundings()    --> files filles
    |    +-- flatten_identifiers() --> files filles
    |         |
    |         v
    |    Insert batch (JDBC) o Write (CSV)
    |    Commit (JDBC) o Flush (CSV)
    |         |
    |         v
    |    Log progres
    |    offset += PAGE_SIZE
    |         |
    +--------<+
```

**Estimacio de temps d'execucio:**
- ~44 pagines x ~2 segons per pagina (fetch + parse + insert) = **~90 segons** per a un full load de 43.193 awards
- El temps pot variar segons latencia de xarxa i rendiment de la BD

### 5.2 Seccio de Configuracio (SECCIO 1, linies 43-120)

**Objectiu**: centralitzar tots els parametres perque l'usuari pugui adaptar el script sense tocar la logica.

**Variables de connexio API:**

| Constant | Tipus | Valor per defecte | Proposit |
|----------|-------|-------------------|----------|
| `PURE_API_URL` | string | `'#GLOBAL.PURE_API_URL'` | URL base de l'endpoint |
| `PURE_API_KEY` | string | `'#GLOBAL.PURE_API_KEY'` | Clau API (header) |
| `PAGE_SIZE` | int | `1000` | Registres per pagina (max API: 1000) |

**Variables de connexio JDBC:**

| Constant | Tipus | Valor per defecte | Proposit |
|----------|-------|-------------------|----------|
| `BCK_JDBC_URL` | string | `'#GLOBAL.BCK_JDBC_URL'` | URL JDBC Oracle |
| `BCK_USER` | string | `'#GLOBAL.BCK_USER'` | Usuari Oracle |
| `BCK_PASSWORD` | string | `'#GLOBAL.BCK_PASSWORD'` | Password Oracle |

**Variables de control:**

| Constant | Tipus | Valor per defecte | Proposit |
|----------|-------|-------------------|----------|
| `MODE` | string | `'JDBC'` | Mode de carrega: `'JDBC'` o `'CSV'` |
| `CSV_OUTPUT_DIR` | string | `'/tmp/odi/awards'` | Directori per fitxers CSV |
| `MAX_RETRIES` | int | `3` | Reintents per peticio HTTP fallida |
| `RETRY_BASE_DELAY` | int | `2` | Segons base entre reintents (exponencial) |
| `DELAY_BETWEEN_PAGES` | float | `0.5` | Segons entre pagines (evitar rate limit) |
| `HTTP_CONNECT_TIMEOUT` | int | `30000` | Timeout connexio HTTP (ms) |
| `HTTP_READ_TIMEOUT` | int | `60000` | Timeout lectura HTTP (ms) |
| `MAX_PAGE_ERRORS` | int | `5` | Errors de pagina abans d'abortar |
| `TRUNCATE_BEFORE_LOAD` | bool | `True` | Truncar taules abans de carregar |

**Com funciona la substitucio de variables ODI:**

Quan l'agent ODI executa el script, **abans** d'enviar-lo a Jython, substitueix textualment cada `#GLOBAL.VAR_NAME` pel valor de la variable. Per exemple:

```python
# El que escrivim:
PURE_API_URL = '#GLOBAL.PURE_API_URL'

# El que Jython rep despres de la substitucio:
PURE_API_URL = 'https://egreta.uab.cat/ws/api/awards'
```

**Regles importants:**
- Les variables **son case-sensitive**: `#GLOBAL.PURE_API_URL` != `#GLOBAL.pure_api_url`
- Per a strings: les cometes simples van **fora** del `#`: `'#GLOBAL.VAR'`
- Per a numerics: **sense** cometes: `#GLOBAL.VAR`
- Si la variable no existeix, el text `#GLOBAL.VAR` es queda literal (no hi ha error, pero el script fallara despres)

### 5.3 Mapeig de Columnes (SECCIO 1b, linies 121-195)

**Objectiu**: definir quins camps del JSON es mapegen a quines columnes d'Oracle, en un format facil de modificar.

**Format**: llista de tuples `(NOM_COLUMNA_ORACLE, TIPUS_ORACLE)`.

```python
AWARD_COLUMNS = [
    ('AWARD_UUID',           'VARCHAR2'),   # uuid del JSON
    ('PURE_ID',              'NUMBER'),     # pureId del JSON
    ('TITLE_CA',             'VARCHAR2'),   # title.ca_ES del JSON
    # ...
]
```

L'**ordre** de la llista es critic: ha de coincidir exactament amb l'ordre dels valors retornats per la funcio `flatten_award()`. Si afegiu una columna al mig de la llista, heu d'afegir el valor corresponent a la mateixa posicio dins de `flatten_award()`.

**Tipus suportats i el seu tractament a JDBC:**

| TIPUS_ORACLE | Metode JDBC | Conversio SQL | Exemple |
|-------------|-------------|---------------|---------|
| `'VARCHAR2'` | `setString()` | Cap | `'abc'` |
| `'NUMBER'` | `setLong()` o `setDouble()` | Cap | `45755723` |
| `'DATE'` | `setString()` | `TO_DATE(?, 'YYYY-MM-DD')` | `'2023-10-05'` |
| `'TIMESTAMP'` | `setString()` | `TO_TIMESTAMP(?, 'YYYY-MM-DD"T"HH24:MI:SS')` | `'2023-10-05T14:30:00'` |

**Com adaptar per a les vostres taules existents:**

1. Canvieu `NOM_COLUMNA_ORACLE` pel nom real de la vostra columna
2. Canvieu `TIPUS_ORACLE` pel tipus corresponent
3. Afegiu o traieu tuples segons els camps que necessiteu
4. Modifiqueu la funcio `flatten_*` per retornar el mateix nombre de valors

Exemple: si la vostra taula te la columna `TITOL_CATALA` en lloc de `TITLE_CA`:
```python
# Abans:
('TITLE_CA', 'VARCHAR2'),
# Despres:
('TITOL_CATALA', 'VARCHAR2'),
```
No cal canviar res mes — la funcio `flatten_award()` segueix retornant el valor `title.ca_ES` a la mateixa posicio.

### 5.4 Imports i Deteccio de Tier (SECCIO 2, linies 196-260)

**Objectiu**: importar les classes Java necessaries i detectar el parser JSON disponible.

**Llista completa d'imports amb justificacio:**

| Import | Classe Java | Per que es necessaria |
|--------|-------------|----------------------|
| `from java.net import URL` | `java.net.URL` | Construir objectes URL per a peticions HTTP |
| `from java.net import HttpURLConnection` | `java.net.HttpURLConnection` | Obrir connexio HTTP/HTTPS, configurar headers i timeouts |
| `from java.io import BufferedReader` | `java.io.BufferedReader` | Llegir la resposta HTTP linia a linia amb buffer |
| `from java.io import InputStreamReader` | `java.io.InputStreamReader` | Convertir flux de bytes a caracters amb encoding UTF-8 |
| `from java.io import StringReader` | `java.io.StringReader` | Necessari per a `javax.json.Json.createReader()` (Tier 1) |
| `from java.io import FileWriter` | `java.io.FileWriter` | Escriure fitxers CSV (mode CSV) |
| `from java.io import BufferedWriter` | `java.io.BufferedWriter` | Buffer d'escriptura de 8KB per reduir I/O |
| `from java.io import File` | `java.io.File` | Crear directoris (mode CSV) |
| `from java.lang import StringBuilder` | `java.lang.StringBuilder` | Concatenar strings en O(n) vs O(n^2) de `+=` |
| `from java.lang import System` | `java.lang.System` | Obtenir timestamp (`currentTimeMillis`) |
| `from java.lang import Thread` | `java.lang.Thread` | `sleep()` entre pagines per evitar rate limiting |
| `from java.sql import DriverManager` | `java.sql.DriverManager` | Obtenir connexions JDBC a Oracle |
| `from java.sql import Types` | `java.sql.Types` | Constants per a `setNull()` (VARCHAR, NUMERIC) |

**Mecanisme de deteccio de tier:**

```python
JSON_TIER = 0

try:
    from javax.json import Json        # Tier 1: javax.json
    JSON_TIER = 1
except ImportError:
    try:
        from org.json import JSONObject  # Tier 2: org.json
        JSON_TIER = 2
    except ImportError:
        JSON_TIER = 3                    # Tier 3: eval() fallback
```

La variable global `JSON_TIER` es consulada per totes les funcions `safe_*` per saber quina API usar.

### 5.5 Funcions Auxiliars (SECCIO 3, linies 261-580)

#### 5.5.1 `log(msg)` — Logging amb timestamp

| Aspecte | Detall |
|---------|--------|
| **Signatura** | `log(msg) -> None` |
| **Proposit** | Escriure missatges amb timestamp ISO al log de sessio d'ODI |
| **Com arriba al log** | L'agent ODI captura `stdout` i el mostra a Operator Navigator > Sessions > Task Log |
| **Format** | `[2026-03-28T10:00:00] El teu missatge` |
| **Decisio** | Usem `SimpleDateFormat` de Java (no `time.strftime`) per compatibilitat garantida |

#### 5.5.2 `fetch_page(base_url, api_key, offset, size)` — HTTP GET amb retry

| Aspecte | Detall |
|---------|--------|
| **Signatura** | `fetch_page(base_url, api_key, offset, size) -> str` |
| **Proposit** | Fer una peticio HTTP GET paginada a la Pure API i retornar el JSON |
| **Retorn** | String JSON complet de la resposta |

**Flux intern:**

1. Construir URL amb query params: `{base_url}?offset={offset}&size={size}`
2. `URL(url_str).openConnection()` -> `HttpURLConnection`
3. Configurar headers:
   - `api-key: {api_key}` (autenticacio Pure)
   - `Accept: application/json` (forcar resposta JSON, no XML)
4. Configurar timeouts (evitar bloqueig indefinit)
5. Verificar `responseCode == 200`
6. Llegir cos amb `BufferedReader` + `StringBuilder`
7. Si error retriable (429, 5xx): esperar `2^attempt` segons i reintentar
8. Si error definitiu (4xx): llançar excepcio amb el cos de l'error

**Per que `StringBuilder` i no `+=`?**

```python
# MAL (O(n^2) — cada += crea un nou string i copia tot el contingut):
result = ""
while line:
    result += line  # Copia n bytes cada iteracio!

# BE (O(n) — StringBuilder te un buffer intern que creix sense copiar):
sb = StringBuilder()
while line:
    sb.append(line)  # Afegeix al buffer existent
result = sb.toString()  # Una sola copia al final
```

Amb respostes de ~1MB per pagina i milers de linies, la diferencia es significativa.

**Estrategia de retry amb backoff exponencial:**

| Intent | Espera | Total acumulat |
|--------|--------|----------------|
| 1 | 2^0 * 2 = 2s | 2s |
| 2 | 2^1 * 2 = 4s | 6s |
| 3 | 2^2 * 2 = 8s | 14s |
| 4 (ultim) | Excepcio | - |

Aixo evita sobrecarregar el servidor si esta ocupat (429) o reiniciant (503).

#### 5.5.3 `parse_json(json_string)` — Dispatcher de tiers

| Aspecte | Detall |
|---------|--------|
| **Signatura** | `parse_json(json_string) -> objecte` |
| **Proposit** | Convertir string JSON a objecte navegable |
| **Retorn Tier 1** | `javax.json.JsonObject` (immutable) |
| **Retorn Tier 2** | `org.json.JSONObject` (mutable) |
| **Retorn Tier 3** | `dict` Python (via `eval()`) |

**Tier 3 (eval) — detalls de seguretat:**

```python
s = s.replace('true', 'True')    # JSON true  -> Python True
s = s.replace('false', 'False')  # JSON false -> Python False
s = s.replace('null', 'None')    # JSON null  -> Python None
return eval(s, {"__builtins__": {}}, {})
```

El segon argument de `eval()` (`{"__builtins__": {}}`) desactiva totes les funcions integrades de Python (`__import__`, `open`, `exec`, etc.), impedint l'execucio de codi maliciós. Aixo es segur en el nostre context perque la Pure API es una font de confianca interna.

**Limitacio del Tier 3**: si un valor de text al JSON conte literalment la paraula `true`, `false` o `null` (ex: `"description": "This is true"`), el reemplacament pot corrompre el valor. Amb Tier 1/2, aixo no passa perque usen un parser real.

#### 5.5.4 Funcions `safe_*` — Acces segur a camps

| Funcio | Retorn | Proposit |
|--------|--------|----------|
| `safe_str(obj, key, default="")` | `str` | Obtenir string, o default si absent/null |
| `safe_int(obj, key, default=None)` | `int` o `None` | Obtenir enter |
| `safe_float(obj, key, default=None)` | `float` o `None` | Obtenir decimal |
| `safe_obj(obj, key)` | objecte o `None` | Obtenir sub-objecte niat |
| `safe_arr(obj, key)` | array o `None` | Obtenir array |
| `arr_len(arr)` | `int` | Longitud d'un array (compatible tots tiers) |
| `arr_get_obj(arr, index)` | objecte | Obtenir element d'un array per index |

**Per que son necessaries?**

El JSON de Pure te molts camps opcionals. Un award pot tenir `status` o no, `managingOrganization` o no, `fundings` o una llista buida. Sense acces segur:

```python
# FALLA si l'award no te "status":
status_type = award["status"]["typeDiscriminator"]  # KeyError!

# FUNCIONA sempre:
status = safe_obj(award, "status")
status_type = ""
if status is not None:
    status_type = safe_str(status, "typeDiscriminator", "")
```

Cada funcio `safe_*` te una implementacio diferent per cada tier, ja que les APIs Java tenen metodes diferents:
- **Tier 1** (`javax.json`): `obj.containsKey(key)` + `obj.getString(key)`
- **Tier 2** (`org.json`): `obj.optString(key, default)` (metode integrat)
- **Tier 3** (dict): `obj.get(key, default)` (metode estandard de Python)

#### 5.5.5 `extract_localized(obj, field, locale)` — Camps multilingue

**Proposit**: obtenir el text en un idioma concret d'un camp multilingue.

Pure retorna els camps de text en multiples idiomes com a objecte amb claus de locale:
```json
"title": {
    "ca_ES": "Ajut per a projectes de recerca",
    "es_ES": "Ayuda para proyectos de investigacion",
    "en_GB": "Research project grant"
}
```

La funcio navega a l'objecte `title` i extreu el valor per al locale demanat:
```python
title_ca = extract_localized(award, "title", "ca_ES")
# -> "Ajut per a projectes de recerca"
```

#### 5.5.6 `extract_period(obj, field)` — Rangs de dates

**Proposit**: extreure dates d'inici i fi d'objectes de tipus `DateRange`.

```json
"actualPeriod": {
    "startDate": "2023-01-01",
    "endDate": "2025-12-31"
}
```

Retorna una tupla `(start_date, end_date)` on cada valor es un string o `""`.

#### 5.5.7 `flatten_award(award_obj)` — Aplanar award pare

**Proposit**: convertir un objecte JSON niat a una llista plana de valors, en el mateix ordre que `AWARD_COLUMNS`.

**Mapeig complet JSON -> columna Oracle:**

| # | Camp JSON | Columna Oracle | Metode d'extraccio |
|---|-----------|---------------|---------------------|
| 0 | `uuid` | `AWARD_UUID` | `safe_str()` directe |
| 1 | `pureId` | `PURE_ID` | `safe_int()` directe |
| 2 | `typeDiscriminator` | `TYPE_DISCRIMINATOR` | `safe_str()` directe |
| 3 | `version` | `VERSION_HASH` | `safe_str()` directe |
| 4 | `acronym` | `ACRONYM` | `safe_str()` directe |
| 5 | `awardDate` | `AWARD_DATE` | `safe_str()` (data com a string per a TO_DATE) |
| 6 | `title.ca_ES` | `TITLE_CA` | `extract_localized()` |
| 7 | `title.es_ES` | `TITLE_ES` | `extract_localized()` |
| 8 | `title.en_GB` | `TITLE_EN` | `extract_localized()` |
| 9 | `actualPeriod.startDate` | `ACTUAL_START_DATE` | `extract_period()` |
| 10 | `actualPeriod.endDate` | `ACTUAL_END_DATE` | `extract_period()` |
| 11 | `expectedPeriod.startDate` | `EXPECTED_START_DATE` | `extract_period()` |
| 12 | `expectedPeriod.endDate` | `EXPECTED_END_DATE` | `extract_period()` |
| 13 | `managingOrganization.uuid` | `MANAGING_ORG_UUID` | `safe_obj()` + `safe_str()` |
| 14 | `managingOrganization.name.ca_ES` | `MANAGING_ORG_NAME_CA` | `safe_obj()` + `extract_localized()` |
| 15 | `type.uri` | `AWARD_TYPE_URI` | `safe_obj()` + `safe_str()` |
| 16 | `workflow.step` | `WORKFLOW_STEP` | `safe_obj()` + `safe_str()` |
| 17 | `status.typeDiscriminator` | `STATUS_TYPE` | `safe_obj()` + `safe_str()` |
| 18 | `status.date` | `STATUS_DATE` | `safe_obj()` + `safe_str()` |
| 19 | `status.reason` | `STATUS_REASON` | `safe_obj()` + `safe_str()` |
| 20 | `cluster.uuid` | `CLUSTER_UUID` | `safe_obj()` + `safe_str()` |
| 21 | `portalUrl` | `PORTAL_URL` | `safe_str()` directe |
| 22 | `createdBy` | `CREATED_BY` | `safe_str()` directe |
| 23 | `createdDate` | `CREATED_DATE` | `safe_str()` (timestamp com a string) |
| 24 | `modifiedBy` | `MODIFIED_BY` | `safe_str()` directe |
| 25 | `modifiedDate` | `MODIFIED_DATE` | `safe_str()` (timestamp com a string) |

#### 5.5.8-10 `flatten_award_holders/fundings/identifiers()` — Generar files filles

Aquestes funcions segueixen el mateix patro:

1. Obtenir l'array niat amb `safe_arr()` (ex: `"awardHolders"`)
2. Si l'array es `None` o buit, retornar llista buida
3. Iterar sobre cada element de l'array
4. Per cada element, extreure els camps amb `safe_str()`, `safe_float()`, etc.
5. Afegir l'`AWARD_UUID` com a primer camp (foreign key)
6. Retornar llista de llistes (una per fila)

Referencies als camps:
- **Holders**: context.md linies 478-484 (awardHolders amb person.uuid i percentatge)
- **Fundings**: context.md linies 500-505 (fundings amb funder, awardedAmount)
- **Identifiers**: context.md linies 452-458 (identifiers amb ID FENIX)

#### 5.5.11 `build_insert_sql(table_name, columns)` — Generar SQL INSERT

**Proposit**: generar un SQL parametritzat amb `?` placeholders per a `PreparedStatement`.

**Tractament especial per a dates:**
- Columnes `DATE`: el placeholder es `TO_DATE(?, 'YYYY-MM-DD')` en lloc de `?`
- Columnes `TIMESTAMP`: el placeholder es `TO_TIMESTAMP(?, 'YYYY-MM-DD"T"HH24:MI:SS')`

Aixo es perque Oracle no pot convertir implicitament un string a DATE. La funcio `TO_DATE` d'Oracle fa la conversio explicita.

**SQL generat d'exemple:**
```sql
INSERT INTO BCK_PURE_AWARD (AWARD_UUID, PURE_ID, ..., AWARD_DATE, ...)
VALUES (?, ?, ..., TO_DATE(?, 'YYYY-MM-DD'), ...)
```

#### 5.5.12 `insert_batch_jdbc(conn, table_name, columns, rows)` — Batch INSERT

**Proposit**: inserir un conjunt de files eficientment via JDBC.

**Per que `PreparedStatement` i no `Statement` amb SQL concatenat?**

```python
# MAL — SQL injection + rendiment pobre:
sql = "INSERT INTO T VALUES ('%s', %d)" % (user_input, 123)
stmt.execute(sql)  # Oracle compila un nou pla per cada INSERT diferent

# BE — parametritzat + rendiment optim:
sql = "INSERT INTO T VALUES (?, ?)"
pstmt = conn.prepareStatement(sql)
pstmt.setString(1, user_input)  # Escapat automaticament
pstmt.setLong(2, 123)
pstmt.addBatch()
pstmt.executeBatch()  # Oracle reutilitza el pla d'execucio
```

**Per que `addBatch()` + `executeBatch()`?**
- Sense batch: 1 roundtrip de xarxa per cada INSERT = 43.193 roundtrips
- Amb batch: 1 roundtrip per pagina de 1000 files = 44 roundtrips
- Reduccio de ~1000x en comunicacio de xarxa

#### 5.5.13-14 `escape_csv_value()` i `write_csv()` — Escriptura CSV

Segueixen l'estandard **RFC 4180**:
- Si un valor conte comes, cometes dobles o salts de linia → embolcallar amb `"..."`
- Les cometes dobles internes es dupliquen: `"` → `""`

Usem `java.io.BufferedWriter` (no Python `open()`) per:
- Garantir encoding UTF-8 a Jython 2.5
- Buffer de 8KB que redueix crides I/O al sistema operatiu

### 5.6 Execucio Principal (SECCIO 4, funcio `main()`)

**Estructura general:**

```python
def main():
    conn = None
    try:
        # 4.1 Log inici
        # 4.2 Inicialitzar recursos (JDBC o CSV)
        # 4.3 Truncar taules (opcional)
        # 4.4 Fetch pagina 0 -> total_count
        # 4.5 Bucle de paginacio
        # 4.6 Resum final
    finally:
        # 4.7 Tancar recursos (SEMPRE)
        if conn is not None:
            conn.close()
```

**Per que `try/finally` i no `with`?**
Jython 2.5 no suporta el `with` statement. `try/finally` garanteix que els recursos (connexio JDBC, fitxers) es tanquen fins i tot si hi ha una excepcio.

**Gestio d'errors a dos nivells:**

1. **Nivell de pagina** (`try/except` dins del bucle):
   - Si una pagina falla: log error, rollback de la pagina, continuar amb la seguent
   - El comptador `page_errors` s'incrementa
   - Si `page_errors >= MAX_PAGE_ERRORS`: abortar l'execucio completa
   - **Raonamient**: perdre 1 pagina de 44 es acceptable; perdre 5 indica un problema sistemic

2. **Nivell global** (`try/finally`):
   - Garanteix que la connexio JDBC es tanca SEMPRE
   - Prevé fuites de connexio (connection leaks) que poden esgotar el pool d'Oracle

**Commit per pagina (mode JDBC):**
- Fem `conn.commit()` despres d'inserir tota la pagina (pare + filles)
- Si la pagina falla, fem `conn.rollback()` per desfer els inserts parcials
- **Raonamient**: compromis entre rendiment i recuperabilitat
  - Commit per fila: massa lent (1 commit = 1 flush a disc)
  - Commit al final: si falla a la pagina 43/44, es perden 42 pagines

### 5.7 Com Adaptar el Template per a Altres Endpoints

El template esta dissenyat per a l'endpoint `/awards`, pero es pot adaptar per a qualsevol endpoint de Pure (persons, projects, research-outputs, etc.).

**Passos per adaptar:**

1. **Canviar la URL**: 
   ```python
   PURE_API_URL = 'https://egreta.uab.cat/ws/api/persons'  # o /projects, etc.
   ```

2. **Definir noves columnes**:
   ```python
   PERSON_COLUMNS = [
       ('PERSON_UUID', 'VARCHAR2'),
       ('FIRST_NAME',  'VARCHAR2'),
       ('LAST_NAME',   'VARCHAR2'),
       # ... camps especifics de l'endpoint
   ]
   ```

3. **Crear noves funcions flatten**:
   ```python
   def flatten_person(person_obj):
       uuid = safe_str(person_obj, "uuid", "")
       first = safe_str(person_obj, "name.firstName", "")
       # ...
       return [uuid, first, ...]
   ```

4. **Adaptar el bucle principal** per cridar les noves funcions

5. **Canviar els noms de les taules**

---

## 6. Opcio A: Insercio Directa a BCK via JDBC

Aquesta opcio es la **recomanada per a produccio**. El script insereix directament a les taules Oracle sense passar per fitxers intermedis.

### 6.1 Configuracio

```python
MODE = 'JDBC'
BCK_JDBC_URL  = '#GLOBAL.BCK_JDBC_URL'   # jdbc:oracle:thin:@//host:1521/service
BCK_USER      = '#GLOBAL.BCK_USER'
BCK_PASSWORD  = '#GLOBAL.BCK_PASSWORD'
TRUNCATE_BEFORE_LOAD = True  # Full load: buidar taules primer
```

### 6.2 Formats de JDBC URL per a Oracle

| Format | Exemple | Quan usar |
|--------|---------|-----------|
| Service Name | `jdbc:oracle:thin:@//host:1521/BCKSERVICE` | Recomanat (Oracle 12c+) |
| SID (antic) | `jdbc:oracle:thin:@host:1521:BCKSID` | Instal·lacions antigues |
| TNS | `jdbc:oracle:thin:@(DESCRIPTION=(ADDRESS=(HOST=host)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=BCKSERVICE)))` | Configuracions complexes (RAC, failover) |

### 6.3 Estrategia de Commit

El script fa un `commit()` despres de cada pagina (1000 registres). Aixo significa:

- Si l'execucio falla a la pagina 30, les pagines 1-29 ja estan commitejades
- La pagina 30 fa rollback automatic
- Podeu re-executar l'script (amb `TRUNCATE_BEFORE_LOAD=True`) per fer un full load net

### 6.4 Verificacio

Despres d'executar, verificar amb SQL:

```sql
SELECT COUNT(*) FROM BCK_PURE_AWARD;
-- Hauria de ser ~43.193 (o el count retornat per l'API)

SELECT COUNT(*) FROM BCK_PURE_AWARD_HOLDER;
SELECT COUNT(*) FROM BCK_PURE_AWARD_FUNDING;
SELECT COUNT(*) FROM BCK_PURE_AWARD_IDENTIFIER;
```

---

## 7. Opcio B: Generacio CSV + Carrega amb LKM

Aquesta opcio es **recomanada per a proves i depuracio** perque permet inspeccionar els fitxers CSV abans de carregar-los a Oracle.

### 7.1 Configuracio

```python
MODE = 'CSV'
CSV_OUTPUT_DIR = '/tmp/odi/awards'
```

### 7.2 Fitxers Generats

Despres de l'execucio, el directori contindra:

```
/tmp/odi/awards/
├── awards.csv              # Taula pare (43.193 files)
├── award_holders.csv       # Holders (variable)
├── award_fundings.csv      # Fundings (variable)
└── award_identifiers.csv   # Identifiers (variable)
```

Cada fitxer te una fila de capcalera amb els noms de les columnes i les dades en format CSV RFC 4180 (encoding UTF-8).

### 7.3 Carregar els CSV a Oracle amb ODI

Un cop generats els CSV, cal configurar ODI per carregar-los:

**Pas 1: Crear un Data Server File a la Topologia**

1. ODI Studio > **Topology Navigator**
2. **Physical Architecture > Technologies > File** > clic dret > **New Data Server**
3. Name: `DS_FILE_CSV_AWARDS`
4. **Connection** tab:
   - JDBC Driver: `com.sunopsis.jdbc.dbfile.SnpsDBFileDriver` (ja inclosa a ODI)
   - JDBC URL: `jdbc:snps:dbfile?ENCODING=UTF8`
5. **Physical Schema** tab: crear un schema apuntant a `/tmp/odi/awards/`
6. Crear un **Logical Schema** associat

**Pas 2: Crear Model i Datastores per als CSV**

1. **Designer Navigator > Models** > clic dret > **New Model**
2. Associar al Logical Schema creat
3. Per cada fitxer CSV: clic dret > **New Datastore**
4. Configurar el datastore amb el fitxer CSV com a origen

**Pas 3: Crear Mappings (CSV -> BCK)**

1. Crear un mapping per cada fitxer CSV -> taula BCK
2. Source: Datastore CSV
3. Target: Taula BCK (Oracle)
4. LKM: `LKM File to SQL` (carrega el fitxer a la BD)
5. IKM: `IKM SQL to SQL Append` (insercio simple)

**Pas 4: Afegir al Package**

Afegir els mappings al paquet despres del procediment de generacio CSV:

```
[PROC_INGESTA_AWARDS_JSON (CSV)] --ok--> [Mapping awards.csv -> BCK_PURE_AWARD]
  --ok--> [Mapping holders.csv -> BCK_PURE_AWARD_HOLDER]
  --ok--> [Mapping fundings.csv -> BCK_PURE_AWARD_FUNDING]
  --ok--> [Mapping identifiers.csv -> BCK_PURE_AWARD_IDENTIFIER]
```

---

## 8. Carrega Incremental

La carrega incremental (fase 4 del TFG) permet carregar nomes els awards modificats des de l'ultima execucio, en lloc de tots.

### 8.1 Estrategia: modifiedDate >= ultima carrega

La Pure API retorna un camp `modifiedDate` per cada award. Podem usar-lo com a filtre:

1. Abans d'executar, obtenir l'ultima data de carrega:
   ```sql
   SELECT MAX(MODIFIED_DATE) FROM BCK_PURE_AWARD
   ```
2. Usar l'endpoint `POST /awards/search` amb filtre de data:
   ```json
   {
       "modifiedDate": {
           "from": "2025-06-01T00:00:00.000Z"
       },
       "size": 1000,
       "offset": 0
   }
   ```
3. Per als registres retornats, fer MERGE (UPSERT) a Oracle

### 8.2 Variable ODI per a l'Ultima Data

Crear una variable `GLOBAL.LAST_LOAD_TIMESTAMP` amb:
- **Datatype**: Alphanumeric (format ISO timestamp)
- **Refreshing tab**: 
  ```sql
  SELECT TO_CHAR(MAX(MODIFIED_DATE), 'YYYY-MM-DD"T"HH24:MI:SS.FF3"Z"')
  FROM BCK_PURE_AWARD
  ```

### 8.3 MERGE (UPSERT) a Oracle

En lloc de `TRUNCATE + INSERT`, usem `MERGE`:

```sql
MERGE INTO BCK_PURE_AWARD t
USING (SELECT ? AS AWARD_UUID, ? AS PURE_ID, ... FROM DUAL) s
ON (t.AWARD_UUID = s.AWARD_UUID)
WHEN MATCHED THEN
    UPDATE SET t.PURE_ID = s.PURE_ID, t.TITLE_CA = s.TITLE_CA, ...
WHEN NOT MATCHED THEN
    INSERT (AWARD_UUID, PURE_ID, TITLE_CA, ...)
    VALUES (s.AWARD_UUID, s.PURE_ID, s.TITLE_CA, ...);
```

**Avantatges de la carrega incremental:**
- Molt mes rapid (nomes X awards modificats vs 43.193 totals)
- Menys carrega sobre la Pure API i la BD Oracle
- Les dades sempre estan actualitzades

**Inconvenients:**
- Mes complex de implementar i depurar
- No detecta eliminacions (awards borrats a Pure)
- Requereix confianca en el camp `modifiedDate` de Pure

### 8.4 Adaptacio del Script

Per adaptar `ingesta_awards_odi.py` per a carrega incremental:

1. Canviar `fetch_page()` per usar `POST /awards/search` amb cos JSON
2. Afegir el filtre `modifiedDate.from` amb el valor de `#GLOBAL.LAST_LOAD_TIMESTAMP`
3. Canviar `TRUNCATE_BEFORE_LOAD = False`
4. Canviar `build_insert_sql()` per generar MERGE en lloc de INSERT

Nota: aquesta adaptacio es prevista com a fase separada del TFG (fase 4, linies 191-199 del context.md).

---

## 9. Problemes Comuns i Solucions

### 9.1 `ImportError: No module named json`

**Causa:** Jython 2.5 no inclou el modul `json` de la biblioteca estandard (introduit a Python 2.6).

**Simptoma:** Error a l'inici del script si algú intenta `import json`.

**Solucio:** El template **no usa** `import json`. Usa classes Java. Si veieu aquest error, es perque heu modificat el script i afegit `import json`. Useu les funcions `parse_json()` i `safe_*()` del template.

**Verificacio:** El log mostrara `JSON Parser Tier: X` a l'inici. Si apareix Tier 3, considereu instal·lar el JAR org.json (veure 2.4).

### 9.2 `javax.net.ssl.SSLHandshakeException`

**Causa:** El certificat SSL d'`egreta.uab.cat` no es al truststore de la JVM de l'agent ODI.

**Simptoma:** Error a la primera crida `fetch_page()`.

**Solucio (definitiva):**

1. Descarregar el certificat del servidor:
   ```bash
   openssl s_client -connect egreta.uab.cat:443 </dev/null 2>/dev/null \
     | openssl x509 -outform PEM > egreta.cer
   ```

2. Importar-lo al truststore de la JVM:
   ```bash
   keytool -import -trustcacerts -alias egreta \
     -keystore $JAVA_HOME/jre/lib/security/cacerts \
     -file egreta.cer \
     -storepass changeit
   ```
   (el password per defecte del truststore es `changeit`)

3. Reiniciar l'agent ODI

**Solucio alternativa (si no teniu acces a keytool):**

Afegir a les opcions JVM de l'agent:
```
-Djavax.net.ssl.trustStore=/path/to/custom_cacerts
```

**Solucio alternativa (TLS antic):**

Si la JVM es Java 7 i el servidor requereix TLS 1.2:
```
-Dhttps.protocols=TLSv1.2
```

### 9.3 `java.lang.OutOfMemoryError: Java heap space`

**Causa:** La JVM de l'agent ODI te massa poc heap (per defecte 256MB).

**Simptoma:** Error durant el processament, especialment si `PAGE_SIZE` es gran.

**Solucio:**

1. Localitzar el fitxer de configuracio de l'agent:
   - Standalone: `<DOMAIN_HOME>/bin/setDomainEnv.sh` (o `.bat`)
   - Alternativa: `<ODI_HOME>/oracledi/agent/bin/odiparams.sh`
2. Afegir o modificar:
   ```bash
   USER_MEM_ARGS="-Xms512m -Xmx2g"
   ```
3. Reiniciar l'agent

**Prevencio:** El template ja processa pagina a pagina (consum constant ~5MB). Si l'error persisteix amb `-Xmx2g`, pot haver-hi una fuita de memoria en un altre component d'ODI.

### 9.4 `java.lang.ClassNotFoundException: org.json.JSONObject`

**Causa:** El JAR `json-XXXXX.jar` no es al classpath de l'agent ODI.

**Simptoma:** Error `ImportError` al intentar `from org.json import JSONObject` (Tier 2).

**Solucio:**

1. Descarregar el JAR des de Maven Central:
   https://search.maven.org/artifact/org.json/json
2. Copiar a: `<ODI_HOME>/oracledi/agent/drivers/`
3. Reiniciar l'agent ODI

**Nota:** Si no podeu instal·lar JARs (restriccions de change management), el script usara Tier 1 (javax.json, si WebLogic) o Tier 3 (eval). No es un blocker.

### 9.5 JDBC: Connection refused / TNS: no listener

**Causa:** La URL JDBC es incorrecta, hi ha un firewall, o el listener d'Oracle esta apagat.

**Simptoma:** Error a la linia `DriverManager.getConnection()`.

**Solucio:**

1. **Verificar connectivitat de xarxa** des del servidor de l'agent:
   ```bash
   telnet db_host 1521
   ```
   Ha de respondre. Si no: problema de firewall o xarxa.

2. **Verificar el format JDBC URL:**
   ```
   # Service Name (recomanat):
   jdbc:oracle:thin:@//hostname:1521/service_name

   # SID (antic):
   jdbc:oracle:thin:@hostname:1521:SID

   # IMPORTANT: el doble // es obligatori per a Service Name
   ```

3. **Verificar el listener:**
   ```bash
   tnsping service_name
   ```

4. **Verificar credencials:**
   ```bash
   sqlplus user/password@//hostname:1521/service_name
   ```

### 9.6 `ORA-00942: table or view does not exist`

**Causa:** L'usuari JDBC no te acces a la taula o la taula no existeix.

**Solucio:**

1. Verificar que la taula existeix:
   ```sql
   SELECT table_name FROM all_tables WHERE table_name = 'BCK_PURE_AWARD';
   ```

2. Si existeix en un altre schema, prefixar:
   ```python
   TABLE_AWARD = 'SCHEMA_OWNER.BCK_PURE_AWARD'
   ```

3. O concedir permisos:
   ```sql
   GRANT INSERT, SELECT, DELETE ON schema_owner.BCK_PURE_AWARD TO bck_user;
   GRANT INSERT, SELECT, DELETE ON schema_owner.BCK_PURE_AWARD_HOLDER TO bck_user;
   GRANT INSERT, SELECT, DELETE ON schema_owner.BCK_PURE_AWARD_FUNDING TO bck_user;
   GRANT INSERT, SELECT, DELETE ON schema_owner.BCK_PURE_AWARD_IDENTIFIER TO bck_user;
   ```

### 9.7 Script supera 100.000 caracters

**Causa:** Limit intern d'ODI per al camp Target Command d'un task.

**Simptoma:** Error de truncament o l'script es talla al final.

**Solucio:**

1. Desar el script complet com a fitxer al servidor de l'agent:
   ```bash
   scp ingesta_awards_odi.py agent_server:/opt/odi/scripts/
   ```

2. Al Target Command del task, escriure nomes:
   ```python
   execfile('/opt/odi/scripts/ingesta_awards_odi.py')
   ```

3. **IMPORTANT**: si el script usa variables ODI (`#GLOBAL.VAR`), la substitucio nomes funciona dins del Target Command, NO dins del fitxer extern. Solucio: al Target Command, definir les variables i despres `execfile`:
   ```python
   PURE_API_URL = '#GLOBAL.PURE_API_URL'
   PURE_API_KEY = '#GLOBAL.PURE_API_KEY'
   BCK_JDBC_URL = '#GLOBAL.BCK_JDBC_URL'
   BCK_USER     = '#GLOBAL.BCK_USER'
   BCK_PASSWORD = '#GLOBAL.BCK_PASSWORD'
   execfile('/opt/odi/scripts/ingesta_awards_odi.py')
   ```
   I al fitxer extern, substituir les constants per lectures de variables globals de Jython.

### 9.8 Variables ODI no se substitueixen

**Simptoma:** El log mostra literals com `#GLOBAL.PURE_API_URL` en lloc del valor real.

**Causes i solucions:**

| Causa | Exemple erroni | Exemple correcte |
|-------|---------------|-----------------|
| Case incorrecto | `'#GLOBAL.pure_api_url'` | `'#GLOBAL.PURE_API_URL'` |
| Variable no existeix | `'#GLOBAL.API_URL'` (no creada) | Crear la variable a Global Objects |
| Cometes incorrectes | `#GLOBAL.PURE_API_URL` (per string) | `'#GLOBAL.PURE_API_URL'` (amb cometes fora) |
| Variable de projecte | `'#GLOBAL.VAR'` (pero es de projecte) | `'#PROJECT_CODE.VAR'` |

### 9.9 HTTP 429 Too Many Requests

**Causa:** Massa peticions a la Pure API en poc temps.

**Solucio:** Augmentar el delay entre pagines al template:
```python
DELAY_BETWEEN_PAGES = 1.0   # 1 segon (en lloc de 0.5)
```

Si persisteix, contactar l'administrador de Pure per preguntar el rate limit.

### 9.10 Caracters estranys o errors d'encoding

**Simptoma:** Caracters catalans (c, ñ, accents) apareixen com `?` o `â€™`.

**Causes i solucions:**

1. **HTTP**: El template ja usa `InputStreamReader(stream, "UTF-8")`. Si el problema persisteix, verificar que la Pure API retorna UTF-8 (hauria de ser-ho per defecte).

2. **Base de dades**: Verificar el character set d'Oracle:
   ```sql
   SELECT value FROM nls_database_parameters WHERE parameter = 'NLS_CHARACTERSET';
   ```
   Hauria de ser `AL32UTF8`. Si es `WE8ISO8859P1`, contactar el DBA.

3. **CSV**: El template ja escriu amb encoding UTF-8 via `BufferedWriter`.

### 9.11 El paquet no executa els passos en l'ordre correcte

**Causa:** Falten les fletxes de connexio entre passos al diagrama del paquet.

**Solucio:**

1. Verificar que un pas te l'etiqueta **First Step** (simbol especial)
2. Verificar que hi ha fletxes verdes (**ok**) entre tots els passos consecutius
3. Si falta una fletxa: toolbar > seleccionar **Next Step on Success** > arrossegar entre passos
4. Si un pas no s'executa: verificar que no hi ha un **Next Step on Failure** (fletxa vermella) que el salta

---

## 10. Validacio

Despres de la primera execucio, es fonamental validar que les dades carregades son correctes.

### 10.1 Comptar registres

```sql
-- El count ha de coincidir amb el "count" retornat per l'API
SELECT COUNT(*) AS total_awards FROM BCK_PURE_AWARD;

-- Verificar que les taules filles tenen registres
SELECT COUNT(*) AS total_holders FROM BCK_PURE_AWARD_HOLDER;
SELECT COUNT(*) AS total_fundings FROM BCK_PURE_AWARD_FUNDING;
SELECT COUNT(*) AS total_identifiers FROM BCK_PURE_AWARD_IDENTIFIER;
```

### 10.2 Verificar integritat referencial

```sql
-- No hauria de retornar files (tots els holders han de tenir un award pare)
SELECT h.AWARD_UUID
FROM BCK_PURE_AWARD_HOLDER h
LEFT JOIN BCK_PURE_AWARD a ON a.AWARD_UUID = h.AWARD_UUID
WHERE a.AWARD_UUID IS NULL;

-- Idem per fundings i identifiers
SELECT f.AWARD_UUID
FROM BCK_PURE_AWARD_FUNDING f
LEFT JOIN BCK_PURE_AWARD a ON a.AWARD_UUID = f.AWARD_UUID
WHERE a.AWARD_UUID IS NULL;
```

### 10.3 Comparar amb dades XML existents

Si disposeu de les dades carregades amb el proces XML actual, podeu comparar:

```sql
-- Seleccionar 10 awards aleatoris i comparar camps clau
SELECT AWARD_UUID, PURE_ID, TITLE_CA, AWARD_DATE, WORKFLOW_STEP
FROM BCK_PURE_AWARD
WHERE ROWNUM <= 10;
```

Verificar manualment que els valors coincideixen amb els de la taula XML equivalent.

### 10.4 Verificar camps nullables

```sql
-- Quants awards no tenen titol en catala?
SELECT COUNT(*) FROM BCK_PURE_AWARD WHERE TITLE_CA IS NULL OR TITLE_CA = '';

-- Quants awards no tenen status?
SELECT COUNT(*) FROM BCK_PURE_AWARD WHERE STATUS_TYPE IS NULL OR STATUS_TYPE = '';

-- Distribucio per workflow step
SELECT WORKFLOW_STEP, COUNT(*) AS total
FROM BCK_PURE_AWARD
GROUP BY WORKFLOW_STEP
ORDER BY total DESC;

-- Distribucio per status type
SELECT STATUS_TYPE, COUNT(*) AS total
FROM BCK_PURE_AWARD
GROUP BY STATUS_TYPE
ORDER BY total DESC;
```

### 10.5 Verificar el log de sessio ODI

Al log haurien d'apareixer:

1. El tier JSON detectat
2. El total d'awards disponibles a l'API
3. El progres pagina a pagina
4. El resum final amb totals i temps d'execucio
5. Cap linia `ERROR` (nomes `WARN` es acceptable)

---

## 11. Referencies

### Referencies del projecte (context.md)

| # | Referencia | URL |
|---|-----------|-----|
| [1] | euroCRIS — Why does one need a CRIS? | https://eurocris.org/why-does-one-need-cris |
| [2] | UAB — Informe ciberatac | https://www.uab.cat/doc/informe-ciberatac-claustre-des21 |
| [3] | IBM — What is a data warehouse? | https://www.ibm.com/mx-es/think/topics/data-warehouse |
| [4] | Webservice: definicion y ejemplos | https://nextcode.global/webservice-definicion-y-ejemplos/ |
| [5] | Pure API documentation | https://api.elsevierpure.com/ws/api/documentation/index.html |
| [6] | Oracle — Data warehouse concepts | https://docs.oracle.com/en/database/oracle/oracle-database/26/dwhsg/introduction-data-warehouse-concepts.html |
| [7] | Postman — API Client | https://www.postman.com/product/api-client/ |
| [8] | ODI Documentation (14.1.2) | https://docs.oracle.com/en/middleware/fusion-middleware/data-integrator/14.1.2/index.html |
| [9] | Flatterer (JSON to CSV) | https://github.com/kindly/flatterer |
| [10] | Saxonica — What is Saxon? | https://www.saxonica.com/html/documentation12/about/whatis.html |

### Referencies tecniques addicionals

| Tema | URL |
|------|-----|
| Pure API Awards (UAB) | https://egreta.uab.cat/ws/api/api-docs/index.html |
| ODI 12c Procedures | https://docs.oracle.com/en/middleware/fusion-middleware/data-integrator/12.2.1.4/odidg/working-procedures.html |
| ODI 12c Variables | https://docs.oracle.com/en/middleware/fusion-middleware/data-integrator/12.2.1.4/odidg/ (capitol variables) |
| ODI 12c Packages | https://docs.oracle.com/en/middleware/fusion-middleware/data-integrator/12.2.1.4/odidg/ (capitol packages) |
| javax.json (JSR 353) | Part de WebLogic 12c (no requereix descarga) |
| org.json (JSON-java) | https://github.com/stleary/JSON-java |
| Jython 2.5.x | https://www.jython.org/ |
| RFC 4180 — CSV Format | https://tools.ietf.org/html/rfc4180 |
| CERIF Data Model | https://eurocris.org/cerif/main-features-cerif |
| XSLT 3.0 JSON Functions | https://www.w3.org/TR/xpath-functions-31/#json-functions |
| Saxon JSON Processing | https://www.saxonica.com/html/documentation12/functions/fn/json-to-xml.html |
| ODI JSON Complex File | https://docs.oracle.com/en/middleware/fusion-middleware/data-integrator/12.2.1.3/tutorial-json-file/index.html |

---

*Document generat com a part del TFG — UAB 2025/2026*  
*Tutoritzat per: Espinosa Morales, Antonio (Area d'Arquitectura i Tecnologia de Computadors)*
