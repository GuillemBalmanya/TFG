# Migració XSLT Awards: XML a JSON

## Resum del projecte

Migració del pipeline ETL de Saxon XSLT per al domini **awards** de la Universitat Autònoma de Barcelona (UAB). Els templates XSLT originals consumeixen dades XML de l'API EGRETA/Pure i generen fitxers CSV delimitats per punt i coma (`;`) que alimenten el Data Warehouse (DWH) via Oracle Data Integrator (ODI).

La migració converteix els templates per consumir **dades JSON** en lloc d'XML, utilitzant les capacitats XSLT 3.0 de Saxon 9 HE.

---

## Abast

- **Domini:** Només awards (16 templates + functions.xslt)
- **Motor:** Saxon 9 HE (build 2019-12-06) — confirmat compatible amb XSLT 3.0
- **Sortida:** Mateixos fitxers CSV amb delimitador `;` (sense canvis al format de sortida)
- **Ubicació fitxers nous:** `xslt/awards/ok/json/` (els originals a `xslt/awards/ok/` NO es modifiquen)

---

## Arquitectura de la solució

### Patró d'invocació

```bash
java -jar saxon9he.jar \
  -s:xslt/awards/ok/json/dummy.xml \
  -xsl:xslt/awards/ok/json/<template>.xslt \
  -o:csv/awards/<output>.csv \
  json-file=xml/<fitxer>.json
```

