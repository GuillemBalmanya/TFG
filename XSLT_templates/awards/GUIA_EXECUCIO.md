# Guia d'execució i proves — Templates JSON Awards

## Prerequisits

1. **Java** instal·lat al sistema (JRE 8 o superior)
2. **Saxon 9 HE** (`saxon9he.jar`) a l'arrel del directori SAXON
3. **Fitxer JSON** amb dades d'awards descarregat de l'API EGRETA/Pure
4. **Directori de treball**: L'arrel de SAXON (on hi ha `saxon9he.jar`)

> **Nota important:** Totes les comandes s'executen des del directori arrel de SAXON.
> A Windows: `cd C:\ruta\al\directori\SAXON`

---

## 1. Test ràpid — Prova de concepte

Abans de res, verifiquem que Saxon pot processar JSON correctament amb el template més simple:

```bat
java -jar saxon9he.jar -s:xslt\awards\ok\json\dummy.xml -xsl:xslt\awards\ok\json\awards_oc_recompte.xslt json-file=xslt\awards\ok\json\awards_test.json
```

**Resultat esperat:** Una línia amb el recompte d'awards, p.ex.:
```
recompte_count;recompte_variable
43196;awards
```

Si funciona, el pipeline JSON està operatiu. Si dona error, consulteu la secció **Resolució de problemes**.

---

## 2. Descarregar JSON real de l'API

El JSON de mostra (`awards_test.json`) només conté 1 registre. Per a proves reals cal descarregar dades completes.

### API JSON d'EGRETA

- **Documentació:** https://egreta.uab.cat/ws/api/api-docs/index.html?url=/ws/api/openapi.yaml#/
- **API Key JSON:** `c5f8eab5-e923-4684-97f3-5c6508b25ec0`

### Exemple de descàrrega amb curl

```bat
curl -H "api-key: c5f8eab5-e923-4684-97f3-5c6508b25ec0" ^
     -H "Accept: application/json" ^
     "https://egreta.uab.cat/ws/api/524/awards?size=100&offset=0" ^
     -o xml\awards.json
```

