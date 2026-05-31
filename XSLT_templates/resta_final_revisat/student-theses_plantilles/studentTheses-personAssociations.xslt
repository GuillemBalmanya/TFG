<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:uab="http://www.uab.cat"
    exclude-result-prefixes="xs fn uab">

	<xsl:include href="functions.xslt"/>

	<xsl:output method="text" />

	<xsl:param name="json-file" as="xs:string"/>

	<xsl:template name="xsl:initial-template">
		<xsl:variable name="json-text" select="unparsed-text($json-file)"/>
		<xsl:variable name="json-xml" select="json-to-xml($json-text)"/>
		
		<xsl:text>thesisUuid;PersonUuid;personRoleUuid;personRoleUri;personRoleText_ca;personRoleText_en;personRoleText_es</xsl:text>

		<xsl:value-of select="$newline" />

		<xsl:for-each select="$json-xml/fn:map/fn:array[@key='items']/fn:map">

			<!-- Guardem uuid de l'activitat -->
			<xsl:variable name="thesisUuid" select="fn:string[@key='uuid']" />

			<!-- Recorrem les persones de les activitats -->
			<xsl:for-each select="fn:array[@key='contributors']/fn:map">

				<!-- Identificador de l'activitat que hem guardat abans-->

				<xsl:value-of select="$thesisUuid"/>
				<xsl:value-of select="$separator" />
				<xsl:choose>
					<xsl:when test="fn:map[@key='person']">
						<xsl:value-of select="fn:map[@key='person']/fn:string[@key='uuid']"/>
					</xsl:when>
					<xsl:when test="fn:map[@key='personRef']">
						<xsl:value-of select="fn:map[@key='personRef']/fn:string[@key='uuid']"/>
					</xsl:when>
					<xsl:when test="fn:map[@key='externalPerson']">
						<xsl:value-of select="fn:map[@key='externalPerson']/fn:string[@key='uuid']"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="fn:map[@key='externalPersonRef']/fn:string[@key='uuid']"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:value-of select="$separator" />
				<xsl:value-of select="fn:map[@key='role']/fn:string[@key='pureId']"/>
				<xsl:value-of select="$separator" />
				<xsl:value-of select="fn:map[@key='role']/fn:string[@key='uri']"/>
				<xsl:value-of select="$separator" />
				<xsl:value-of select="uab:clean_ca_en_es(fn:map[@key='role']/fn:map[@key='term'])"/>
				<xsl:value-of select="$newline" />
				
			</xsl:for-each>

		</xsl:for-each>

	</xsl:template> 
</xsl:stylesheet>
