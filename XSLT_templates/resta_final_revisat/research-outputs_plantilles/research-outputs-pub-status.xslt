<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:uab="http://www.uab.cat"
	exclude-result-prefixes="fn uab xs">
	<xsl:include href="functions.xslt"/>
	<xsl:output method="text" />
	<xsl:param name="json-file" as="xs:string"/>
	<xsl:template match="/" name="xsl:initial-template">
		<xsl:variable name="json-text" select="unparsed-text($json-file)" />
		<xsl:variable name="json-xml" select="json-to-xml($json-text)" />
		<xsl:text>pubUuid;publicationStatusPureId;publicationStatusUri;publicationStatus_ca_ES;publicationStatus_en_GB;publicationStatus_es_ES;publicationDateYear;publicationDateMonth;publicationDateDay</xsl:text>
		<xsl:value-of select="$newline" />
		<xsl:for-each select="$json-xml/fn:map/fn:array[@key='items']/fn:map">
			<xsl:variable name="pubUuid" select="fn:string[@key='uuid']" />
			<xsl:for-each select="fn:array[@key='publicationStatuses']/fn:map">
				<xsl:value-of select="$pubUuid"/><xsl:value-of select="$separator" />
				<xsl:value-of select="fn:map[@key='publicationStatus']/fn:number[@key='pureId']"/><xsl:value-of select="$separator" />
				<xsl:value-of select="fn:map[@key='publicationStatus']/fn:string[@key='uri']"/><xsl:value-of select="$separator" />
				<xsl:value-of select="uab:clean_ca_en_es(fn:map[@key='publicationStatus']/fn:map[@key='term'])"/><xsl:value-of select="$separator" />
				<xsl:value-of select="fn:map[@key='publicationDate']/fn:number[@key='year']"/><xsl:value-of select="$separator" />
				<xsl:value-of select="fn:map[@key='publicationDate']/fn:number[@key='month']"/><xsl:value-of select="$separator" />
				<xsl:value-of select="fn:map[@key='publicationDate']/fn:number[@key='day']"/><xsl:value-of select="$newline" />
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template> 
</xsl:stylesheet>