> **Nota:** Deseu el fitxer a la carpeta `xml\` (o on vulgueu, ajustant el paràmetre `json-file` de la comanda Saxon). El paràmetre `size` controla quants registres es descarreguen (màxim habitual: 100-1000).

### Descàrrega completa (paginada)

Si cal descarregar tots els registres (43.196 segons el count), caldrà fer múltiples crides incrementant `offset`:

```
offset=0&size=1000
offset=1000&size=1000
offset=2000&size=1000
...
```

O bé ajustar el `size` al màxim que permeti l'API i fer una sola crida si és possible.

---

## 3. Comandes d'execució — Tots els templates

### Convencions

- **`-s:`** → Sempre `xslt\awards\ok\json\dummy.xml` (fitxer XML buit, requerit per Saxon)
- **`-xsl:`** → El template JSON a executar
- **`-o:`** → Fitxer CSV de sortida
- **`json-file=`** → Ruta al fitxer JSON amb les dades (relativa al directori d'execució)

### Variable: ruta al JSON

A les comandes següents, substituïu `xml\awards.json` per la ruta real al vostre fitxer JSON. Si useu el JSON de mostra: `xslt\awards\ok\json\awards_test.json`

---

### 3.1. awards_oc_recompte.xslt — Recompte

```bat
java -jar saxon9he.jar -s:xslt\awards\ok\json\dummy.xml -xsl:xslt\awards\ok\json\awards_oc_recompte.xslt -o:csv\awards\awards_recompte_json.csv json-file=xml\awards.json
```

**Sortida:** Recompte total d'awards (`count` del JSON).

---

### 3.2. awards_rao.xslt — RAO principal

```bat
java -jar saxon9he.jar -s:xslt\awards\ok\json\dummy.xml -xsl:xslt\awards\ok\json\awards_rao.xslt -o:csv\awards\awards_rao_json.csv json-file=xml\awards.json
```

**Sortida:** Fitxer principal RAO amb tots els camps d'awards.
**Comparar amb:** `csv\awards\awards_rao.csv`

---

### 3.3. awards_rao2.xslt — RAO2 (justificació corregida)

```bat
java -jar saxon9he.jar -s:xslt\awards\ok\json\dummy.xml -xsl:xslt\awards\ok\json\awards_rao2.xslt -o:csv\awards\awards_rao2_json.csv json-file=xml\awards.json
```

**Sortida:** Igual que RAO però amb lògica de justificació econòmica diferent.
**Comparar amb:** `csv\awards\awards_rao.csv` (mateixa estructura)

---

### 3.4. awards-estat_oc.xslt — Estat dels awards (nou)

```bat
java -jar saxon9he.jar -s:xslt\awards\ok\json\dummy.xml -xsl:xslt\awards\ok\json\awards-estat_oc.xslt -o:csv\awards\awards-estat_json.csv json-file=xml\awards.json
```

**Sortida:** Estat de cada award amb statusDetails.
**Comparar amb:** `csv\awards\awards_estat_20230305.csv`

---

### 3.5. awards-estat_old_oc.xslt — Estat antic (keywords)

```bat
java -jar saxon9he.jar -s:xslt\awards\ok\json\dummy.xml -xsl:xslt\awards\ok\json\awards-estat_old_oc.xslt -o:csv\awards\awards-estat_old_json.csv json-file=xml\awards.json
```

**Sortida:** Estat extret de keywordGroups (mètode antic pre-2021).

---

### 3.6. awards-holders_oc.xslt — Membres de l'equip

```bat
java -jar saxon9he.jar -s:xslt\awards\ok\json\dummy.xml -xsl:xslt\awards\ok\json\awards-holders_oc.xslt -o:csv\awards\awards-holders_json.csv json-file=xml\awards.json
```

**Sortida:** Llistat de holders per award (rols, noms, dates).
**Comparar amb:** `csv\awards\awards-holders.csv`

---

### 3.7. awards-ids_oc.xslt — Identificadors

```bat
java -jar saxon9he.jar -s:xslt\awards\ok\json\dummy.xml -xsl:xslt\awards\ok\json\awards-ids_oc.xslt -o:csv\awards\awards-ids_json.csv json-file=xml\awards.json
```

**Sortida:** Identificadors de cada award (pureId, externalId, tipus).
**Comparar amb:** `csv\awards\awards_ids.csv`

---

### 3.8. awards-comanagers_oc.xslt — Co-managers

```bat
java -jar saxon9he.jar -s:xslt\awards\ok\json\dummy.xml -xsl:xslt\awards\ok\json\awards-comanagers_oc.xslt -o:csv\awards\awards-comanagers_json.csv json-file=xml\awards.json
```

**Sortida:** Unitats organitzatives co-gestores per award.

---

### 3.9. Awards-natureTypes_oc.xslt — Tipus de naturalesa

```bat
java -jar saxon9he.jar -s:xslt\awards\ok\json\dummy.xml -xsl:xslt\awards\ok\json\Awards-natureTypes_oc.xslt -o:csv\awards\awards-natureTypes_json.csv json-file=xml\awards.json
```

**Sortida:** Tipus de naturalesa per award.
**Comparar amb:** `csv\awards\awards_natureTypes.csv` o `csv\awards\awards-naturetyes.csv`

---

### 3.10. awards-relatedApplications_oc.xslt — Sol·licituds relacionades

```bat
java -jar saxon9he.jar -s:xslt\awards\ok\json\dummy.xml -xsl:xslt\awards\ok\json\awards-relatedApplications_oc.xslt -o:csv\awards\awards-relapps_json.csv json-file=xml\awards.json
```

**Sortida:** Sol·licituds relacionades per award.
**Comparar amb:** `csv\awards\awards-relapps.csv`

---

### 3.11. awards-fundings_oc.xslt — Finançaments

```bat
java -jar saxon9he.jar -s:xslt\awards\ok\json\dummy.xml -xsl:xslt\awards\ok\json\awards-fundings_oc.xslt -o:csv\awards\awards-fundings_json.csv json-file=xml\awards.json
```

**Sortida:** Detalls de finançament per award (funder, imports, visibilitat).
**Comparar amb:** `csv\awards\awards-fundings.csv`

---

### 3.12. awards-collaborators_oc.xslt — Col·laboradors

```bat
java -jar saxon9he.jar -s:xslt\awards\ok\json\dummy.xml -xsl:xslt\awards\ok\json\awards-collaborators_oc.xslt -o:csv\awards\awards-collaborators_json.csv json-file=xml\awards.json
```

**Sortida:** Col·laboradors per award (organitzacions internes i externes).
**Comparar amb:** `csv\awards\awards-collaborators.csv`

---

### 3.13. awards-fundings-collaborators_oc.xslt — Col·laboradors de finançament

```bat
java -jar saxon9he.jar -s:xslt\awards\ok\json\dummy.xml -xsl:xslt\awards\ok\json\awards-fundings-collaborators_oc.xslt -o:csv\awards\awards-fundings-collaborators_json.csv json-file=xml\awards.json
```

**Sortida:** Col·laboradors dins de cada finançament (niuament profund).
**Comparar amb:** `csv\awards\awards-awards-percent-part.csv`

---

### 3.14. awards-budgetAndExpenditures_oc.xslt — Pressupostos i despeses

```bat
java -jar saxon9he.jar -s:xslt\awards\ok\json\dummy.xml -xsl:xslt\awards\ok\json\awards-budgetAndExpenditures_oc.xslt -o:csv\awards\awards-budgetAndExpenditures_json.csv json-file=xml\awards.json
```

**Sortida:** Registres de pressupostos i despeses per funding.
**Comparar amb:** `csv\awards\awards-budgeAndExpenditures.csv`

---

### 3.15. awards-accounts_oc.xslt — Comptes (4 nivells)

```bat
java -jar saxon9he.jar -s:xslt\awards\ok\json\dummy.xml -xsl:xslt\awards\ok\json\awards-accounts_oc.xslt -o:csv\awards\awards-accounts_json.csv json-file=xml\awards.json
```

**Sortida:** Comptes i pressupostos anuals (fundings -> budgets -> accounts -> yearlyBudgets).

---

### 3.16. awards-budget-periodes_oc.xslt — Períodes pressupostaris

```bat
java -jar saxon9he.jar -s:xslt\awards\ok\json\dummy.xml -xsl:xslt\awards\ok\json\awards-budget-periodes_oc.xslt -o:csv\awards\awards-budget-periodes_json.csv json-file=xml\awards.json
```

**Sortida:** Períodes pressupostaris extrets de keywordGroups.
**Comparar amb:** `csv\awards\awards-budget-periodes.csv`

---

## 4. Script per executar tots els templates

Per comoditat, podeu crear un fitxer `.bat` que executi tots els templates d'un cop.
Deseu el contingut següent com `executar_json_awards.bat` al directori arrel de SAXON:

```bat
@echo off
REM ============================================
REM Execucio de tots els templates JSON - Awards
REM ============================================
REM Ajusteu la variable JSON_FILE a la ruta del vostre fitxer JSON
REM ============================================

