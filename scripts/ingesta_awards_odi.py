# -*- coding: utf-8 -*-
# ============================================================================
#  INGESTA DE DADES D'AWARDS DES DE PURE API (JSON) CAP A ORACLE BCK
# ============================================================================
#
#  Autor:       Template generat per al TFG - UAB
#  Data:        2026-03
#  Compatibilitat: Jython 2.5.x (ODI 12c / 14c)
#  Llicencia:   Ús intern UAB - Oficina de Govern de les Dades
#
#  DESCRIPCIO GENERAL:
#    Aquest script s'executa com a pas Jython dins d'un procediment ODI.
#    Realitza la ingesta completa de l'endpoint /awards de la Pure API
#    (EGRETA) cap a les taules de staging (BCK) d'Oracle.
#
#  MODES DE FUNCIONAMENT:
#    MODE = 'JDBC'  -> Insereix directament a Oracle via JDBC PreparedStatement
#    MODE = 'CSV'   -> Genera fitxers CSV per a carrega posterior amb ODI LKM
#
#  ESTRUCTURA DE TAULES:
#    Taula pare:   BCK_PURE_AWARD            (1 fila per award)
#    Taula filla:  BCK_PURE_AWARD_HOLDER     (1:N titulars per award)
#    Taula filla:  BCK_PURE_AWARD_FUNDING    (1:N financaments per award)
#    Taula filla:  BCK_PURE_AWARD_IDENTIFIER (1:N identificadors per award)
#
#  COM ADAPTAR AQUEST TEMPLATE:
#    1. Modificar la SECCIO 1 (configuracio) amb els vostres parametres
#    2. Si les taules BCK tenen columnes diferents, modificar els diccionaris
#       AWARD_COLUMNS, HOLDER_COLUMNS, FUNDING_COLUMNS, IDENTIFIER_COLUMNS
#    3. Si canvieu d'endpoint (ex: /persons), modifiqueu les funcions
#       flatten_* de la SECCIO 3
#
#  REFERENCIES:
#    - Pure API: https://api.elsevierpure.com/ws/api/documentation/index.html
#    - EGRETA UAB: https://egreta.uab.cat/ws/api/api-docs/index.html
#    - ODI Procedures: https://docs.oracle.com/en/middleware/fusion-middleware/
#      data-integrator/12.2.1.4/odidg/working-procedures.html
#    - Guia completa: veure guia_ingesta_python_odi.md (seccio 5)
#
# ============================================================================


# ============================================================================
#  SECCIO 1 — CONFIGURACIO
# ============================================================================
#  Objectiu:
#    Centralitzar TOTS els parametres modificables en un sol lloc perque
#    l'usuari pugui adaptar el script sense tocar la logica.
#
#  Decisio de disseny:
#    Usem placeholders d'ODI (#GLOBAL.VAR_NAME) que l'agent substitueix
#    pel valor real ABANS d'executar el codi Jython.
#    - Per a strings:   '#GLOBAL.VAR'  (amb cometes simples FORA)
#    - Per a numerics:  #GLOBAL.VAR    (sense cometes)
#    Si executeu el script fora d'ODI (ex: testing local), substituiu
#    els placeholders pels valors reals.
#
#  Alternativa descartada:
#    Hardcodejar valors directament -> no portable entre entorns
#    (desenvolupament, preproducci, produccio).
# ============================================================================

# --- Connexio a Pure API ---
# URL base de l'endpoint Awards. Sense barra final.
# Referencia: context.md linia 409 (EGRETA)
PURE_API_URL = '#GLOBAL.PURE_API_URL'
# Exemple directe (descomentar per testing fora d'ODI):
# PURE_API_URL = 'https://egreta.uab.cat/ws/api/awards'

# API key proporcionada per l'administrador de Pure/EGRETA.
# S'envia com a header HTTP "api-key" (no com a query parameter).
# Referencia: documentacio Pure API - Security scheme "apiKey"
PURE_API_KEY = '#GLOBAL.PURE_API_KEY'
# Exemple directe (descomentar per testing fora d'ODI):
# PURE_API_KEY = 'la-teva-api-key-aqui'

# Nombre de registres per pagina. Maxim permes per Pure API: 1000.
# Amb 43.193 awards (context.md linia 363), son ~44 pagines.
PAGE_SIZE = 1000

# --- Mode de carrega ---
# 'JDBC' = inserir directament a Oracle via PreparedStatement
# 'CSV'  = generar fitxers CSV per a carrega posterior amb ODI LKM
MODE = 'JDBC'

# --- Connexio JDBC a Oracle (nomes per a MODE='JDBC') ---
# Format: jdbc:oracle:thin:@//host:port/service_name
BCK_JDBC_URL  = '#GLOBAL.BCK_JDBC_URL'
BCK_USER      = '#GLOBAL.BCK_USER'
BCK_PASSWORD  = '#GLOBAL.BCK_PASSWORD'
# Exemples directes (descomentar per testing fora d'ODI):
# BCK_JDBC_URL = 'jdbc:oracle:thin:@//dbhost:1521/BCKSERVICE'
# BCK_USER     = 'BCK_OWNER'
# BCK_PASSWORD = 'password'

# --- Ruta CSV (nomes per a MODE='CSV') ---
# Directori on es generaran els fitxers CSV.
# Ha de ser accessible per l'agent ODI.
CSV_OUTPUT_DIR = '/tmp/odi/awards'

# --- Noms de les taules de staging ---
# Canvieu-los per adaptar-los a les vostres taules existents.
TABLE_AWARD      = 'BCK_PURE_AWARD'
TABLE_HOLDER     = 'BCK_PURE_AWARD_HOLDER'
TABLE_FUNDING    = 'BCK_PURE_AWARD_FUNDING'
TABLE_IDENTIFIER = 'BCK_PURE_AWARD_IDENTIFIER'

# --- Control d'errors i rendiment ---
# Nombre maxim de reintents per peticio HTTP fallida
MAX_RETRIES = 3
# Temps base d'espera entre reintents (segons). Backoff exponencial: 2^n * base
RETRY_BASE_DELAY = 2
# Temps d'espera entre pagines (segons). Prevenir HTTP 429 (rate limiting).
DELAY_BETWEEN_PAGES = 0.5
# Timeout de connexio HTTP (mil·lisegons)
HTTP_CONNECT_TIMEOUT = 30000
# Timeout de lectura HTTP (mil·lisegons)
HTTP_READ_TIMEOUT = 60000
# Nombre maxim d'errors per pagina abans d'abortar l'execucio completa
MAX_PAGE_ERRORS = 5
# Truncar taules staging abans de carregar? (True per a full load)
TRUNCATE_BEFORE_LOAD = True

