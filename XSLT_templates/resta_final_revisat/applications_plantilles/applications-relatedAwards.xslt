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

		<xsl:text>uuid;relatedAward_uuid</xsl:text>
		<xsl:value-of select="$newline" />

		<xsl:for-each select="$json-xml/fn:map/fn:array[@key='items']/fn:map">
			<!-- Guardem uuid de l'application -->
			<xsl:variable name="uuid" select="fn:string[@key='uuid']" />

			<!-- Recorrem els relatedAwards -->
			<xsl:for-each select="fn:array[@key='relatedAwards']/fn:map">

				<!-- Identificador sol·licitud que hem guardat abans-->
				<xsl:value-of select="$uuid"/>
				<xsl:value-of select="$separator" />

				<!-- uuid de l'award -->
				<xsl:value-of select="fn:string[@key='uuid']"/>
				<xsl:value-of select="$separator"/>
				
				<xsl:value-of select="$newline" /> 								

			</xsl:for-each>

		</xsl:for-each> 
	</xsl:template>  
</xsl:stylesheet>
