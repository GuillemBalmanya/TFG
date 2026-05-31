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
<xsl:text>uuid;fcFundingPureId; fcFunder_uuid;fcName_text_ca_ES;fcName_text_en_GB;fcName_text_es_ES;colType_term_text_ca_ES;colType_term_text_en_GB;colType_term_text_es_ES;fcInstitutionalPart</xsl:text>
		<xsl:value-of select="$newline" />
		
				
		

		<xsl:for-each select="$json-xml/fn:map/fn:array[@key='items']/fn:map">
			<!-- Guardem uuid de l'application -->
			<xsl:variable name="awardUuid" select="fn:string[@key='uuid']" />

			<!-- Recorrem els fundings -->
			<xsl:for-each select="fn:array[@key='fundings']/fn:map/fn:array[@key='fundingCollaborators']/fn:map">

				<!-- Identificador sol·licitud que hem guardat abans-->
				<xsl:value-of select="$awardUuid"/>
				<xsl:value-of select="$separator" />
				
				<!-- pureId i externalId del funding -->
				<xsl:value-of select="fn:number[@key='pureId']"/>
				<xsl:value-of select="$separator"/>

				<!-- uuid del funder -->
				<xsl:value-of select="fn:map[@key='collaborator']/fn:string[@key='uuid']"/>
				<xsl:value-of select="$separator"/>
				<xsl:value-of select="uab:clean_ca_en_es(fn:map[@key='collaborator']/fn:map[@key='name'])"/>
				<xsl:value-of select="$separator" />

				<!--tipus de funder  -->
				<xsl:value-of select="uab:clean_ca_en_es(fn:map[@key='collaborator']/fn:map[@key='type']/fn:map[@key='term'])"/>
				<xsl:value-of select="$separator" />
				
				<!-- fn:number[@key='institutionalPart'] -->
				<xsl:value-of select="fn:map[@key='institutionalPart']/fn:string[@key='value']"/>
				<xsl:value-of select="$separator"/>
				
				<xsl:value-of select="$newline" /> 								

			</xsl:for-each>

		</xsl:for-each> 
	</xsl:template>  
</xsl:stylesheet>