# ============================================================================
#  SECCIO 1b — MAPEIG DE COLUMNES
# ============================================================================
#  Objectiu:
#    Definir quins camps del JSON es mapegen a quines columnes d'Oracle.
#    Centralitzat aqui per facilitar l'adaptacio a taules existents.
#
#  Format:
#    Llista de tuples (NOM_COLUMNA_ORACLE, TIPUS_ORACLE)
#    L'ordre ha de coincidir amb l'ordre dels valors retornats
#    per les funcions flatten_* de la Seccio 3.
#
#  TIPUS_ORACLE:
#    'VARCHAR2' -> setString() / setNull(Types.VARCHAR)
#    'NUMBER'   -> setLong() o setDouble() / setNull(Types.NUMERIC)
#    'DATE'     -> setString() amb TO_DATE a l'SQL
#    'TIMESTAMP'-> setString() amb TO_TIMESTAMP a l'SQL
#
#  Per adaptar a les vostres taules:
#    1. Canvieu NOM_COLUMNA_ORACLE pel nom real de la vostra columna
#    2. Afegiu o traieu tuples segons els camps que necessiteu
#    3. Modifiqueu la funcio flatten_* corresponent per retornar
#       el mateix nombre de valors en el mateix ordre
# ============================================================================

AWARD_COLUMNS = [
    ('AWARD_UUID',           'VARCHAR2'),
    ('PURE_ID',              'NUMBER'),
    ('TYPE_DISCRIMINATOR',   'VARCHAR2'),
    ('VERSION_HASH',         'VARCHAR2'),
    ('ACRONYM',              'VARCHAR2'),
    ('AWARD_DATE',           'DATE'),
    ('TITLE_CA',             'VARCHAR2'),
    ('TITLE_ES',             'VARCHAR2'),
    ('TITLE_EN',             'VARCHAR2'),
    ('ACTUAL_START_DATE',    'DATE'),
    ('ACTUAL_END_DATE',      'DATE'),
    ('EXPECTED_START_DATE',  'DATE'),
    ('EXPECTED_END_DATE',    'DATE'),
    ('MANAGING_ORG_UUID',    'VARCHAR2'),
    ('MANAGING_ORG_NAME_CA', 'VARCHAR2'),
    ('AWARD_TYPE_URI',       'VARCHAR2'),
    ('WORKFLOW_STEP',        'VARCHAR2'),
    ('STATUS_TYPE',          'VARCHAR2'),
    ('STATUS_DATE',          'DATE'),
    ('STATUS_REASON',        'VARCHAR2'),
    ('CLUSTER_UUID',         'VARCHAR2'),
    ('PORTAL_URL',           'VARCHAR2'),
    ('CREATED_BY',           'VARCHAR2'),
    ('CREATED_DATE',         'TIMESTAMP'),
    ('MODIFIED_BY',          'VARCHAR2'),
    ('MODIFIED_DATE',        'TIMESTAMP'),
]

HOLDER_COLUMNS = [
    ('AWARD_UUID',              'VARCHAR2'),
    ('HOLDER_TYPE',             'VARCHAR2'),
    ('PERSON_UUID',             'VARCHAR2'),
    ('EXTERNAL_PERSON_UUID',    'VARCHAR2'),
    ('HOLDER_NAME_FIRST',       'VARCHAR2'),
    ('HOLDER_NAME_LAST',        'VARCHAR2'),
    ('ROLE_URI',                'VARCHAR2'),
    ('ACADEMIC_OWNERSHIP_PCT',  'NUMBER'),
    ('COMMITMENT_PCT',          'NUMBER'),
    ('PERIOD_START_DATE',       'DATE'),
    ('PERIOD_END_DATE',         'DATE'),
]

FUNDING_COLUMNS = [
    ('AWARD_UUID',              'VARCHAR2'),
    ('FUNDING_TYPE_DISC',       'VARCHAR2'),
    ('FUNDER_UUID',             'VARCHAR2'),
    ('FUNDER_SYSTEM_NAME',      'VARCHAR2'),
    ('INTERNAL_FUNDER_UUID',    'VARCHAR2'),
    ('COST_CODE',               'VARCHAR2'),
    ('FUNDING_PROJECT_SCHEME',  'VARCHAR2'),
    ('AWARDED_AMOUNT_CURRENCY', 'VARCHAR2'),
    ('AWARDED_AMOUNT_VALUE',    'NUMBER'),
    ('AWARDED_ORIG_CURRENCY',   'VARCHAR2'),
    ('AWARDED_ORIG_VALUE',      'NUMBER'),
]

IDENTIFIER_COLUMNS = [
    ('AWARD_UUID',           'VARCHAR2'),
    ('IDENTIFIER_TYPE_DISC', 'VARCHAR2'),
    ('IDENTIFIER_ID',        'VARCHAR2'),
    ('IDENTIFIER_TYPE_URI',  'VARCHAR2'),
    ('IDENTIFIER_TYPE_TERM', 'VARCHAR2'),
]


# ============================================================================
#  SECCIO 2 — IMPORTS I DETECCIO DEL PARSER JSON
# ============================================================================
#  Objectiu:
#    Importar les classes Java necessaries i detectar automaticament
#    quin parser JSON esta disponible al classpath de l'agent ODI.
#
#  Per que classes Java i no biblioteques Python?
#    ODI utilitza Jython 2.5.x, que implementa Python 2.5 sobre la JVM.
#    Aixo implica:
#      - El modul 'json' NO existeix (introduit a Python 2.6)
#      - 'requests' es CPython pur, no funciona a Jython
#      - 'urllib2' falla amb HTTPS a Jython 2.5
#      - 'cx_Oracle' es una extensio C, incompatible amb la JVM
#    En canvi, des de Jython podem importar QUALSEVOL classe Java
#    que estigui al classpath, com si fos un modul Python.
#
#  Sistema de 3 tiers (nivells) amb fallback automatic:
#    Tier 1: javax.json.* (JSR 353)
#      -> Disponible si l'agent ODI corre sobre WebLogic 12c
#      -> Es l'estandard Java EE, no requereix cap JAR addicional
#      -> API: Json.createReader(), JsonObject, JsonArray
#
#    Tier 2: org.json.* (JSON-java de stleary)
#      -> Disponible si s'ha afegit json-XXXXX.jar al classpath
#      -> On posar el JAR: <ODI_HOME>/oracledi/agent/drivers/
#      -> API: new JSONObject(string), getJSONArray(), optString()
#
#    Tier 3: eval() amb substitucions
#      -> SEMPRE disponible (no depent de cap JAR)
#      -> Converteix JSON a dict/list Python via eval()
#      -> Segur en aquest context: la Pure API es font de confianca
#      -> Limitacio: no gestiona unicode escapes (\uXXXX) en claus
#
#  El script detecta el tier a l'inici i usa la mateixa interficie
#  abstracta (funcions safe_*) per accedir als camps JSON.
# ============================================================================

# --- Imports Java: sempre disponibles a Jython ---

# java.net.URL: construir objectes URL per a peticions HTTP
# java.net.HttpURLConnection: obrir connexio HTTP/HTTPS, configurar
#   headers, timeouts, i llegir la resposta
from java.net import URL, HttpURLConnection

# java.io.BufferedReader: llegir la resposta HTTP linia a linia
#   de manera eficient (amb buffer intern)
# java.io.InputStreamReader: convertir el flux de bytes (InputStream)
#   a caracters, especificant encoding UTF-8
# java.io.StringReader: wrapper per passar un string a APIs que
#   esperen un Reader (necessari per javax.json)
from java.io import BufferedReader, InputStreamReader, StringReader
# java.io.FileWriter: escriure fitxers de text (per al mode CSV)
# java.io.BufferedWriter: buffer d'escriptura de 8KB que redueix
#   el nombre de crides al sistema operatiu (I/O syscalls)
from java.io import FileWriter, BufferedWriter, File

