<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:uab="http://www.uab.cat"
	exclude-result-prefixes="fn uab xs">
	<xsl:include href="functions.xslt"/>
	<xsl:output method="text" />
	<xsl:param name="json-file" as="xs:string"/>

	<xsl:template match="/">
		<xsl:variable name="json-text" select="unparsed-text($json-file)" />
		<xsl:variable name="json-xml" select="json-to-xml($json-text)" />
		<xsl:text>uuid;externalId;name_ca_ES;name_en_GB;name_es_ES;type_pureId;type_ca_ES;organisationid;fenix_code;nif;startDate;endDate;ambit_coneixPureId;ambit_coneix_term_text_ca_ES;ambit_coneix_term_text_en_GB;ambit_coneix_term_text_es_ES;pureId&#10;</xsl:text>
		
		<xsl:for-each select="$json-xml/fn:map/fn:array[@key='items']/fn:map">
			<xsl:value-of select="fn:string[@key='uuid']" />
			<xsl:value-of select="$separator" />
			
			<xsl:value-of select="fn:string[@key='externalId']" />
			<xsl:value-of select="$separator" />
			
			<xsl:value-of select="uab:clean_ca_en_es(fn:map[@key='name'])" />
			<xsl:value-of select="$separator" />
			
			<xsl:value-of select="fn:map[@key='type']/fn:number[@key='pureId']" />
			<xsl:value-of select="$separator" />
			
			<xsl:value-of select="uab:clean_ca(fn:map[@key='type']/fn:map[@key='term'])" />
			<xsl:value-of select="$separator" />
			
			<xsl:value-of select="fn:array[@key='identifiers']/fn:map[fn:map[@key='type']/fn:string[@key='uri']='/dk/atira/pure/organisation/organisationsources/organisationid']/fn:string[@key='id']" />
			<xsl:value-of select="$separator" />
			
			<xsl:value-of select="fn:array[@key='identifiers']/fn:map[fn:map[@key='type']/fn:string[@key='uri']='/dk/atira/pure/organisation/organisationsources/fenix_code']/fn:string[@key='id']" />
			<xsl:value-of select="$separator" />
			
			<xsl:value-of select="fn:array[@key='identifiers']/fn:map[fn:map[@key='type']/fn:string[@key='uri']='/dk/atira/pure/organisation/organisationsources/nif']/fn:string[@key='id']" />
			<xsl:value-of select="$separator" />
			
			<xsl:value-of select="fn:map[@key='lifecycle']/fn:string[@key='startDate']" />
			<xsl:value-of select="$separator" />
			
			<xsl:value-of select="fn:map[@key='lifecycle']/fn:string[@key='endDate']" />
			<xsl:value-of select="$separator" />
			
			<!--ambit (using uri as pureId is absent in classifications) -->
			<xsl:value-of select="fn:array[@key='keywordGroups']/fn:map[fn:string[@key='logicalName']='/uab/organisations/ambit_coneix']/fn:array[@key='classifications']/fn:map[1]/fn:string[@key='uri']" />
			<xsl:value-of select="$separator" />
			
			<xsl:value-of select="uab:clean_ca_en_es(fn:array[@key='keywordGroups']/fn:map[fn:string[@key='logicalName']='/uab/organisations/ambit_coneix']/fn:array[@key='classifications']/fn:map[1]/fn:map[@key='term'])" />
			<xsl:value-of select="$separator" />
			
			<xsl:value-of select="fn:number[@key='pureId']" />
			
			<xsl:value-of select="$newline" />
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