set JSON_FILE=xml\awards.json
set DUMMY=xslt\awards\ok\json\dummy.xml
set XSL_DIR=xslt\awards\ok\json
set CSV_DIR=csv\awards

echo [1/16] Recompte...
java -jar saxon9he.jar -s:%DUMMY% -xsl:%XSL_DIR%\awards_oc_recompte.xslt -o:%CSV_DIR%\awards_recompte_json.csv json-file=%JSON_FILE%
if errorlevel 1 echo    ERROR al template recompte!

echo [2/16] RAO principal...
java -jar saxon9he.jar -s:%DUMMY% -xsl:%XSL_DIR%\awards_rao.xslt -o:%CSV_DIR%\awards_rao_json.csv json-file=%JSON_FILE%
if errorlevel 1 echo    ERROR al template RAO!

echo [3/16] RAO2 (justificacio corregida)...
java -jar saxon9he.jar -s:%DUMMY% -xsl:%XSL_DIR%\awards_rao2.xslt -o:%CSV_DIR%\awards_rao2_json.csv json-file=%JSON_FILE%
if errorlevel 1 echo    ERROR al template RAO2!

echo [4/16] Estat (nou)...
java -jar saxon9he.jar -s:%DUMMY% -xsl:%XSL_DIR%\awards-estat_oc.xslt -o:%CSV_DIR%\awards-estat_json.csv json-file=%JSON_FILE%
if errorlevel 1 echo    ERROR al template estat!

echo [5/16] Estat antic (keywords)...
java -jar saxon9he.jar -s:%DUMMY% -xsl:%XSL_DIR%\awards-estat_old_oc.xslt -o:%CSV_DIR%\awards-estat_old_json.csv json-file=%JSON_FILE%
if errorlevel 1 echo    ERROR al template estat_old!