# java.lang.StringBuilder: concatenar strings de manera eficient O(n)
#   En lloc de += que es O(n^2) perque crea un nou string cada cop
# java.lang.System: obtenir timestamp (currentTimeMillis) per mesurar
#   el temps d'execucio
# java.lang.Thread: sleep() entre pagines per evitar rate limiting
from java.lang import StringBuilder, System, Thread

# java.sql.DriverManager: obtenir connexions JDBC a Oracle
# java.sql.Types: constants per a setNull() (VARCHAR, NUMERIC, etc.)
from java.sql import DriverManager, Types

# sys i traceback: per gestionar excepcions i mostrar stack traces
import sys
import traceback

# --- Deteccio del tier JSON ---
# Provem d'importar cada biblioteca de major a menor preferencia.
# La primera que funcioni defineix JSON_TIER.
JSON_TIER = 0

try:
    # Tier 1: javax.json (JSR 353) - disponible a WebLogic 12c
    from javax.json import Json
    from javax.json import JsonValue
    JSON_TIER = 1
except ImportError:
    try:
        # Tier 2: org.json (JSON-java) - requereix JAR al classpath
        from org.json import JSONObject as OrgJSONObject
        from org.json import JSONArray as OrgJSONArray
        JSON_TIER = 2
    except ImportError:
        # Tier 3: eval() fallback - sempre disponible
        JSON_TIER = 3


# ============================================================================
#  SECCIO 3 — FUNCIONS AUXILIARS
# ============================================================================
#  Objectiu:
#    Encapsular cada responsabilitat en una funcio independent per
#    facilitar el manteniment, testing i adaptacio del codi.
#
#  Organitzacio:
#    3.1  log()                    - Logging amb timestamp
#    3.2  fetch_page()             - Peticio HTTP GET amb retry
#    3.3  parse_json()             - Parsing JSON (dispatcher de tiers)
#    3.4  safe_str/int/date()      - Acces segur a camps JSON
#    3.5  extract_localized()      - Camps multilingue
#    3.6  extract_period()         - Rangs de dates
#    3.7  flatten_award()          - Aplanar award pare
#    3.8  flatten_award_holders()  - Generar files filles (holders)
#    3.9  flatten_award_fundings() - Generar files filles (fundings)
#    3.10 flatten_award_identifiers() - Generar files filles (identifiers)
#    3.11 build_insert_sql()       - Generar SQL INSERT parametritzat
#    3.12 insert_batch_jdbc()      - INSERT amb PreparedStatement + batch
#    3.13 write_csv()              - Escriure CSV RFC 4180
#    3.14 escape_csv_value()       - Escapar valors per a CSV
# ============================================================================

# --- 3.1 log(msg) ---
# Objectiu:
#   Escriure missatges amb timestamp al log de sessio d'ODI.
#   L'agent ODI captura la sortida estandard (stdout) del script Jython
#   i la mostra a l'Operator Navigator > Sessions > Task Log.
#
# Decisio de disseny:
#   Usem 'print' (statement a Jython 2.5, NO funcio).
#   El timestamp ISO facilita la correlacio amb altres logs.
#
# Parametre:
#   msg (str): missatge a escriure
#
# Retorn: cap
def log(msg):
    from java.text import SimpleDateFormat
    from java.util import Date
    sdf = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss")
    ts = sdf.format(Date())
    print "[%s] %s" % (ts, msg)


# --- 3.2 fetch_page(base_url, api_key, offset, size) ---
# Objectiu:
#   Fer una peticio HTTP GET a la Pure API amb parametres de paginacio
#   i retornar el cos de la resposta com a string JSON.
#
# Decisio de disseny:
#   - Usem java.net.URL.openConnection() -> HttpURLConnection
#     perque es 100% fiable per a HTTPS a Jython (a diferencia d'urllib2).
#   - Header "api-key": requerit per la Pure API (no com a query param).
#   - Header "Accept: application/json": assegurar format JSON.
#   - Llegim amb BufferedReader + StringBuilder (NO += que es O(n^2)).
#   - Retry amb backoff exponencial per a errors transitoris:
#     HTTP 429 (Too Many Requests), 500, 502, 503, 504.
#   - Timeout configurable per evitar bloqueig indefinit.
#
# Alternativa descartada: urllib2
#   -> Falla amb HTTPS a Jython 2.5 (SSLHandshakeException)
# Alternativa descartada: Apache HttpClient
#   -> No sempre al classpath, afegeix dependencia innecessaria
#
# Parametres:
#   base_url (str): URL de l'endpoint (ex: https://egreta.uab.cat/ws/api/awards)
#   api_key  (str): clau API per autenticacio
#   offset   (int): posicio inicial (0-indexed)
#   size     (int): nombre de registres per pagina (max 1000)
#
# Retorn:
#   str: cos de la resposta HTTP (JSON string)
#
# Excepcions:
#   Exception: si la peticio falla despres de tots els reintents
def fetch_page(base_url, api_key, offset, size):
    url_str = "%s?offset=%d&size=%d" % (base_url, offset, size)
    last_error = None

    for attempt in range(MAX_RETRIES + 1):
        conn = None
        reader = None
        try:
            url = URL(url_str)
            conn = url.openConnection()
            conn.setRequestMethod("GET")
            # Header d'autenticacio (obligatori per Pure API)
            conn.setRequestProperty("api-key", api_key)
            # Demanar resposta en JSON (no XML)
            conn.setRequestProperty("Accept", "application/json")
            # Timeouts per evitar bloqueig indefinit
            conn.setConnectTimeout(HTTP_CONNECT_TIMEOUT)
            conn.setReadTimeout(HTTP_READ_TIMEOUT)

            response_code = conn.getResponseCode()

            # --- Resposta correcta ---
            if response_code == 200:
                # Llegir resposta amb BufferedReader + StringBuilder
                # StringBuilder es O(n) vs += que es O(n^2) en memoria
                reader = BufferedReader(
                    InputStreamReader(conn.getInputStream(), "UTF-8")
                )
                sb = StringBuilder()
                line = reader.readLine()
                while line is not None:
                    sb.append(line)
                    line = reader.readLine()
                return sb.toString()

            # --- Errors retriables (transitoris) ---
            elif response_code in (429, 500, 502, 503, 504):
                wait_secs = RETRY_BASE_DELAY * (2 ** attempt)
                log("WARN: HTTP %d a offset=%d. Reintentant en %ds (intent %d/%d)"
                    % (response_code, offset, wait_secs, attempt + 1, MAX_RETRIES))
                last_error = "HTTP %d" % response_code
                Thread.sleep(int(wait_secs * 1000))
                continue

            # --- Errors definitius (no retriables) ---
            else:
                # Intentar llegir el cos de l'error per diagnosticar
                error_msg = ""
                try:
                    err_reader = BufferedReader(
                        InputStreamReader(conn.getErrorStream(), "UTF-8")
                    )
                    err_sb = StringBuilder()
                    err_line = err_reader.readLine()
                    while err_line is not None:
                        err_sb.append(err_line)
                        err_line = err_reader.readLine()
                    err_reader.close()
                    error_msg = err_sb.toString()
                except:
                    pass
                raise Exception(
                    "HTTP %d a offset=%d: %s" % (response_code, offset, error_msg)
                )

        except Exception, e:
            # Si es l'ultim intent, propagar l'excepcio
            if attempt >= MAX_RETRIES:
                raise Exception(
                    "Error despres de %d intents a offset=%d: %s"
                    % (MAX_RETRIES + 1, offset, str(e))
                )
            last_error = str(e)
            wait_secs = RETRY_BASE_DELAY * (2 ** attempt)
            log("WARN: Error a offset=%d: %s. Reintentant en %ds (intent %d/%d)"
                % (offset, str(e), wait_secs, attempt + 1, MAX_RETRIES))
            Thread.sleep(int(wait_secs * 1000))

        finally:
            # SEMPRE tancar el reader si s'ha obert
            if reader is not None:
                try:
                    reader.close()
                except:
                    pass
            # Desconnectar la connexio HTTP per alliberar recursos
            if conn is not None:
                try:
                    conn.disconnect()
                except:
                    pass

    # No hauria d'arribar aqui, pero per seguretat
    raise Exception("Error inesperat a fetch_page offset=%d" % offset)


