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
		
		<xsl:text>eventUuid;PersonUuid;personRoleUuid;personRoleUri;personRoleText_ca;personRoleText_en;personRoleText_es</xsl:text>

		<xsl:value-of select="$newline" />

		<xsl:for-each select="$json-xml/fn:map/fn:array[@key='items']/fn:map">

			<!-- Guardem uuid de l'event -->
			<xsl:variable name="eventUuid" select="fn:string[@key='uuid']" />

			<!-- Recorrem les persones de les activitats (personAssociations o persons) -->
			<xsl:for-each select="fn:array[@key='personAssociations' or @key='persons']/fn:map">

				<!-- Identificador de l'activitat que hem guardat abans-->

				<xsl:value-of select="$eventUuid"/>
				<xsl:value-of select="$separator" />
				<xsl:choose>
					<xsl:when test="fn:map[@key='person']">
						<xsl:value-of select="fn:map[@key='person']/fn:string[@key='uuid']"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="fn:map[@key='externalPerson']/fn:string[@key='uuid']"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:value-of select="$separator" />
				
				<!-- Role o personRole -->
				<xsl:variable name="roleMap" select="fn:map[@key='personRole' or @key='role']"/>
				<xsl:value-of select="$roleMap/fn:number[@key='pureId']"/>
				<xsl:value-of select="$separator" />
				<xsl:value-of select="$roleMap/fn:string[@key='uri']"/>
				<xsl:value-of select="$separator" />
				<xsl:value-of select="uab:clean_ca_en_es($roleMap/fn:map[@key='term'])"/>
				<xsl:value-of select="$separator" />
				<xsl:value-of select="$newline" />
				
			</xsl:for-each>

		</xsl:for-each>

	</xsl:template> 
</xsl:stylesheet>
