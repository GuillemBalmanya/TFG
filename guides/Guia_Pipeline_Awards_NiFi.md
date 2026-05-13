# Guia d'Implementació: Pipeline ELT d'Awards a Apache NiFi (JSON natiu)

Aquesta arquitectura aprofita la capacitat nativa de NiFi per processar JSON i utilitza els "Record Processors" per aplicar les neteges de text i fer les insercions massives a Oracle de manera altament eficient, sense necessitat de Saxon ni de plantilles XSLT.

## Fase 1: Preparació de l'entorn Docker i Dependències

Atès que prescindim de Saxon, l'única dependència externa que NiFi necessita és el driver JDBC d'Oracle per poder connectar-se al Data Warehouse.

1.  **Crear carpeta de recursos:** S'ha creat la carpeta `/home/guillem/nifi-resources`.
2.  **Descarregar Driver Oracle:** S'ha descarregat `ojdbc8.jar` a la carpeta de recursos.
3.  **Recrear contenidor NiFi:** S'ha arrencat el contenidor mapejant el directori de recursos a `/opt/nifi/nifi-current/resources` i establint usuari (`admin`) i contrasenya (`SuperSecretPassword123!`).

---

## Fase 2: Extracció (Ingesta des de l'API Pure)

Dins del *canvas* de NiFi, cal crear un "Process Group" anomenat `Awards_Pipeline` i afegir els següents processadors:

### 1. `GenerateFlowFile`
Aquest processador actua com a disparador del procés.
*   **Scheduling Strategy:** `CRON driven`
*   **Run Schedule:** `0 0 2 * * ?` (Exemple: cada dia a les 2:00 AM).

### 2. `InvokeHTTP`
S'encarrega de fer la crida a l'endpoint de Pure i recollir el JSON.
*   **HTTP Method:** `GET`
*   **Remote URL:** L'URL del teu endpoint d'Awards de Pure.
*   **Basic Authentication Username / Password:** Les credencials d'accés a l'API.
*   *Enrutament:* Connectar la relació `Response` cap al següent processador.

---

## Fase 3: Transformació (Substitució de l'XSLT)

En aquesta fase s'aplana el JSON i s'apliquen les funcions de neteja (eliminació de salts de línia, substitució de caràcters, etc.) de manera nativa.

### Pas 3.1: Aplanar el JSON (Processador `JoltTransformJSON`)
Utilitzarem Jolt per convertir el JSON complex niat en un JSON pla que correspongui a les columnes de la base de dades.

*   **Jolt Transform DSL:** `Chain`
*   **Jolt Specification:**
```json
[
  {
    "operation": "shift",
    "spec": {
      "items": {
        "*": {
          "uuid": "[&1].uuid",
          "title": {
            "ca_ES": "[&1].text_ca_ES",
            "en_GB": "[&1].text_en_GB",
            "es_ES": "[&1].text_es_ES"
          },
          "type": {
            "pureId": "[&1].typePureId",
            "uri": "[&1].typeUri",
            "term": {
              "ca_ES": "[&1].type_term_text_ca_ES",
              "en_GB": "[&1].type_term_text_en_GB",
              "es_ES": "[&1].type_term_text_es_ES"
            }
          },
          "managingOrganization": {
            "uuid": "[&1].managingOrganisationalUnit_Uuid",
            "externalId": "[&1].managingOrganisationalUnit_ExternaId",
            "name": {
              "ca_ES": "[&1].MOU_name_text_ca_ES",
              "en_GB": "[&1].MOU_name_text_en_GB",
              "es_ES": "[&1].MOU_name_text_es_ES"
            }
          },
          "collaborative": "[&1].SN_collaborative",
          "totalAwardedAmount": "[&1].totalAwardedAmount",
          "totalSpendAmount": "[&1].totalSpendAmount",
          "actualPeriod": {
            "startDate": "[&1].actualPeriodStartDate",
            "endDate": "[&1].actualPeriodEndtDate"
          },
          "expectedPeriod": {
            "startDate": "[&1].expectedPeriodStartDate",
            "endDate": "[&1].expectedPeriodEndtDate"
          },
          "awardDate": "[&1].awardDate",
          "statusDetails": {
            "status": {
              "key": "[&1].estatId"
            },
            "internallyApprovedDate": "[&1].internallyApprovedDate",
            "relinquished": "[&1].relinquished",
            "relinquishmentDate": "[&1].relinquishmentDate",
            "relinquishmentReason": "[&1].relinquishmentReason",
            "declined": "[&1].declined",
            "declinationDate": "[&1].declinationDate",
            "declinedReason": "[&1].declinedReason"
          },
          "workflow": {
            "step": "[&1].workflow"
          },
          "pureId": "[&1].pureId"
          // NOTA: Els arrays de keywordGroups requeriran lògica avançada de Jolt o un ScriptedTransformRecord per extreure els valors a_carrec i justificacio_economica, tal com feia l'XSLT.
        }
      }
    }
  }
]
```