# --- 3.3 parse_json(json_string) ---
# Objectiu:
#   Convertir un string JSON a una estructura navegable.
#   Actua com a dispatcher que crida el parser del tier detectat.
#
# Decisio de disseny:
#   El retorn depent del tier:
#     Tier 1: javax.json.JsonObject  (objecte Java immutable)
#     Tier 2: org.json.JSONObject    (objecte Java mutable)
#     Tier 3: dict Python            (via eval())
#   Les funcions safe_* (3.4) encapsulen les diferencies d'API
#   perque la resta del codi no hagi de saber quin tier s'usa.
#
# Parametre:
#   json_string (str): string JSON valid
#
# Retorn:
#   objecte navegable (el tipus depen del tier)
def parse_json(json_string):
    if JSON_TIER == 1:
        # javax.json: creem un JsonReader des d'un StringReader
        reader = Json.createReader(StringReader(json_string))
        obj = reader.readObject()
        reader.close()
        return obj
    elif JSON_TIER == 2:
        # org.json: el constructor parseja directament el string
        return OrgJSONObject(json_string)
    else:
        # Tier 3: eval() amb substitucions JSON -> Python
        # true/false/null son literals JSON que no existeixen a Python
        s = json_string
        s = s.replace('true', 'True')
        s = s.replace('false', 'False')
        s = s.replace('null', 'None')
        # Restringim builtins per seguretat minima
        # (eval no pot accedir a __import__, open, etc.)
        return eval(s, {"__builtins__": {}}, {})


# --- 3.4 Funcions d'acces segur a camps JSON ---
# Objectiu:
#   Accedir a camps que poden ser null, absents, o de tipus diferent
#   sense llançar excepcions. Cada tier te la seva implementacio.
#
# Decisio de disseny:
#   En lloc d'un if/elif/else a cada linia de flatten_award(),
#   encapsulem la logica en funcions que retornen un valor per defecte
#   si el camp no existeix o es null. Aixo fa el codi molt mes net.
#
# Per que es necessari?
#   El JSON de Pure te molts camps opcionals. Un award pot tenir
#   status o no, managingOrganization o no, etc. Sense acces segur,
#   el script fallaria amb KeyError/NullPointerException al primer
#   award que no tingui un camp esperat.

def safe_str(obj, key, default=""):
    """Retorna el valor string d'un camp, o default si no existeix/es null."""
    try:
        if JSON_TIER == 1:
            # javax.json: getString llança excepcion si no existeix
            if obj.containsKey(key) and not obj.isNull(key):
                return obj.getString(key)
            return default
        elif JSON_TIER == 2:
            # org.json: optString retorna default si no existeix
            return obj.optString(key, default)
        else:
            # dict Python: get() retorna default si no existeix
            val = obj.get(key, default)
            if val is None:
                return default
            return str(val)
    except:
        return default


def safe_int(obj, key, default=None):
    """Retorna el valor enter d'un camp, o default si no existeix/es null."""
    try:
        if JSON_TIER == 1:
            if obj.containsKey(key) and not obj.isNull(key):
                return obj.getJsonNumber(key).longValue()
            return default
        elif JSON_TIER == 2:
            if obj.has(key) and not obj.isNull(key):
                return obj.getLong(key)
            return default
        else:
            val = obj.get(key, default)
            if val is None:
                return default
            return int(val)
    except:
        return default


def safe_float(obj, key, default=None):
    """Retorna el valor decimal d'un camp, o default si no existeix/es null."""
    try:
        if JSON_TIER == 1:
            if obj.containsKey(key) and not obj.isNull(key):
                return obj.getJsonNumber(key).doubleValue()
            return default
        elif JSON_TIER == 2:
            if obj.has(key) and not obj.isNull(key):
                return obj.getDouble(key)
            return default
        else:
            val = obj.get(key, default)
            if val is None:
                return default
            return float(val)
    except:
        return default


def safe_obj(obj, key):
    """Retorna un sub-objecte JSON, o None si no existeix/es null."""
    try:
        if JSON_TIER == 1:
            if obj.containsKey(key) and not obj.isNull(key):
                return obj.getJsonObject(key)
            return None
        elif JSON_TIER == 2:
            if obj.has(key) and not obj.isNull(key):
                return obj.getJSONObject(key)
            return None
        else:
            val = obj.get(key, None)
            if val is None or not isinstance(val, dict):
                return None
            return val
    except:
        return None


def safe_arr(obj, key):
    """Retorna un array JSON, o llista buida si no existeix/es null."""
    try:
        if JSON_TIER == 1:
            if obj.containsKey(key) and not obj.isNull(key):
                return obj.getJsonArray(key)
            return None
        elif JSON_TIER == 2:
            if obj.has(key) and not obj.isNull(key):
                return obj.getJSONArray(key)
            return None
        else:
            val = obj.get(key, None)
            if val is None or not isinstance(val, list):
                return None
            return val
    except:
        return None


def arr_len(arr):
    """Retorna la longitud d'un array JSON (compatible amb tots els tiers)."""
    if arr is None:
        return 0
    if JSON_TIER == 1:
        return arr.size()
    elif JSON_TIER == 2:
        return arr.length()
    else:
        return len(arr)


def arr_get_obj(arr, index):
    """Retorna l'objecte a l'index donat d'un array JSON."""
    if JSON_TIER == 1:
        return arr.getJsonObject(index)
    elif JSON_TIER == 2:
        return arr.getJSONObject(index)
    else:
        return arr[index]


# --- 3.5 extract_localized(obj, field, locale) ---
# Objectiu:
#   Obtenir el text d'un camp multilingue de Pure.
#   Pure retorna els camps multilingue com a objecte amb claus de locale:
#     "title": {"ca_ES": "Ajut de recerca", "es_ES": "Ayuda...", "en_GB": "Research..."}
#
# Parametres:
#   obj    : objecte JSON (l'award)
#   field  : nom del camp (ex: "title")
#   locale : codi de locale (ex: "ca_ES")
#
# Retorn:
#   str: text en el locale demanat, o "" si no existeix
def extract_localized(obj, field, locale):
    sub = safe_obj(obj, field)
    if sub is None:
        return ""
    return safe_str(sub, locale, "")