- **`dummy.xml`**: Fitxer XML mínim requerit per Saxon com a font (`-s:`). El contingut real es carrega del JSON.
- **`json-file`**: Paràmetre extern amb la ruta al fitxer JSON (relativa al directori d'execució).

### Flux de dades dins cada template

```
1. xsl:param name="json-file"          ← ruta al fitxer JSON
2. unparsed-text($json-file)            ← llegeix JSON com a text
3. json-to-xml($json-text)             ← converteix a representació XML fn:*
4. Navegació amb XPath sobre fn:map/fn:array/fn:string/fn:number/fn:boolean
5. Sortida CSV amb separador ; i salt de línia
```

---

## Canvis aplicats a cada template

### Canvis comuns a TOTS els templates

| # | Canvi | Detall |
|---|---|---|
| 1 | `version="1.0"` → `version="3.0"` | Necessari per `json-to-xml()`, `unparsed-text()` |
| 2 | Afegir `xmlns:fn="http://www.w3.org/2005/xpath-functions"` | Namespace per als elements generats per `json-to-xml()` |
| 3 | Afegir `xmlns:xs="http://www.w3.org/2001/XMLSchema"` | Necessari per a `as="xs:string"` al paràmetre |
| 4 | Afegir `exclude-result-prefixes="fn uab xs"` | Evitar que els namespaces surtin al CSV |
| 5 | Afegir `<xsl:param name="json-file" as="xs:string"/>` | Ruta al fitxer JSON |
| 6 | Afegir variable `$json-text` amb `unparsed-text($json-file)` | Lectura del fitxer |
| 7 | Afegir variable `$json-xml` amb `json-to-xml($json-text)` | Conversió a XML navegable |
| 8 | Reescriure tots els XPaths | De navegació XML nativa a navegació `fn:*` |

### Transformació de XPaths

#### Mapping XML → JSON (json-to-xml)

La funció `json-to-xml()` converteix JSON a una representació XML amb el namespace `http://www.w3.org/2005/xpath-functions`:

| JSON | Element XML generat |
|---|---|
| `"clau": "valor"` | `<fn:string key="clau">valor</fn:string>` |
| `"clau": 123` | `<fn:number key="clau">123</fn:number>` |
| `"clau": true` | `<fn:boolean key="clau">true</fn:boolean>` |
| `"clau": {...}` | `<fn:map key="clau">...</fn:map>` |
| `"clau": [...]` | `<fn:array key="clau">...</fn:array>` |
| Element arrel | `<fn:map>` (sense `@key`) |

#### Regles de transformació XPath

| XPath XML original | XPath JSON equivalent | Notes |
|---|---|---|
| `result/items/award` | `$json-xml/fn:map/fn:array[@key='items']/fn:map` | El JSON no té `result` wrapper ni element `award` |
| `result/count` | `$json-xml/fn:map/fn:number[@key='count']` | |
| `@uuid` | `fn:string[@key='uuid']` | Atributs XML → propietats JSON |
| `@pureId` | `fn:number[@key='pureId']` | Numèric al JSON |
| `@externalId` | `fn:string[@key='externalId']` | |
| `@uri` | `fn:string[@key='uri']` | |
| `@key` | `fn:string[@key='key']` | |
| `@workflowStep` | — | Veure nota workflow |
| `@locale` | `@key` dins `fn:map` | Veure secció locales |
| `title/text` | `fn:map[@key='title']` | Per funcions locale |
| `type/@pureId` | `fn:map[@key='type']/fn:number[@key='pureId']` | |
| `type/@uri` | `fn:map[@key='type']/fn:string[@key='uri']` | |
| `type/term/text` | `fn:map[@key='type']/fn:map[@key='term']` | Per funcions locale |
| `info/createdDate` | `fn:string[@key='createdDate']` | Top-level al JSON |
| `info/modifiedDate` | `fn:string[@key='modifiedDate']` | Top-level al JSON |
| `workflow/@workflowStep` | `fn:map[@key='workflow']/fn:string[@key='step']` | Canvi de nom |
| `collaborative` | `fn:boolean[@key='collaborative']` | Boolean al JSON |
| `totalAwardedAmount` | `fn:string[@key='totalAwardedAmount']` | Pot ser string o number |
| `actualPeriod/startDate` | `fn:map[@key='actualPeriod']/fn:string[@key='startDate']` | |
| `fundings/funding` | `fn:array[@key='fundings']/fn:map` | Array JSON, sense element `funding` |
| `awardholders/awardholder` | `fn:array[@key='awardHolders']/fn:map` | Nota: camelCase al JSON |
| `collaborators/collaborator` | `fn:array[@key='collaborators']/fn:map` | |
| `ids/id` | `fn:array[@key='identifiers']/fn:map` | Nota: `ids` → `identifiers` al JSON |
| `../` (parent axis) | `../` | Funciona igual |
| `../../@pureId` | `../../fn:number[@key='pureId']` | |

#### Diferències de noms XML vs JSON

| Element XML | Propietat JSON | Nota |
|---|---|---|
| `awardholder` | `awardHolders` | CamelCase + plural |
| `personRole` | `role` | Nom diferent |
| `ids/id` | `identifiers` | Nom diferent |
| `workflow/@workflowStep` | `workflow.step` | Atribut → propietat, nom diferent |
| `info/createdDate` | `createdDate` | Puja a nivell superior |
| `info/modifiedDate` | `modifiedDate` | Puja a nivell superior |
| `externalOrganisation` | `externalOrganization` | Diferent ortografia (s→z) |
| `organisationalUnit` | `organisationalUnit` | Igual (no confirmat si canvia al JSON) |
| `fundingCollaborators/fundingCollaborator` | `fundingCollaborators` (array) | Sense element intermedi |
| `budgetAndExpenditures/budgetAndExpenditure` | `budgetAndExpenditures` (array) | Sense element intermedi |
| `keywordGroups/keywordGroup` | `keywordGroups` (array) | Sense element intermedi |
| `keywordContainers/keywordContainer` | `keywordContainers` (array) | Sense element intermedi |
| `freeKeywords/freeKeyword` | `freeKeywords` (array) | Sense element intermedi |
| `visibility/@key` | `visibility.key` | Atribut → propietat |
| `person/@uuid` | `person.uuid` | Atribut → propietat |
| `text[@locale='ca_ES']` | `fn:string[@key='ca_ES']` | Locale com a clau de mapa |
| `managingOrganisationalUnit/@uuid` | `managingOrganisationalUnit.uuid` | Atribut → propietat |
| `structuredKeyword/@pureId` | `structuredKeyword.pureId` | Atribut → propietat (o pot ser objecte) |
| `structuredKeyword/@uri` | `structuredKeyword.uri` | Atribut → propietat (o pot ser objecte) |
| `natureType` | `natureType` | Pot no existir al JSON (camp opcional) |

---

## Detall per template

### functions.xslt

**Canvi clau:** Les funcions de locale (`uab:clean_ca`, `uab:clean_en`, `uab:clean_es`, `uab:cutclean_ca`, etc.) originalment reben un node-set de `<text>` amb atribut `@locale` i filtren per `$element[@locale='ca_ES']`.

Al JSON, les locales es representen com un `fn:map` amb claus `ca_ES`, `en_GB`, `es_ES`:
```json
{"title": {"ca_ES": "Títol", "en_GB": "Title", "es_ES": "Título"}}
```
Que `json-to-xml()` converteix a:
```xml
<fn:map key="title">
  <fn:string key="ca_ES">Títol</fn:string>
  <fn:string key="en_GB">Title</fn:string>
  <fn:string key="es_ES">Título</fn:string>
</fn:map>
```

**Transformació de les funcions:**

| Funció | Abans | Després |
|---|---|---|
| `uab:clean_ca($element)` | `$element[@locale='ca_ES']` | `$element/fn:string[@key='ca_ES']` |
| `uab:clean_en($element)` | `$element[@locale='en_GB']` | `$element/fn:string[@key='en_GB']` |
| `uab:clean_es($element)` | `$element[@locale='es_ES']` | `$element/fn:string[@key='es_ES']` |
| `uab:cutclean_ca($element)` | `substring($element[@locale='ca_ES'],...)` | `substring($element/fn:string[@key='ca_ES'],...)` |
| `uab:cutclean_en($element)` | `substring($element[@locale='en_GB'],...)` | `substring($element/fn:string[@key='en_GB'],...)` |
| `uab:cutclean_es($element)` | `substring($element[@locale='es_ES'],...)` | `substring($element/fn:string[@key='es_ES'],...)` |

**Impacte als templates:** Tots els templates que criden `uab:clean_ca_en_es(X/text)` canvien a `uab:clean_ca_en_es(fn:map[@key='X'])`, passant el `fn:map` en lloc del node-set de `text`.

### awards_oc_recompte.xslt (ja convertit)

Template simple que extreu el `count` del JSON. Prova de concepte completada.

### awards-estat_oc.xslt

- Iteració plana sobre awards
- Camps: uuid, externalId, title, statusDetails (status key, value terms, dates, booleans)
- **Nota JSON:** `statusDetails` al JSON pot ser un objecte directe, no un wrapper
- XPaths `statusDetails/status/@key` → `fn:map[@key='statusDetails']/fn:map[@key='status']/fn:string[@key='key']`
- XPaths `statusDetails/status/value/text` → `fn:map[@key='statusDetails']/fn:map[@key='status']/fn:map[@key='value']` (per locale)

### awards-holders_oc.xslt

- Iteració niuada: award → awardholders
- **Canvi de nom:** `awardholders/awardholder` → `fn:array[@key='awardHolders']/fn:map`
- **Canvi de nom:** `personRole` → `role`
- `person/@uuid` → `fn:map[@key='person']/fn:string[@key='uuid']`
- `externalPerson/@uuid` → `fn:map[@key='externalPerson']/fn:string[@key='uuid']`
- `name/firstName` → `fn:map[@key='name']/fn:string[@key='firstName']`

### awards-ids_oc.xslt

- Iteració niuada: award → ids
- **Canvi de nom:** `ids/id` → `fn:array[@key='identifiers']/fn:map`
- `id/@pureId` → `fn:number[@key='pureId']`
- `id/value` → `fn:string[@key='value']` o `fn:string[@key='id']` (depèn del typeDiscriminator)
- `id/type/@pureId` → `fn:map[@key='type']/fn:number[@key='pureId']`

### awards-comanagers_oc.xslt

- Iteració niuada: award → coManagingOrganisationalUnits
- `coManagingOrganisationalUnits/coManagingOrganisationalUnit` → `fn:array[@key='coManagingOrganisationalUnits']/fn:map`
- Utilitza `uab:clean_ca()` (funció individual, no trio)

### Awards-natureTypes_oc.xslt

- Iteració niuada: award → natureTypes
- `natureTypes/natureType` → `fn:array[@key='natureTypes']/fn:map`
- `natureType/@pureId` → `fn:number[@key='pureId']`

### awards-relatedApplications_oc.xslt

- Iteració niuada: award → relatedApplications
- `relatedApplications/relatedApplication` → `fn:array[@key='relatedApplications']/fn:map`
- `relatedApplication/@uuid` → `fn:string[@key='uuid']`

### awards-fundings_oc.xslt

- Iteració niuada: award → fundings
- `fundings/funding` → `fn:array[@key='fundings']/fn:map`
- `funding/@pureId` → `fn:number[@key='pureId']`
- `funder/@uuid` → `fn:map[@key='funder']/fn:string[@key='uuid']`
- `fundingClassifications/fundingClassification/@uri` → pot no existir al JSON
- `visibility/@key` → `fn:map[@key='visibility']/fn:string[@key='key']`
- `awardedAmount` → `fn:map[@key='awardedAmount']/fn:string[@key='value']` (és objecte al JSON amb currency+value)
- `institutionalPart` → pot requerir navegació dins fundingCollaborators

### awards-collaborators_oc.xslt

- Iteració niuada: award → collaborators
- `xsl:choose` per `organisationalUnit` vs `externalOrganisation`
- **Canvi ortografia:** `externalOrganisation` → `externalOrganization` al JSON
- Al JSON, `organisationalUnit` no existeix dins collaborator — cal buscar tipus via `typeDiscriminator`

### awards-fundings-collaborators_oc.xslt

- Path profund: `fundings/funding/fundingCollaborators/fundingCollaborator`
- → `fn:array[@key='fundings']/fn:map/fn:array[@key='fundingCollaborators']/fn:map`
- `collaborator/@uuid` → `fn:map[@key='collaborator']/fn:string[@key='uuid']`

### awards-budgetAndExpenditures_oc.xslt

- Iteració amb parent axis: `../` per obtenir l'uuid de l'award
- `fundings` → `fn:array[@key='fundings']` (iterar sense element intermedi)
- `../../@pureId` → `../../fn:number[@key='pureId']`

### awards-estat_old_oc.xslt

- Filtratge per `keywordGroup[@logicalName='...']`
- → `fn:array[@key='keywordGroups']/fn:map[fn:string[@key='logicalName']='...']`
- `structuredKeyword/@pureId` → camp dins objecte structuredKeyword

### awards-accounts_oc.xslt

- 4 nivells de niuament: fundings → budgetAndExpenditure → accounts → yearlyBudgets
- Parent axis extensiu (`../../@pureId`, `../@uuid`)
- `classification/@pureId` → `fn:map[@key='classification']/fn:number[@key='pureId']`

### awards-budget-periodes_oc.xslt

- Triple niuament: award → keywordGroups → keywordContainers
- `freeKeyword[@locale='es_ES']/freeKeywords/freeKeyword[1]` — accés posicional amb locale
- → Al JSON: `fn:map[fn:string[@key='locale']='es_ES']/fn:array[@key='freeKeywords']/fn:string[1]`

### awards_rao.xslt

- Template gran amb molts camps
- `keywordGroups/keywordGroup[@logicalName='...']` múltiples predicats
- `statusDetails` complet amb tots els camps
- Lògica `xsl:choose` per justificació econòmica
- `workflow/@workflowStep` → `fn:map[@key='workflow']/fn:string[@key='step']`

### awards_rao2.xslt

- Quasi idèntic a rao, amb lògica diferent de justificació econòmica
- La justificació comprova `structuredKeyword[@uri='...']` dins keywordGroups

---

## Preocupacions i supòsits

### 1. Cobertura del JSON de mostra

El fitxer `awards_test.json` només conté **1 item** amb un subconjunt de camps. No tots els camps referenciats pels templates hi són presents:

**Camps presents al JSON de mostra:**
- uuid, pureId, createdBy, createdDate, modifiedBy, modifiedDate, version
- awardHolders (amb name, role, person)
- awardDate, collaborators, descriptions
- actualPeriod, expectedPeriod
- identifiers (amb typeDiscriminator, pureId, idSource, value, type)
- fundings (amb funder, fundingProjectScheme, visibility, awardedAmount, fundingCollaborators)
- title, type, workflow, visibility, systemName

**Camps NO presents al JSON de mostra (però referenciats als templates):**
- `managingOrganisationalUnit` (usat a rao, rao2)
- `coManagingOrganisationalUnits` (usat a comanagers)
- `natureTypes` (usat a natureTypes)
- `keywordGroups` (usat a rao, rao2, estat_old, budget-periodes)
- `statusDetails` (usat a rao, rao2, estat)
- `totalAwardedAmount`, `totalSpendAmount` (usat a rao, rao2)
- `relatedApplications` (usat a relatedApplications)
- `budgetAndExpenditures` dins fundings (usat a accounts, budgetAndExpenditures)
- `collaborative` (usat a rao, rao2)
- `externalPerson` dins awardHolders (usat a holders)

**Impacte:** Els templates produiran valors buits per camps absents, que és el comportament correcte (igual que els templates XML originals quan un camp no existeix). L'estructura XPath és correcta basant-se en l'especificació `json-to-xml()` i l'estructura XML observada.

### 2. Supòsit sobre l'estructura JSON de l'API

L'estructura JSON s'ha deduït de:
- El fitxer `awards_test.json` proporcionat
- L'estructura XML de `awards.xml` (les APIs REST Pure solen mantenir la mateixa estructura semàntica)
- La documentació de `json-to-xml()` del W3C

**Supòsit principal:** Les propietats JSON segueixen les convencions observades (camelCase, arrays per col·leccions, objectes per entitats). Si l'API retorna una estructura diferent per a camps no presents al JSON de mostra, caldrà ajustar els XPaths.

### 3. Camps numèrics vs string

Al JSON, `pureId` sol ser numèric (`"pureId": 45755718`) → `fn:number`. Però `uuid` és string. Cal verificar que no hi ha inconsistències on un camp sigui string en alguns registres i numèric en altres.

### 4. Estructura de `keywordGroups` al JSON

Els templates originals naveguen `keywordGroups/keywordGroup[@logicalName='X']/keywordContainers/keywordContainer/...`. Al JSON, l'estructura probable és:
```json
{
  "keywordGroups": [
    {
      "logicalName": "/uab/awards/a_carrec",
      "keywordContainers": [
        {
          "structuredKeyword": {
            "pureId": 123,
            "uri": "/uab/awards/a_carrec/...",
            "term": {"ca_ES": "...", "en_GB": "...", "es_ES": "..."}
          },
          "freeKeywords": [
            {
              "locale": "ca_ES",
              "freeKeywords": ["valor1", "valor2"]
            }
          ]
        }
      ]
    }
  ]
}
```

Això es confirma parcialment amb l'estructura XML del fitxer `awards.xml` que mostra keywordGroups amb `@logicalName`, keywordContainers, structuredKeyword i freeKeywords.

### 5. Diferències d'ortografia i noms

- XML `externalOrganisation` → JSON `externalOrganization` (British→American spelling)
- XML `personRole` → JSON `role`
- XML `ids/id` → JSON `identifiers`
- XML `workflow/@workflowStep` → JSON `workflow.step`

Aquests canvis s'han aplicat basant-se en el JSON de mostra i les convencions estàndard de l'API Pure.

### 6. El camp `value` dins `id` vs `identifiers`

Al XML, el camp és `id/value` (text simple). Al JSON, per als `ClassifiedId`, el camp és `id` (no `value`). Per als `PrimaryId` i `Id`, el camp és `value`. Cal gestionar ambdós:
- `fn:string[@key='value']` per a PrimaryId/Id
- `fn:string[@key='id']` per a ClassifiedId

La solució: utilitzar `(fn:string[@key='value'] | fn:string[@key='id'])` o gestionar amb `xsl:choose`.

### 7. El camp `awardedAmount` al JSON

Al XML és text pla (`<awardedAmount>70566.00</awardedAmount>`). Al JSON és objecte (`{"currency":"EUR","value":"5000"}`). Cal navegar `fn:map[@key='awardedAmount']/fn:string[@key='value']`.

### 8. El camp `institutionalPart` al JSON

Similar a `awardedAmount`, al JSON pot ser objecte (`{"currency":"EUR","value":"5000"}`) → `fn:map[@key='institutionalPart']/fn:string[@key='value']`.

### 9. Integració ODI

- Cap canvi específic per ODI als templates XSLT
- La invocació canvia: el paràmetre `json-file` substitueix la font XML
- S'ha de mantenir `dummy.xml` accessible
- El fitxer JSON s'ha de descarregar prèviament (pas anterior a l'ODI package)

