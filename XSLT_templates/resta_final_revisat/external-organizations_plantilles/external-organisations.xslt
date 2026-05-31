<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:uab="http://www.uab.cat"
	exclude-result-prefixes="fn uab xs">
<xsl:include href="functions.xslt"/>
<xsl:output method="text"/>
<xsl:param name="json-file" as="xs:string"/>

<xsl:template match="/">
<xsl:variable name="json-text" select="unparsed-text($json-file)" />
<xsl:variable name="json-xml" select="json-to-xml($json-text)" />
<xsl:text>id;pureId;text_ca_ES;text_en_GB;text_es_ES;type_pureId;type_ca_ES;type_en_GB;type_es_ES;natureType_pureId;natureType_ca_ES;natureType_en_GB;natureType_es_ES;caracter_pureId;caracter_ca_ES;caracter_en_GB;caracter_es_ES;Address;Postal_code;city;country_pureId;country_ca_ES;country_en_GB;country_es_ES;ou_pureid;id_egreta_uo</xsl:text>
<xsl:value-of select="$newline"/>
<xsl:for-each select="$json-xml/fn:map/fn:array[@key='items']/fn:map">
<!-- identificador unic de l'entitat -->
<xsl:value-of select="fn:string[@key='uuid']"/>
<xsl:value-of select="$separator"/>
<!-- identificador unic de l'entitat -->
<xsl:value-of select="fn:number[@key='pureId']"/>
<xsl:value-of select="$separator"/>
<!-- nom de l'entitat en cat, ang i fr -->
<xsl:value-of select="uab:clean_ca_en_es(fn:map[@key='name'])"/>
<xsl:value-of select="$separator"/>
<!-- tipus de l'entitat -->
<xsl:value-of select="fn:map[@key='type']/fn:number[@key='pureId']"/>
<xsl:value-of select="$separator"/>
<!-- tipus de l'entitat en cat, ang i fr -->
<xsl:value-of select="uab:clean_ca_en_es(fn:map[@key='type']/fn:map[@key='term'])"/>
<xsl:value-of select="$separator"/>
<!-- naturalesa de l'entitat -->
<xsl:value-of select="fn:array[@key='natureTypes']/fn:map[1]/fn:number[@key='pureId']"/>
<xsl:value-of select="$separator"/>
<!-- naturalesa de l'entitat en cat, ang i fr -->
<xsl:value-of select="uab:clean_ca_en_es(fn:array[@key='natureTypes']/fn:map[1]/fn:map[@key='term'])"/>
<xsl:value-of select="$separator"/>
<!-- caracter de l'entitat -->
<xsl:value-of select="fn:array[@key='keywordGroups']/fn:map[fn:string[@key='logicalName']='/uab/externalorganisations/caracter']/fn:array[@key='classifications']/fn:map[1]/fn:string[@key='uri']"/>
<xsl:value-of select="$separator"/>
<!-- caracter de l'entitat en cat, ang i fr -->
<xsl:value-of select="uab:clean_ca_en_es(fn:array[@key='keywordGroups']/fn:map[fn:string[@key='logicalName']='/uab/externalorganisations/caracter']/fn:array[@key='classifications']/fn:map[1]/fn:map[@key='term'])"/>
<xsl:value-of select="$separator"/>
<!-- poblacio de l'entitat -->
<xsl:value-of select="fn:map[@key='address']/fn:string[@key='address1']"/>
<xsl:value-of select="$separator"/>
<!-- codi postal de l'entitat -->
<xsl:value-of select="fn:map[@key='address']/fn:string[@key='postalCode']"/>
<xsl:value-of select="$separator"/>
<!-- ciutat de l'entitat -->
<xsl:value-of select="fn:map[@key='address']/fn:string[@key='city']"/>
<xsl:value-of select="$separator"/>
<!-- codi pais de l'entitat -->
<xsl:value-of select="fn:map[@key='address']/fn:map[@key='country']/fn:number[@key='pureId']"/>
<xsl:value-of select="$separator"/>
<!-- pais de l'entitat en cat, ang i fr -->
<xsl:value-of select="uab:clean_ca_en_es(fn:map[@key='address']/fn:map[@key='country']/fn:map[@key='term'])"/>
<xsl:value-of select="$separator"/>
<!-- id_egreta_uo -->
<xsl:value-of select="fn:array[@key='identifiers']/fn:map[fn:map[@key='type']/fn:map[@key='term']/fn:string[@key='ca_ES']='ID EGRETA UO']/fn:number[@key='pureId']"/>
<xsl:value-of select="$separator"/>
<xsl:value-of select="$newline"/>
</xsl:for-each>
</xsl:template>
</xsl:stylesheet>