# --- 3.6 extract_period(obj, field) ---
# Objectiu:
#   Extreure les dates d'inici i fi d'un objecte de tipus DateRange.
#   Pure retorna: "actualPeriod": {"startDate": "2023-01-01", "endDate": "2025-12-31"}
#
# Parametres:
#   obj   : objecte JSON (l'award)
#   field : nom del camp (ex: "actualPeriod")
#
# Retorn:
#   tuple (start_date_str, end_date_str) — cadascun pot ser "" si no existeix
def extract_period(obj, field):
    sub = safe_obj(obj, field)
    if sub is None:
        return ("", "")
    return (safe_str(sub, "startDate", ""), safe_str(sub, "endDate", ""))


# --- 3.7 flatten_award(award_obj) ---
# Objectiu:
#   Convertir un objecte JSON niat d'un award a una llista plana de
#   valors, en el mateix ordre que AWARD_COLUMNS.
#
# Decisio de disseny:
#   Apliquem aplanament (flattening) nomes per a:
#     - Relacions 1:1 (managingOrganization, workflow, status, cluster)
#     - Camps localitzats amb cardinalitat fixa (_CA, _ES, _EN)
#   Les relacions 1:N (holders, fundings, identifiers) van a funcions
#   separades que generen files per a les taules filles.
#
#   Per que taules filles i no columnes numerades (HOLDER_1_UUID, HOLDER_2_UUID)?
#     -> La cardinalitat es variable i desconeguda
#     -> Columnes numerades violen 1NF i compliquen les consultes SQL
#     -> Afegir un nou element requereix ALTER TABLE (canvi DDL)
#     -> Referencia: context.md linies 367-406 (estructura Awards)
#
# Parametre:
#   award_obj: objecte JSON d'un award individual
#
# Retorn:
#   list: valors en l'ordre d'AWARD_COLUMNS.
#         Cada valor es str, int, float o None.
def flatten_award(award_obj):
    # --- Camps simples ---
    uuid = safe_str(award_obj, "uuid", "")
    pure_id = safe_int(award_obj, "pureId")
    type_disc = safe_str(award_obj, "typeDiscriminator", "")
    version = safe_str(award_obj, "version", "")
    acronym = safe_str(award_obj, "acronym", "")
    award_date = safe_str(award_obj, "awardDate", "")

    # --- Camps localitzats (title) ---
    # Pure retorna: "title": {"ca_ES": "...", "es_ES": "...", "en_GB": "..."}
    title_ca = extract_localized(award_obj, "title", "ca_ES")
    title_es = extract_localized(award_obj, "title", "es_ES")
    title_en = extract_localized(award_obj, "title", "en_GB")

    # --- Periodes (objectes niats 1:1) ---
    actual_start, actual_end = extract_period(award_obj, "actualPeriod")
    expected_start, expected_end = extract_period(award_obj, "expectedPeriod")

    # --- Managing Organization (objecte niat 1:1) ---
    # Pure retorna: "managingOrganization": {"uuid": "...", "name": {"ca_ES": "..."}}
    managing_org = safe_obj(award_obj, "managingOrganization")
    managing_org_uuid = ""
    managing_org_name_ca = ""
    if managing_org is not None:
        managing_org_uuid = safe_str(managing_org, "uuid", "")
        managing_org_name_ca = extract_localized(managing_org, "name", "ca_ES")

    # --- Tipus d'award (classificacio) ---
    award_type = safe_obj(award_obj, "type")
    award_type_uri = ""
    if award_type is not None:
        award_type_uri = safe_str(award_type, "uri", "")

    # --- Workflow ---
    workflow = safe_obj(award_obj, "workflow")
    workflow_step = ""
    if workflow is not None:
        workflow_step = safe_str(workflow, "step", "")

    # --- Status (polimorfic: CurtailedAwardStatus, ExtendedAwardStatus, etc.) ---
    # Referencia: context.md linies 521-524
    status = safe_obj(award_obj, "status")
    status_type = ""
    status_date = ""
    status_reason = ""
    if status is not None:
        status_type = safe_str(status, "typeDiscriminator", "")
        status_date = safe_str(status, "date", "")
        status_reason = safe_str(status, "reason", "")

    # --- Cluster ---
    cluster = safe_obj(award_obj, "cluster")
    cluster_uuid = ""
    if cluster is not None:
        cluster_uuid = safe_str(cluster, "uuid", "")

    # --- Metadades de creacio/modificacio ---
    portal_url = safe_str(award_obj, "portalUrl", "")
    created_by = safe_str(award_obj, "createdBy", "")
    created_date = safe_str(award_obj, "createdDate", "")
    modified_by = safe_str(award_obj, "modifiedBy", "")
    modified_date = safe_str(award_obj, "modifiedDate", "")

    # Retornem en l'EXACTE ordre d'AWARD_COLUMNS
    return [
        uuid, pure_id, type_disc, version, acronym, award_date,
        title_ca, title_es, title_en,
        actual_start, actual_end, expected_start, expected_end,
        managing_org_uuid, managing_org_name_ca,
        award_type_uri, workflow_step,
        status_type, status_date, status_reason,
        cluster_uuid, portal_url,
        created_by, created_date, modified_by, modified_date,
    ]


# --- 3.8 flatten_award_holders(award_uuid, award_obj) ---
# Objectiu:
#   Extreure la llista d'awardHolders d'un award i generar una fila
#   per cada titular, amb la FK AWARD_UUID per fer el JOIN.
#
# Referencia: context.md linies 478-484
#   "awardHolders[] fa servir referencies en comptes de dades inline:
#    person: {systemName: Person, uuid: b85259e9-...}"
#
# Parametre:
#   award_uuid (str): UUID de l'award pare (FK)
#   award_obj: objecte JSON de l'award
#
# Retorn:
#   list of lists: una llista de valors per cada holder,
#                  en l'ordre de HOLDER_COLUMNS
def flatten_award_holders(award_uuid, award_obj):
    rows = []
    holders = safe_arr(award_obj, "awardHolders")
    if holders is None:
        return rows

    for i in range(arr_len(holders)):
        h = arr_get_obj(holders, i)
        holder_type = safe_str(h, "typeDiscriminator", "")

        # Person UUID: diferent camp segons si es intern o extern
        person_uuid = ""
        ext_person_uuid = ""
        person = safe_obj(h, "person")
        if person is not None:
            person_uuid = safe_str(person, "uuid", "")
        ext_person = safe_obj(h, "externalPerson")
        if ext_person is not None:
            ext_person_uuid = safe_str(ext_person, "uuid", "")

        # Nom del titular
        name_obj = safe_obj(h, "name")
        first_name = ""
        last_name = ""
        if name_obj is not None:
            first_name = safe_str(name_obj, "firstName", "")
            last_name = safe_str(name_obj, "lastName", "")

        # Rol
        role = safe_obj(h, "role")
        role_uri = ""
        if role is not None:
            role_uri = safe_str(role, "uri", "")

        # Percentatges
        academic_pct = safe_float(h, "academicOwnershipPercentage")
        commitment_pct = safe_float(h, "plannedResearcherCommitmentPercentage")

        # Periode
        period_start, period_end = extract_period(h, "period")

        rows.append([
            award_uuid, holder_type,
            person_uuid, ext_person_uuid,
            first_name, last_name,
            role_uri, academic_pct, commitment_pct,
            period_start, period_end,
        ])

    return rows