### Pas 3.2: Neteja de dades (Processador `UpdateRecord`)
Aquest processador aplica neteges de text equivalents a la funció `uab:clean` utilitzant *NiFi RecordPath Language*.

*   **Record Reader:** `JsonTreeReader` (S'ha de crear i activar aquest servei).
*   **Record Writer:** `JsonRecordSetWriter` (S'ha de crear i activar aquest servei).
*   **Replacement Value Strategy:** `Record Path Value`

**Regles dinàmiques (Propietats a afegir):**

| Nom de la Propietat | Valor (RecordPath Expression) |
| :--- | :--- |
| `/text_ca_ES` | `substring( replace( replaceRegex( /text_ca_ES, '[\r\n]', ''), ';', '-'), 0, 255)` |
| `/text_en_GB` | `substring( replace( replaceRegex( /text_en_GB, '[\r\n]', ''), ';', '-'), 0, 255)` |
| `/text_es_ES` | `substring( replace( replaceRegex( /text_es_ES, '[\r\n]', ''), ';', '-'), 0, 255)` |
| `/type_term_text_ca_ES` | `substring( replace( replaceRegex( /type_term_text_ca_ES, '[\r\n]', ''), ';', '-'), 0, 255)` |
| `/relinquishmentReason` | `replace( replaceRegex( /relinquishmentReason, '[\r\n]', ''), ';', '-')` |
| `/declinedReason` | `replace( replaceRegex( /declinedReason, '[\r\n]', ''), ';', '-')` |

*(Aquest patró s'ha de repetir per tots els camps de text descriptius que requerien neteja o retall a l'XSLT original).*

---

## Fase 4: Càrrega a Oracle (Load)

### 1. Configuració dels Serveis (Controller Services)
S'ha de crear a nivell de Process Group:
*   **DBCPConnectionPool:**
    *   *Database Connection URL:* `jdbc:oracle:thin:@//[HOST]:[PORT]/[SERVICE_NAME]`
    *   *Database Driver Class Name:* `oracle.jdbc.OracleDriver`
    *   *Database Driver Location(s):* `/opt/nifi/nifi-current/resources/ojdbc8.jar`
    *   *Database User / Password:* Credencials de l'usuari d'Oracle.

### 2. Processador `PutDatabaseRecord`
Insereix els registres JSON nets a Oracle.
*   **Record Reader:** `JsonTreeReader`
*   **Statement Type:** `UPSERT`
*   **Database Connection Pooling Service:** El `DBCPConnectionPool` acabat de crear.
*   **Table Name:** Nom de la taula d'Awards al teu Data Warehouse.
*   **Update Keys:** `uuid` (o la clau primària adient).
*   **Field Routing Strategy:** `Ignore Unmatched Fields`.

---

## Resum d'Arquitectura i Gestió d'Errors
1.  Les relacions `Failure` dels processadors s'han d'enrutar a un `LogMessage` o `PutFile` per traçar errors.
2.  L'ús de processament natiu JSON garanteix millor rendiment i manteniment que l'enfocament anterior amb Saxon i XML.