echo [6/16] Holders...
java -jar saxon9he.jar -s:%DUMMY% -xsl:%XSL_DIR%\awards-holders_oc.xslt -o:%CSV_DIR%\awards-holders_json.csv json-file=%JSON_FILE%
if errorlevel 1 echo    ERROR al template holders!

echo [7/16] Identificadors...
java -jar saxon9he.jar -s:%DUMMY% -xsl:%XSL_DIR%\awards-ids_oc.xslt -o:%CSV_DIR%\awards-ids_json.csv json-file=%JSON_FILE%
if errorlevel 1 echo    ERROR al template ids!

echo [8/16] Co-managers...
java -jar saxon9he.jar -s:%DUMMY% -xsl:%XSL_DIR%\awards-comanagers_oc.xslt -o:%CSV_DIR%\awards-comanagers_json.csv json-file=%JSON_FILE%
if errorlevel 1 echo    ERROR al template comanagers!

echo [9/16] Nature Types...
java -jar saxon9he.jar -s:%DUMMY% -xsl:%XSL_DIR%\Awards-natureTypes_oc.xslt -o:%CSV_DIR%\awards-natureTypes_json.csv json-file=%JSON_FILE%
if errorlevel 1 echo    ERROR al template natureTypes!

echo [10/16] Related Applications...
java -jar saxon9he.jar -s:%DUMMY% -xsl:%XSL_DIR%\awards-relatedApplications_oc.xslt -o:%CSV_DIR%\awards-relapps_json.csv json-file=%JSON_FILE%
if errorlevel 1 echo    ERROR al template relatedApplications!

echo [11/16] Fundings...
java -jar saxon9he.jar -s:%DUMMY% -xsl:%XSL_DIR%\awards-fundings_oc.xslt -o:%CSV_DIR%\awards-fundings_json.csv json-file=%JSON_FILE%
if errorlevel 1 echo    ERROR al template fundings!

echo [12/16] Collaborators...
java -jar saxon9he.jar -s:%DUMMY% -xsl:%XSL_DIR%\awards-collaborators_oc.xslt -o:%CSV_DIR%\awards-collaborators_json.csv json-file=%JSON_FILE%
if errorlevel 1 echo    ERROR al template collaborators!

echo [13/16] Fundings-Collaborators...
java -jar saxon9he.jar -s:%DUMMY% -xsl:%XSL_DIR%\awards-fundings-collaborators_oc.xslt -o:%CSV_DIR%\awards-fundings-collaborators_json.csv json-file=%JSON_FILE%
if errorlevel 1 echo    ERROR al template fundings-collaborators!

echo [14/16] Budget and Expenditures...
java -jar saxon9he.jar -s:%DUMMY% -xsl:%XSL_DIR%\awards-budgetAndExpenditures_oc.xslt -o:%CSV_DIR%\awards-budgetAndExpenditures_json.csv json-file=%JSON_FILE%
if errorlevel 1 echo    ERROR al template budgetAndExpenditures!

echo [15/16] Accounts (4 nivells)...
java -jar saxon9he.jar -s:%DUMMY% -xsl:%XSL_DIR%\awards-accounts_oc.xslt -o:%CSV_DIR%\awards-accounts_json.csv json-file=%JSON_FILE%
if errorlevel 1 echo    ERROR al template accounts!

echo [16/16] Budget Periodes...
java -jar saxon9he.jar -s:%DUMMY% -xsl:%XSL_DIR%\awards-budget-periodes_oc.xslt -o:%CSV_DIR%\awards-budget-periodes_json.csv json-file=%JSON_FILE%
if errorlevel 1 echo    ERROR al template budget-periodes!