# --- 3.9 flatten_award_fundings(award_uuid, award_obj) ---
# Objectiu:
#   Extreure la llista de fundings d'un award.
#
# Referencia: context.md linies 500-505
#   "JSON inclou un bloc fundings[] detallat amb funder,
#    awardedAmount (EUR 5.000), fundingProjectScheme..."
#
# Parametre:
#   award_uuid (str): UUID de l'award pare (FK)
#   award_obj: objecte JSON de l'award
#
# Retorn:
#   list of lists: una llista de valors per cada funding,
#                  en l'ordre de FUNDING_COLUMNS
def flatten_award_fundings(award_uuid, award_obj):
    rows = []
    fundings = safe_arr(award_obj, "fundings")
    if fundings is None:
        return rows

    for i in range(arr_len(fundings)):
        f = arr_get_obj(fundings, i)
        funding_type = safe_str(f, "typeDiscriminator", "")

        # Funder extern
        funder = safe_obj(f, "funder")
        funder_uuid = ""
        funder_sys = ""
        if funder is not None:
            funder_uuid = safe_str(funder, "uuid", "")
            funder_sys = safe_str(funder, "systemName", "")

        # Funder intern
        int_funder = safe_obj(f, "internalFunder")
        int_funder_uuid = ""
        if int_funder is not None:
            int_funder_uuid = safe_str(int_funder, "uuid", "")

        cost_code = safe_str(f, "costCode", "")
        scheme = safe_str(f, "fundingProjectScheme", "")

        # Import concedit (en moneda del sistema)
        amount = safe_obj(f, "awardedAmount")
        amount_currency = ""
        amount_value = None
        if amount is not None:
            amount_currency = safe_str(amount, "currency", "")
            amount_value = safe_float(amount, "value")

        # Import concedit (en moneda original)
        orig_amount = safe_obj(f, "awardedAmountInAwardedCurrency")
        orig_currency = ""
        orig_value = None
        if orig_amount is not None:
            orig_currency = safe_str(orig_amount, "currency", "")
            orig_value = safe_float(orig_amount, "value")

        rows.append([
            award_uuid, funding_type,
            funder_uuid, funder_sys, int_funder_uuid,
            cost_code, scheme,
            amount_currency, amount_value,
            orig_currency, orig_value,
        ])

    return rows


# --- 3.10 flatten_award_identifiers(award_uuid, award_obj) ---
# Objectiu:
#   Extreure la llista d'identificadors d'un award.
#   Inclou l'ID FENIX, pureId classificat, i altres IDs externs.
#
# Referencia: context.md linies 452-458
#   "JSON els distribueix dins identifiers[]:
#    {typeDiscriminator: ClassifiedId, pureId: 45755723, id: AJU_30193}"
#
# Parametre:
#   award_uuid (str): UUID de l'award pare (FK)
#   award_obj: objecte JSON de l'award
#
# Retorn:
#   list of lists: una llista de valors per cada identifier,
#                  en l'ordre de IDENTIFIER_COLUMNS
def flatten_award_identifiers(award_uuid, award_obj):
    rows = []
    identifiers = safe_arr(award_obj, "identifiers")
    if identifiers is None:
        return rows

    for i in range(arr_len(identifiers)):
        ident = arr_get_obj(identifiers, i)
        type_disc = safe_str(ident, "typeDiscriminator", "")
        id_value = safe_str(ident, "id", "")

        # Tipus d'identificador (ex: "ID FENIX", "Scopus")
        id_type = safe_obj(ident, "type")
        type_uri = ""
        type_term = ""
        if id_type is not None:
            type_uri = safe_str(id_type, "uri", "")
            # El term es multilingue; agafem angles per defecte
            type_term = extract_localized(id_type, "term", "en_GB")
            if not type_term:
                type_term = extract_localized(id_type, "term", "ca_ES")

        rows.append([
            award_uuid, type_disc, id_value, type_uri, type_term,
        ])

    return rows


# --- 3.11 build_insert_sql(table_name, columns) ---
# Objectiu:
#   Generar un SQL INSERT parametritzat (amb ?) per a PreparedStatement.
#   Per a columnes de tipus DATE, embolquem el ? amb TO_DATE().
#   Per a TIMESTAMP, amb TO_TIMESTAMP().
#
# Decisio de disseny:
#   Usem PreparedStatement (no Statement amb SQL concatenat) per:
#     1. Evitar SQL injection (valors parametritzats)
#     2. Oracle pot reutilitzar el pla d'execucio (millor rendiment)
#     3. Gestio automatica de tipus NULL
#
# Parametre:
#   table_name (str): nom de la taula Oracle
#   columns (list of tuples): [(NOM, TIPUS), ...]
#
# Retorn:
#   str: SQL INSERT amb placeholders ?
def build_insert_sql(table_name, columns):
    col_names = []
    placeholders = []
    for col_name, col_type in columns:
        col_names.append(col_name)
        if col_type == 'DATE':
            # TO_DATE amb format ISO: 'YYYY-MM-DD'
            placeholders.append("TO_DATE(?, 'YYYY-MM-DD')")
        elif col_type == 'TIMESTAMP':
            # TO_TIMESTAMP amb format ISO: 'YYYY-MM-DD"T"HH24:MI:SS'
            # Nota: el format pot variar segons el JSON de Pure
            placeholders.append("TO_TIMESTAMP(?, 'YYYY-MM-DD\"T\"HH24:MI:SS')")
        else:
            placeholders.append("?")

    sql = "INSERT INTO %s (%s) VALUES (%s)" % (
        table_name,
        ", ".join(col_names),
        ", ".join(placeholders),
    )
    return sql


# --- 3.12 insert_batch_jdbc(conn, table_name, columns, rows) ---
# Objectiu:
#   Inserir un conjunt de files a Oracle via JDBC PreparedStatement
#   amb executeBatch per rendiment.
#
# Decisio de disseny:
#   - PreparedStatement amb addBatch()/executeBatch():
#     Redueix round-trips de xarxa: 1 crida per N files vs N crides.
#   - setNull() amb el tipus JDBC correcte per a valors None.
#   - No fem commit aqui (el fa el bucle principal per pagina).
#
# Per que JDBC i no cx_Oracle?
#   Jython corre sobre la JVM. cx_Oracle es una extensio C compilada
#   per a CPython, incompatible amb Jython. java.sql.* es natiu.
#
# Parametres:
#   conn       : connexio JDBC (java.sql.Connection)
#   table_name : nom de la taula Oracle
#   columns    : llista de tuples [(NOM, TIPUS), ...]
#   rows       : llista de llistes de valors
#
# Retorn:
#   int: nombre de files inserides
def insert_batch_jdbc(conn, table_name, columns, rows):
    if not rows:
        return 0

    sql = build_insert_sql(table_name, columns)
    pstmt = None
    count = 0

    try:
        pstmt = conn.prepareStatement(sql)

        for row in rows:
            param_idx = 1  # JDBC PreparedStatement es 1-indexed
            for i in range(len(columns)):
                col_name, col_type = columns[i]
                val = row[i]

                if val is None or val == "":
                    # Null: usem setNull amb el tipus JDBC corresponent
                    if col_type == 'NUMBER':
                        pstmt.setNull(param_idx, Types.NUMERIC)
                    elif col_type in ('DATE', 'TIMESTAMP'):
                        # Per a DATE/TIMESTAMP amb TO_DATE(?), el ? es un string
                        pstmt.setNull(param_idx, Types.VARCHAR)
                    else:
                        pstmt.setNull(param_idx, Types.VARCHAR)
                elif col_type == 'NUMBER':
                    if isinstance(val, float):
                        pstmt.setDouble(param_idx, val)
                    else:
                        pstmt.setLong(param_idx, long(val))
                else:
                    # VARCHAR2, DATE (com a string per TO_DATE), TIMESTAMP
                    pstmt.setString(param_idx, str(val))

                param_idx += 1

            pstmt.addBatch()
            count += 1

        pstmt.executeBatch()

    finally:
        if pstmt is not None:
            try:
                pstmt.close()
            except:
                pass

    return count


