# Instruccions de Migració de Plantilles XSLT (De XML a JSON API)

Aquest document detalla el procediment per adaptar les plantilles d'extracció XSLT 1.0 (que processaven fitxers XML) a XSLT 3.0 perquè puguin processar els fitxers JSON retornats per la nova API de Pure, aprofitant la funció estàndard `json-to-xml`.

## 1. Actualització de la Capçalera (Boilerplate)

S'ha de substituir la capçalera inicial (incloent-hi la definició d'espais de noms) per assegurar l'ús de XSLT 3.0 i l'espai de noms de funcions XPath (`fn`). 

**Abans (XSLT 1.0):**
```xml
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:uab="http://www.uab.cat">
    <xsl:include href="functions.xslt"/>
    <xsl:output method="text" />
    <xsl:template match="/">
        <!-- ... -->
```

**Després (XSLT 3.0):**
```xml
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:uab="http://www.uab.cat"
	exclude-result-prefixes="fn uab xs">

	<xsl:include href="functions.xslt" />
	<xsl:output method="text" />
	<xsl:param name="json-file" as="xs:string"/>

	<xsl:template match="/">
		<xsl:variable name="json-text" select="unparsed-text($json-file)" />
		<xsl:variable name="json-xml" select="json-to-xml($json-text)" />
        <!-- ... -->
```

## 2. Definició de les Estructures Iteratives (Bucles)

El JSON transformat a XML fa servir les etiquetes `<fn:map>` per a objectes JSON i `<fn:array>` per a llistes JSON.

**Bucle principal (Items):**
El directori base ja no és `result/items/...` sinó que buscarem dins de l'array `items` de l'arrel del JSON.

*Exemple per a una llista general:*
```xml
<!-- Abans -->
<xsl:for-each select="result/items/application">

<!-- Després -->
<xsl:for-each select="$json-xml/fn:map/fn:array[@key='items']/fn:map">
```

*Exemple amb filtratge per tipus (polimorfisme):*
```xml
<!-- Abans -->
<xsl:for-each select="result/items/consultancy">

<!-- Després -->
<xsl:for-each select="$json-xml/fn:map/fn:array[@key='items']/fn:map[fn:string[@key='typeDiscriminator']='Consultancy']">
```

**Bucles Interns (Arrays niuats):**
Quan es vol iterar sobre subllistes (com ara `persons`, `applicants`, `organisationalUnits`, `fundings`...):

```xml
<!-- Abans -->
<xsl:for-each select="applicants/applicant">

<!-- Després -->
<xsl:for-each select="fn:array[@key='applicants']/fn:map">
```
*(Nota: Llegeix el JSON atentament ja que alguns noms han canviat al passar de la vella estructura XML a la nova API JSON. Per exemple, `organisationalUnits` sol passar a dir-se `organizations`).*

## 3. Substitució de les Rutes d'Extracció (XPaths)

Els elements i atributs XML (ex. `@uuid` o `title/text`) es converteixen en strings, números, booleans, maps o arrays JSON. 

**Exemples de mapeig habituals:**

| Dada | XSLT 1.0 (XML) | XSLT 3.0 (JSON-to-XML) |
|---|---|---|
| **String simple / Identificador** | `@uuid` | `fn:string[@key='uuid']` |
| **String opcional** | `submissionDate` | `fn:string[@key='submissionDate']` |
| **Objectes Niuats (String)** | `fundingOpportunity/@uuid` | `fn:map[@key='fundingOpportunity']/fn:string[@key='uuid']` |
| **Objectes Niuats (Número)** | `type/@pureId` | `fn:map[@key='type']/fn:number[@key='pureId']` |
| **Booleans** | `financial` | `fn:boolean[@key='financial']` (o `fn:*` per suportar qualsevol tipus) |
| **Traduccions en Multi-Idioma** | `uab:clean_ca_en_es(title/text)` | `uab:clean_ca_en_es(fn:map[@key='title'])` |
| **Terminologia (Diccionari)** | `uab:clean_ca_en_es(type/term/text)` | `uab:clean_ca_en_es(fn:map[@key='type']/fn:map[@key='term'])` |
| **Quantitats amb Moneda** | `totalAppliedAmount` | `fn:map[@key='totalAppliedAmount']/fn:string[@key='value']` |
| **Filtre dins un array** | `status[@uri='...']/../date` | `fn:array[@key='statuses']/fn:map[fn:map[@key='status']/fn:string[@key='uri']='...']/fn:string[@key='date']` |
| **Primer element d'un array** | `descriptions/description[1]/value` | `fn:array[@key='descriptions']/fn:map[1]/fn:map[@key='value']` |

## 4. Consells Addicionals
1. **Atenció als canvis en el Model de Dades:** La nova API pot haver canviat lleugerament la denominació d'alguns camps (ex. `managingOrganisationalUnit` per `managingOrganization` o `personRole` per `role`). Verifica sempre el JSON d'exemple (`jq` i `grep` són de gran ajuda).
2. **Funcions externes (`functions.xslt`):** La funció de neteja d'idioma `clean_ca_en_es` acceptava elements de text però ara se li passa directament el diccionari/map (`fn:map`). Això funciona perquè la nova definició de la funció en XSLT 3.0 extreu correctament els valors en funció de la clau (`ca_ES`, `en_GB`, `es_ES`).
3. **Valors Opcionals:** L'ús de `fn:string[@key='...']` retorna nul (o un string buit en el join) si la clau no existeix al diccionari, sense petar l'execució. Si el tipus de camp és desconegut, pots fer servir el wildcard `fn:*[@key='...']`.