echo.
echo ============================================
echo Execucio completada. Reviseu csv\awards\*_json.csv
echo ============================================
pause
```

---

## 5. Verificació de resultats

### 5.1. Verificació bàsica

Després d'executar cada template, comproveu que:

1. **El fitxer CSV s'ha creat** i no està buit
2. **La primera línia** conté la capçalera esperada (noms de columnes separats per `;`)
3. **El nombre de columnes** és consistent a totes les files
4. **No hi ha errors** a la sortida de la consola

### 5.2. Comparació amb CSV originals (XML)

Per verificar que la migració és correcta, compareu la sortida JSON amb la sortida XML existent.

**Important:** Per fer una comparació justa, cal que el JSON i l'XML continguin les mateixes dades. Idealment:
1. Descarregueu les dades d'awards via l'API XML i via l'API JSON al mateix moment
2. Executeu els templates XML originals sobre l'XML
3. Executeu els templates JSON nous sobre el JSON
4. Compareu els CSV resultants

#### Comparació manual

Obriu els dos CSV (original i JSON) a Excel o LibreOffice Calc i compareu:
- Mateixa capçalera (noms de columnes)
- Mateix nombre de files (per a les mateixes dades)
- Valors coincidents per als mateixos registres (busqueu per uuid)

#### Comparació amb WinMerge o diff

Si teniu WinMerge instal·lat:
```bat
WinMerge csv\awards\awards_rao.csv csv\awards\awards_rao_json.csv
```

O amb PowerShell:
```powershell
Compare-Object (Get-Content csv\awards\awards_rao.csv) (Get-Content csv\awards\awards_rao_json.csv)
```

### 5.3. Taula de comparació

| Template JSON | CSV sortida JSON | CSV referència XML |
|---|---|---|
| `awards_oc_recompte.xslt` | `awards_recompte_json.csv` | — (no hi ha equivalent) |
| `awards_rao.xslt` | `awards_rao_json.csv` | `awards_rao.csv` |
| `awards_rao2.xslt` | `awards_rao2_json.csv` | `awards_rao.csv` |
| `awards-estat_oc.xslt` | `awards-estat_json.csv` | `awards_estat_20230305.csv` |
| `awards-estat_old_oc.xslt` | `awards-estat_old_json.csv` | — |
| `awards-holders_oc.xslt` | `awards-holders_json.csv` | `awards-holders.csv` |
| `awards-ids_oc.xslt` | `awards-ids_json.csv` | `awards_ids.csv` |
| `awards-comanagers_oc.xslt` | `awards-comanagers_json.csv` | — |
| `Awards-natureTypes_oc.xslt` | `awards-natureTypes_json.csv` | `awards_natureTypes.csv` |
| `awards-relatedApplications_oc.xslt` | `awards-relapps_json.csv` | `awards-relapps.csv` |
| `awards-fundings_oc.xslt` | `awards-fundings_json.csv` | `awards-fundings.csv` |
| `awards-collaborators_oc.xslt` | `awards-collaborators_json.csv` | `awards-collaborators.csv` |
| `awards-fundings-collaborators_oc.xslt` | `awards-fundings-collaborators_json.csv` | `awards-awards-percent-part.csv` |
| `awards-budgetAndExpenditures_oc.xslt` | `awards-budgetAndExpenditures_json.csv` | `awards-budgeAndExpenditures.csv` |
| `awards-accounts_oc.xslt` | `awards-accounts_json.csv` | — |
| `awards-budget-periodes_oc.xslt` | `awards-budget-periodes_json.csv` | `awards-budget-periodes.csv` |

---

## 6. Resolució de problemes

### Error: "Could not find or load main class"

Java no està instal·lat o no està al PATH del sistema.
```bat
java -version
```
Ha de mostrar versió 8 o superior. Si no, instal·leu Java JRE/JDK.

### Error: "Source file dummy.xml does not exist"

Esteu executant la comanda des d'un directori incorrecte. Assegureu-vos d'estar al directori arrel de SAXON:
```bat
cd C:\ruta\al\directori\SAXON
dir xslt\awards\ok\json\dummy.xml
```

### Error: "Cannot find the file specified" per json-file

La ruta al fitxer JSON és incorrecta. Verifiqueu:
```bat
dir xml\awards.json
```
Si el fitxer és en un altre lloc, ajusteu el paràmetre `json-file=`.

### Error: "XSLT 3.0 not supported" o similar

Verifiqueu que useu `saxon9he.jar` (no una versió anterior):
```bat
java -jar saxon9he.jar -?
```
Ha de dir "Saxon-HE 9.x" amb suport XSLT 3.0.

### Error: "Cannot compile stylesheet" amb missatges sobre fn:

Pot ser un problema de namespace. Verifiqueu que el template té:
```xml
xmlns:fn="http://www.w3.org/2005/xpath-functions"
```

### La sortida CSV està buida (només capçalera)

Causes possibles:
1. El JSON no conté l'array `items` o està buit
2. El JSON no conté els camps que el template espera (comportament correcte per camps opcionals)
3. L'estructura JSON és diferent de l'esperada — verifiqueu l'estructura del JSON amb un editor

### Caràcters estranys al CSV

Problema d'encoding. Saxon genera UTF-8 per defecte. Si obriu el CSV amb Excel, cal importar-lo com UTF-8:
- Dades > Obtenir dades externes > De fitxer text > Seleccionar "65001: Unicode (UTF-8)"

### Error: "XTSE0165: the template includes itself" o "cannot find functions.xslt"

El template intenta incloure `functions.xslt` però no el troba. Verifiqueu que `functions.xslt` existeix a la mateixa carpeta que el template (`xslt\awards\ok\json\`).

---

## 7. Ordre recomanat de proves

L'ordre recomanat és de menor a major complexitat:

| Fase | Templates | Objectiu |
|---|---|---|
| **1. Verificació bàsica** | `awards_oc_recompte.xslt` | Confirmar que el pipeline JSON funciona |
| **2. Template principal** | `awards_rao.xslt` | Validar el template més complet |
| **3. Iteració plana** | `awards-estat_oc.xslt`, `awards-estat_old_oc.xslt` | Iteració simple sobre awards |
| **4. Niuament simple** | `awards-holders_oc.xslt`, `awards-ids_oc.xslt`, `awards-comanagers_oc.xslt`, `Awards-natureTypes_oc.xslt`, `awards-relatedApplications_oc.xslt` | Un nivell de niuament |
| **5. Niuament amb lògica** | `awards-fundings_oc.xslt`, `awards-collaborators_oc.xslt` | Lògica condicional dins iteració |
| **6. Niuament profund** | `awards-fundings-collaborators_oc.xslt`, `awards-budgetAndExpenditures_oc.xslt`, `awards-budget-periodes_oc.xslt` | Múltiples nivells |
| **7. Niuament molt profund** | `awards-accounts_oc.xslt` | 4 nivells de niuament |
| **8. Validació final** | `awards_rao2.xslt` | Confirmar variant RAO amb justificació |

---

## 8. Integració ODI

Un cop validats els templates, per integrar-los a Oracle Data Integrator:

### Canvis necessaris als packages ODI

1. **Pas de descàrrega:** Canviar l'endpoint XML per l'endpoint JSON
   - Header: Afegir `Accept: application/json`
   - API Key: De `54f08e92-3fa6-4a1f-9970-b5ecac8a7403` (XML) a `c5f8eab5-e923-4684-97f3-5c6508b25ec0` (JSON)
   - Desar com `.json` en lloc de `.xml`

2. **Pas de transformació Saxon:** Canviar la comanda
   - **Abans:** `java -jar saxon9he.jar -s:xml\awards.xml -xsl:xslt\awards\ok\<template>.xslt -o:csv\awards\<output>.csv`
   - **Després:** `java -jar saxon9he.jar -s:xslt\awards\ok\json\dummy.xml -xsl:xslt\awards\ok\json\<template>.xslt -o:csv\awards\<output>.csv json-file=xml\awards.json`

3. **Assegurar que `dummy.xml` està accessible** des del directori d'execució d'ODI

4. **El pas de càrrega al DWH no canvia** — els CSV tenen el mateix format

### Migració gradual recomanada

Es pot migrar template a template, verificant que el CSV generat pel template JSON és idèntic al generat pel template XML. No cal migrar tots els templates alhora.

---

## 9. Fitxers de referència

| Fitxer | Ubicació | Descripció |
|---|---|---|
| `dummy.xml` | `xslt\awards\ok\json\` | XML mínim per Saxon |
| `awards_test.json` | `xslt\awards\ok\json\` | JSON de mostra (1 registre) |
| `functions.xslt` | `xslt\awards\ok\json\` | Funcions compartides (v3.0, JSON) |
| `MIGRACIO_XML_A_JSON.md` | `xslt\awards\ok\json\` | Documentació tècnica de la migració |
| `llegeix-me.txt` | Arrel SAXON | Instruccions generals i claus API |

---

*Guia creada el 2026-03-31. Consulteu `MIGRACIO_XML_A_JSON.md` per als detalls tècnics de la migració.*
