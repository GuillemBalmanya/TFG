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

		<xsl:text>uuid;funder_uuid;fundingClassification_uri;fundingProjectScheme;financial;appliedAmount;institutionalPart;visibility</xsl:text>
		<xsl:value-of select="$newline" />
		
		<xsl:for-each select="$json-xml/fn:map/fn:array[@key='items']/fn:map">
			<!-- Guardem uuid de l'application -->
			<xsl:variable name="uuid" select="fn:string[@key='uuid']" />

			<!-- Recorrem els fundings -->
			<xsl:for-each select="fn:array[@key='fundings']/fn:map">

				<!-- Identificador sol·licitud que hem guardat abans-->
				<xsl:value-of select="$uuid"/>
				<xsl:value-of select="$separator" />

				<!-- uuid del funder -->
				<xsl:value-of select="fn:map[@key='funder']/fn:string[@key='uuid']"/>
				<xsl:value-of select="$separator"/>

				<!-- ATENCIÓ: Funding classifications: no tots en tenen i els que he vist només en tenen un tot i el plural -->
				<xsl:value-of select="fn:array[@key='fundingClassifications']/fn:map[1]/fn:string[@key='uri']"/>
				<xsl:value-of select="$separator"/>
				
				<!-- fundingProjectScheme -->
				<xsl:value-of select="fn:*[@key='fundingProjectScheme']"/>
				<xsl:value-of select="$separator"/>
				
				<!-- financial -->
				<xsl:value-of select="fn:*[@key='financial']"/>
				<xsl:value-of select="$separator"/>
				
				<!-- appliedAmount -->
				<xsl:value-of select="fn:map[@key='appliedAmount']/fn:*[@key='value']"/>
				<xsl:value-of select="$separator"/>
				
				<!-- institutionalPart -->
				<xsl:value-of select="fn:*[@key='institutionalPart']"/>
				<xsl:value-of select="$separator"/>

				<!-- TODO: Budget & expenditures -->
				
				<!-- Visibility -->
				<xsl:value-of select="fn:map[@key='visibility']/fn:string[@key='key']"/>
				
				<xsl:value-of select="$newline" /> 								

			</xsl:for-each>

		</xsl:for-each> 
	</xsl:template>  
</xsl:stylesheet>
