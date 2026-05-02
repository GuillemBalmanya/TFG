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
<xsl:text>awardUuid;fundingPureId; budgetPureId;budgetExternalId;costCode</xsl:text>
		<xsl:value-of select="$newline" />

		
		
		<xsl:for-each select="$json-xml/fn:map/fn:array[@key='items']/fn:map/fn:array[@key='fundings']/fn:map">
		
			<!-- Guardem uuid de l'award -->
			
			<xsl:variable name="awardUuid" select="../fn:string[@key='uuid']" />
		
			<!-- Guardem uuid i titol del funding -->
			<!--<xsl:variable name="pureId" select="funding/fn:number[@key='pureId']" />				-->
			

			
			<!-- Recorrem els budgets i agafem el costcode -->	
			<xsl:for-each select="fn:array[@key='budgetAndExpenditures']/fn:map">
				<!--identificador unic de l'award que hem guardat abans-->
				
				<xsl:value-of select="$awardUuid"/>
				<xsl:value-of select="$separator" />
				
				
				
				
			<!--identificador unic del funding que busquem ara, dins del bucle-->	
			
			
				<xsl:value-of select="../../fn:number[@key='pureId']"/>
				<xsl:value-of select="$separator" />

								
				<!--Dades del budget-->
					
				<xsl:value-of select="fn:number[@key='pureId']"/>
				<xsl:value-of select="$separator" />
				<xsl:value-of select="fn:string[@key='externalId']"/>
				<xsl:value-of select="$separator" />
				<xsl:value-of select="fn:string[@key='costCode']"/>
				
				<xsl:value-of select="$newline" />
				
					
			</xsl:for-each> 
			 
		</xsl:for-each> 
	</xsl:template>  
</xsl:stylesheet>