---

## Fitxers creats

| Fitxer | Descripció | Estat |
|---|---|---|
| `json/dummy.xml` | XML mínim per Saxon | Creat |
| `json/awards_test.json` | JSON de mostra | Creat |
| `json/functions.xslt` | Funcions v3.0 per JSON | Reescrit |
| `json/awards_oc_recompte.xslt` | Recompte (prova de concepte) | Convertit |
| `json/awards-estat_oc.xslt` | Estat dels awards | Convertit |
| `json/awards-holders_oc.xslt` | Holders (membres equip) | Convertit |
| `json/awards-ids_oc.xslt` | Identificadors | Convertit |
| `json/awards-comanagers_oc.xslt` | Co-managers | Convertit |
| `json/Awards-natureTypes_oc.xslt` | Tipus de naturalesa | Convertit |
| `json/awards-relatedApplications_oc.xslt` | Sol·licituds relacionades | Convertit |
| `json/awards-fundings_oc.xslt` | Finançaments | Convertit |
| `json/awards-collaborators_oc.xslt` | Col·laboradors | Convertit |
| `json/awards-fundings-collaborators_oc.xslt` | Col·laboradors de finançament | Convertit |
| `json/awards-budgetAndExpenditures_oc.xslt` | Pressupostos i despeses | Convertit |
| `json/awards-estat_old_oc.xslt` | Estat antic (keywords) | Convertit |
| `json/awards-accounts_oc.xslt` | Comptes (4 nivells) | Convertit |
| `json/awards-budget-periodes_oc.xslt` | Períodes pressupostaris | Convertit |
| `json/awards_rao.xslt` | RAO principal | Convertit |
| `json/awards_rao2.xslt` | RAO2 (justificació corregida) | Convertit |
| `json/MIGRACIO_XML_A_JSON.md` | Documentació (aquest fitxer) | Creat |

