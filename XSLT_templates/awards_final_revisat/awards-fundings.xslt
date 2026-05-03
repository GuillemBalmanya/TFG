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
<xsl:text>uuid;fundingPureId;fundingExternalId;funder_uuid;fundingClassification_uri;fundingProjectScheme;financial;awardedAmount;institutionalPart;visibility</xsl:text>
		<xsl:value-of select="$newline" />
		
				
		

		<xsl:for-each select="$json-xml/fn:map/fn:array[@key='items']/fn:map">
			<!-- Guardem uuid de l'application -->
			<xsl:variable name="awardUuid" select="fn:string[@key='uuid']" />

			<!-- Recorrem els fundings -->
			<xsl:for-each select="fn:array[@key='fundings']/fn:map">

				<!-- Identificador sol·licitud que hem guardat abans-->
				<xsl:value-of select="$awardUuid"/>
				<xsl:value-of select="$separator" />
				
				<!-- pureId i externalId del funding -->
				<xsl:value-of select="fn:number[@key='pureId']"/>
				<xsl:value-of select="$separator"/>
				<xsl:value-of select="fn:string[@key='externalId']"/>
				<xsl:value-of select="$separator"/>				

				<!-- uuid del funder -->
				<xsl:value-of select="fn:map[@key='funder']/fn:string[@key='uuid']"/>
				<xsl:value-of select="$separator"/>

				<!--  -->
				<xsl:value-of select="fn:array[@key='fundingClassifications']/fn:map/fn:string[@key='uri']"/>
				<xsl:value-of select="$separator"/>
				
				<!-- fn:string[@key='fundingProjectScheme'] -->
				<!-- EPS 20230601<xsl:value-of select="fn:string[@key='fundingProjectScheme']"/> -->
				<xsl:value-of select="uab:clean(fn:string[@key='fundingProjectScheme'])"/>	
				<xsl:value-of select="$separator"/>
				
				<!-- fn:boolean[@key='financial'] -->
				<xsl:value-of select="fn:boolean[@key='financial']"/>
				<xsl:value-of select="$separator"/>
				
				<!-- fn:number[@key='awardedAmount'] -->
				<xsl:value-of select="fn:map[@key='awardedAmount']/fn:string[@key='value']"/>
				<xsl:value-of select="$separator"/>
				
				<!-- fn:number[@key='institutionalPart'] -->
				<xsl:value-of select="fn:array[@key='fundingCollaborators']/fn:map/fn:map[@key='institutionalPart']/fn:string[@key='value']"/>
				<xsl:value-of select="$separator"/>
				

				<!-- Budget & expenditures -->
				
				
				
				<!-- Visibility -->
				<xsl:value-of select="fn:map[@key='visibility']/fn:string[@key='key']"/>
				
				<xsl:value-of select="$newline" /> 								

			</xsl:for-each>

		</xsl:for-each> 
	</xsl:template>  
</xsl:stylesheet>