# --- 3.13 escape_csv_value(val) ---
# Objectiu:
#   Escapar un valor per a CSV seguint RFC 4180:
#   - Si conte comes, cometes dobles, o salts de linia: embolcallar amb "..."
#   - Les cometes dobles internes es dupliquen: " -> ""
#
# Parametre:
#   val: qualsevol valor (str, int, float, None)
#
# Retorn:
#   str: valor escapat per a CSV
def escape_csv_value(val):
    if val is None:
        return ""
    s = str(val)
    # Si conte caracters especials, embolcallar amb cometes
    if ',' in s or '"' in s or '\n' in s or '\r' in s:
        s = '"' + s.replace('"', '""') + '"'
    return s


# --- 3.14 write_csv(filepath, columns, rows, append) ---
# Objectiu:
#   Escriure files a un fitxer CSV amb capçalera.
#
# Decisio de disseny:
#   Usem java.io.BufferedWriter (no Python open()) per:
#     - Mes fiable per a encoding UTF-8 a Jython 2.5
#     - Buffer de 8KB redueix crides I/O al sistema operatiu
#     - Control explicit del flush
#
# Parametres:
#   filepath (str): ruta del fitxer CSV
#   columns (list of tuples): [(NOM, TIPUS), ...] - per a la capcalera
#   rows (list of lists): files de dades
#   append (bool): True per afegir al final, False per sobreescriure
#
# Retorn:
#   int: nombre de files escrites
def write_csv(filepath, columns, rows, append):
    if not rows and not append:
        # Si no hi ha files i no estem afegint, nomes escriure capcalera
        pass
    elif not rows:
        return 0

    writer = None
    try:
        writer = BufferedWriter(FileWriter(filepath, append))

        # Escriure capcalera nomes si no estem afegint (primera crida)
        if not append:
            header = ",".join([col[0] for col in columns])
            writer.write(header)
            writer.newLine()

        count = 0
        for row in rows:
            line = ",".join([escape_csv_value(v) for v in row])
            writer.write(line)
            writer.newLine()
            count += 1

        writer.flush()
        return count

    finally:
        if writer is not None:
            try:
                writer.close()
            except:
                pass


# ============================================================================
#  SECCIO 4 — EXECUCIO PRINCIPAL
# ============================================================================
#  Objectiu:
#    Orquestrar tot el proces d'ingesta de principi a fi.
#
#  Flux:
#    1. Log inici + tier JSON detectat
#    2. Inicialitzar connexio (JDBC) o crear directoris (CSV)
#    3. Opcionalment truncar taules staging (full load)
#    4. Fetch pagina 0 -> obtenir count total
#    5. Bucle de paginacio:
#       per cada pagina (offset = 0, PAGE_SIZE, 2*PAGE_SIZE, ...):
#         a. fetch_page(offset)
#         b. parse_json(resposta)
#         c. per cada award en items[]:
#            - flatten_award -> llista pare
#            - flatten_holders -> llista filles
#            - flatten_fundings -> llista filles
#            - flatten_identifiers -> llista filles
#         d. insert/write batch
#         e. log progres (X de Y processats)
#    6. Log resum (total, temps, errors)
#    7. Tancar recursos (finally block)
#
#  Decisio de disseny — Per que processar per pagina i no tot de cop?
#    - La Pure API retorna fins a 1000 registres per pagina
#    - Amb 43.193 awards, carregar-ho tot en memoria seria ~200MB+ de JSON
#    - Processar pagina a pagina mante el consum de memoria constant (~5MB)
#    - Si falla a la pagina 30, les pagines 0-29 ja estan commitejades
#
#  Gestio d'errors:
#    - try/except al nivell de pagina: log error, continuar amb la seguent
#    - try/finally al nivell global: SEMPRE tancar connexio/fitxers
#    - Comptador d'errors: si supera MAX_PAGE_ERRORS, abortar
# ============================================================================