---

## Com verificar

### Test bàsic amb el JSON de mostra

```bash
cd /home/guillem/Downloads/SAXON

# Recompte (prova de concepte)
java -jar saxon9he.jar -s:xslt/awards/ok/json/dummy.xml \
  -xsl:xslt/awards/ok/json/awards_oc_recompte.xslt \
  json-file=xslt/awards/ok/json/awards_test.json

# Qualsevol altre template
java -jar saxon9he.jar -s:xslt/awards/ok/json/dummy.xml \
  -xsl:xslt/awards/ok/json/awards-estat_oc.xslt \
  json-file=xslt/awards/ok/json/awards_test.json
```

### Validació de sortida

La sortida CSV ha de coincidir en estructura (mateixos noms de columnes, mateix ordre) amb la sortida dels templates XML originals. Els valors poden diferir si el JSON conté dades diferents o camps absents (valors buits).

---

## Historial de canvis

| Data | Canvi |
|---|---|
| 2026-03-31 | Creació inicial: dummy.xml, awards_test.json, functions.xslt (v3.0 bump), awards_oc_recompte.xslt |
| 2026-03-31 | Reescriptura functions.xslt per JSON (funcions locale) |
| 2026-03-31 | Conversió de tots els 15 templates restants a JSON |
| 2026-03-31 | Creació d'aquest document de migració |
| 2026-03-31 | Creació de `GUIA_EXECUCIO.md` amb comandes d'execució per a tots els 16 templates |
