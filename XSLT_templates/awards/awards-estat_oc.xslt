<!-- ATENCIÓ! AL MAIG DE 2021 CANVIEN L'ORIGEN A STATUS, JA NO DE KEYWORDS-->
<!-- Versió JSON: llegeix dades de fitxer JSON via json-to-xml() -->

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

		<xsl:text>uuid;externalId;text_ca_ES;text_en_GB;text_es_ES;estatId;estat_term_text_ca_ES;estat_term_text_en_GB;estat_term_text_es_ES;internallyApprovedDate;relinquished;relinquishmentDate;relinquishmentReason;declined;declinationDate;declinedReason</xsl:text>
		<xsl:value-of select="$newline" />

		<xsl:for-each select="$json-xml/fn:map/fn:array[@key='items']/fn:map">

			<!-- uuid i externalId de l'award -->
			<xsl:value-of select="fn:string[@key='uuid']"/>
			<xsl:value-of select="$separator"/>
			<xsl:value-of select="fn:string[@key='externalId']"/>
			<xsl:value-of select="$separator"/>
			<!-- Títol en ca, en, es -->
			<xsl:value-of select="uab:clean_ca_en_es(fn:map[@key='title'])"/>
			<xsl:value-of select="$separator"/>
			<!-- Estat -->
			<xsl:value-of select="fn:map[@key='statusDetails']/fn:map[@key='status']/fn:string[@key='key']"/>
			<xsl:value-of select="$separator"/>
			<xsl:value-of select="uab:clean_ca_en_es(fn:map[@key='statusDetails']/fn:map[@key='status']/fn:map[@key='value'])"/>
			<xsl:value-of select="$separator"/>
			<xsl:value-of select="fn:map[@key='statusDetails']/fn:string[@key='internallyApprovedDate']"/>
			<xsl:value-of select="$separator"/>
			<xsl:value-of select="fn:map[@key='statusDetails']/fn:boolean[@key='relinquished']"/>
			<xsl:value-of select="$separator"/>
			<xsl:value-of select="fn:map[@key='statusDetails']/fn:string[@key='relinquishmentDate']"/>
			<xsl:value-of select="$separator"/>
			<xsl:value-of select="fn:map[@key='statusDetails']/fn:string[@key='relinquishmentReason']"/>
			<xsl:value-of select="$separator"/>
			<xsl:value-of select="fn:map[@key='statusDetails']/fn:boolean[@key='declined']"/>
			<xsl:value-of select="$separator"/>
			<xsl:value-of select="fn:map[@key='statusDetails']/fn:string[@key='declinationDate']"/>
			<xsl:value-of select="$separator"/>
			<xsl:value-of select="fn:map[@key='statusDetails']/fn:string[@key='declinedReason']"/>
			<xsl:value-of select="$separator"/>
			<xsl:value-of select="$newline" />
		</xsl:for-each> 
	</xsl:template>  
</xsl:stylesheet>