def main():
    start_time = System.currentTimeMillis()

    # --- 4.1 Log inici ---
    log("=" * 60)
    log("INICI INGESTA AWARDS DES DE PURE API")
    log("=" * 60)
    log("Mode: %s" % MODE)
    log("URL: %s" % PURE_API_URL)
    log("Page size: %d" % PAGE_SIZE)

    tier_names = {1: "javax.json (JSR 353)", 2: "org.json (JSON-java)", 3: "eval() fallback"}
    log("JSON Parser Tier: %d - %s" % (JSON_TIER, tier_names.get(JSON_TIER, "desconegut")))

    if JSON_TIER == 3:
        log("AVIS: Usant eval() per parsing JSON. Funcional pero menys robust.")
        log("      Per millorar, afegiu json-XXXXX.jar a <ODI_HOME>/oracledi/agent/drivers/")

    # --- 4.2 Inicialitzar recursos ---
    conn = None
    total_awards = 0
    total_holders = 0
    total_fundings = 0
    total_identifiers = 0
    page_errors = 0

    try:
        if MODE == 'JDBC':
            log("Connectant a Oracle via JDBC: %s" % BCK_JDBC_URL)
            conn = DriverManager.getConnection(BCK_JDBC_URL, BCK_USER, BCK_PASSWORD)
            # Desactivar autocommit per controlar quan fem commit
            conn.setAutoCommit(False)
            log("Connexio JDBC establerta correctament")

            # --- 4.3 Truncar taules staging (opcional) ---
            if TRUNCATE_BEFORE_LOAD:
                log("Truncant taules staging (TRUNCATE_BEFORE_LOAD=True)...")
                stmt = conn.createStatement()
                for tbl in [TABLE_IDENTIFIER, TABLE_FUNDING, TABLE_HOLDER, TABLE_AWARD]:
                    try:
                        stmt.execute("TRUNCATE TABLE %s" % tbl)
                        log("  Truncat: %s" % tbl)
                    except Exception, e:
                        log("  WARN: No s'ha pogut truncar %s: %s" % (tbl, str(e)))
                stmt.close()
                # TRUNCATE fa commit implicit a Oracle, no cal commit explícit

        elif MODE == 'CSV':
            log("Mode CSV: fitxers es generaran a %s" % CSV_OUTPUT_DIR)
            # Crear directori si no existeix
            csv_dir = File(CSV_OUTPUT_DIR)
            if not csv_dir.exists():
                csv_dir.mkdirs()
                log("Directori creat: %s" % CSV_OUTPUT_DIR)

        # --- 4.4 Primera pagina: obtenir count total ---
        log("Fent primera peticio per obtenir el nombre total d'awards...")
        first_page_json = fetch_page(PURE_API_URL, PURE_API_KEY, 0, PAGE_SIZE)
        first_page = parse_json(first_page_json)
        total_count = safe_int(first_page, "count", 0)
        log("Total awards disponibles a l'API: %d" % total_count)

        if total_count == 0:
            log("AVIS: L'API retorna 0 awards. Verificar URL i API key.")
            return

        total_pages = (total_count + PAGE_SIZE - 1) / PAGE_SIZE  # arrodoniment amunt
        log("Total pagines a processar: %d (de %d registres cadascuna)" % (total_pages, PAGE_SIZE))

        # --- 4.5 Bucle de paginacio ---
        # Comencem des de 0 perque ja hem fet fetch de la primera pagina
        # pero la processem tambe dins del bucle per simplicitat
        # (la re-descarreguem, cost minim vs complexitat del codi)
        first_page_csv = True  # Per escriure capcalera CSV nomes un cop

        offset = 0
        while offset < total_count:
            page_num = (offset / PAGE_SIZE) + 1

            try:
                # --- Fetch pagina ---
                if offset == 0:
                    # Reutilitzem la primera pagina ja descarregada
                    page_json = first_page_json
                    page = first_page
                else:
                    page_json = fetch_page(PURE_API_URL, PURE_API_KEY, offset, PAGE_SIZE)
                    page = parse_json(page_json)

                # Alliberar referencia al JSON string (ajudar el GC)
                page_json = None

                # --- Extreure items ---
                items = safe_arr(page, "items")
                if items is None:
                    log("WARN: Pagina %d/%d sense items. Saltant." % (page_num, total_pages))
                    offset += PAGE_SIZE
                    continue

                items_count = arr_len(items)

                # Llistes per acumular files d'aquesta pagina
                award_rows = []
                holder_rows = []
                funding_rows = []
                identifier_rows = []

                # --- Processar cada award de la pagina ---
                for i in range(items_count):
                    try:
                        award = arr_get_obj(items, i)
                        award_uuid = safe_str(award, "uuid", "")

                        # Aplanar award pare
                        award_rows.append(flatten_award(award))

                        # Generar files filles
                        holder_rows.extend(flatten_award_holders(award_uuid, award))
                        funding_rows.extend(flatten_award_fundings(award_uuid, award))
                        identifier_rows.extend(flatten_award_identifiers(award_uuid, award))

                    except Exception, e:
                        log("WARN: Error processant award %d de pagina %d: %s"
                            % (i, page_num, str(e)))
                        # Continuem amb el seguent award (no abortem la pagina)

                # --- Insert/Write batch ---
                if MODE == 'JDBC':
                    # Inserir pare primer, despres filles (integritat referencial)
                    n_a = insert_batch_jdbc(conn, TABLE_AWARD, AWARD_COLUMNS, award_rows)
                    n_h = insert_batch_jdbc(conn, TABLE_HOLDER, HOLDER_COLUMNS, holder_rows)
                    n_f = insert_batch_jdbc(conn, TABLE_FUNDING, FUNDING_COLUMNS, funding_rows)
                    n_i = insert_batch_jdbc(conn, TABLE_IDENTIFIER, IDENTIFIER_COLUMNS, identifier_rows)
                    # Commit per pagina: si falla, nomes perdem la pagina actual
                    conn.commit()

                elif MODE == 'CSV':
                    append = not first_page_csv
                    n_a = write_csv(CSV_OUTPUT_DIR + "/awards.csv",
                                    AWARD_COLUMNS, award_rows, append)
                    n_h = write_csv(CSV_OUTPUT_DIR + "/award_holders.csv",
                                    HOLDER_COLUMNS, holder_rows, append)
                    n_f = write_csv(CSV_OUTPUT_DIR + "/award_fundings.csv",
                                    FUNDING_COLUMNS, funding_rows, append)
                    n_i = write_csv(CSV_OUTPUT_DIR + "/award_identifiers.csv",
                                    IDENTIFIER_COLUMNS, identifier_rows, append)
                    first_page_csv = False

                total_awards += len(award_rows)
                total_holders += len(holder_rows)
                total_fundings += len(funding_rows)
                total_identifiers += len(identifier_rows)

                log("Pagina %d/%d completada: %d awards, %d holders, %d fundings, %d identifiers"
                    % (page_num, total_pages, len(award_rows), len(holder_rows),
                       len(funding_rows), len(identifier_rows)))

            except Exception, e:
                page_errors += 1
                log("ERROR a pagina %d/%d (offset=%d): %s"
                    % (page_num, total_pages, offset, str(e)))
                log("Stack trace:")
                traceback.print_exc()

                if page_errors >= MAX_PAGE_ERRORS:
                    log("ABORTAT: S'ha superat el maxim d'errors per pagina (%d)"
                        % MAX_PAGE_ERRORS)
                    raise Exception(
                        "Massa errors de pagina: %d/%d" % (page_errors, MAX_PAGE_ERRORS)
                    )

                # Si estem en mode JDBC, fer rollback de la pagina fallida
                if MODE == 'JDBC' and conn is not None:
                    try:
                        conn.rollback()
                        log("Rollback de la pagina fallida completat")
                    except:
                        pass

            # --- Delay entre pagines per evitar rate limiting ---
            if DELAY_BETWEEN_PAGES > 0:
                Thread.sleep(int(DELAY_BETWEEN_PAGES * 1000))

            offset += PAGE_SIZE

        # --- 4.6 Resum final ---
        elapsed_ms = System.currentTimeMillis() - start_time
        elapsed_secs = elapsed_ms / 1000.0

        log("=" * 60)
        log("INGESTA COMPLETADA")
        log("=" * 60)
        log("Awards processats:      %d" % total_awards)
        log("Holders processats:     %d" % total_holders)
        log("Fundings processats:    %d" % total_fundings)
        log("Identifiers processats: %d" % total_identifiers)
        log("Errors de pagina:       %d" % page_errors)
        log("Temps total:            %.1f segons" % elapsed_secs)
        if elapsed_secs > 0:
            log("Velocitat:              %.0f awards/segon" % (total_awards / elapsed_secs))
        log("=" * 60)

        if total_awards != total_count and page_errors == 0:
            log("AVIS: S'esperaven %d awards pero se n'han processat %d"
                % (total_count, total_awards))

    # --- 4.7 Tancar recursos (SEMPRE, fins i tot si hi ha error) ---
    # Decisio de disseny:
    #   Usem try/finally (no 'with' statement que no existeix a Jython 2.5).
    #   Es CRITIC tancar la connexio JDBC per evitar fuites de connexio
    #   que poden esgotar el pool de connexions d'Oracle.
    finally:
        if conn is not None:
            try:
                conn.close()
                log("Connexio JDBC tancada correctament")
            except Exception, e:
                log("WARN: Error tancant connexio JDBC: %s" % str(e))

    log("Fi del script")


# ============================================================================
#  PUNT D'ENTRADA
# ============================================================================
#  A ODI, el codi Jython s'executa directament (no cal if __name__).
#  La funcio main() encapsula tota la logica per:
#    1. Facilitar el testing fora d'ODI
#    2. Permetre el try/finally global per tancar recursos
#    3. Mantenir l'espai de noms net (les variables locals de main()
#       no contaminen l'espai global de Jython)
# ============================================================================
main()
