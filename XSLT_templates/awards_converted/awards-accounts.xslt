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
<xsl:text>awarduuId;fundingPureId; budgetPureId;budgetExternalId;costCode;classificationPureId;classificationUri;yearlyBugdetExternalId;year;budget</xsl:text>
		<xsl:value-of select="$newline" />

		
		
		<xsl:for-each select="$json-xml/fn:map/fn:array[@key='items']/fn:map/fn:array[@key='fundings']/fn:map">
		
			<!-- Guardem uuid  del funding -->
			<!--<xsl:variable name="fundingPureId" select="funding/fn:number[@key='pureId']" />	-->
		
			<!-- Guardem uuid i titol de l'award -->
			<xsl:variable name="awarduuId" select="../fn:string[@key='uuid']" />				
			

			
			<!-- Recorrem els budgets i agafem el costcode -->	
			<xsl:for-each select="fn:array[@key='budgetAndExpenditures']/fn:map">
			
						<!-- Guardem uuid del funding -->
			<xsl:variable name="fundingPureId" select="../../fn:number[@key='pureId']" />	
				
					<xsl:variable name="budgetPureId" select="fn:number[@key='pureId']" />
					<xsl:variable name="budgetExternalId" select="fn:string[@key='externalId']" />					
					<xsl:variable name="budgetCostCode" select="fn:string[@key='costCode']" />
					
						<xsl:for-each select="fn:array[@key='accounts']/fn:map">
								
								<xsl:variable name="classificationPureId"  select="fn:map[@key='classification']/fn:number[@key='pureId']"/>
								<xsl:variable name="classificationUri"  select="fn:map[@key='classification']/fn:string[@key='uri']"/>
								
								
				
							<xsl:for-each select="fn:array[@key='yearlyBudgets']/fn:map">
							
								<!--identificador unic del award i del 	funding que hem guardat abans-->
								<xsl:value-of select="$awarduuId"/>
								<xsl:value-of select="$separator" />
								<xsl:value-of select="$fundingPureId"/>
								<xsl:value-of select="$separator" />
								
								<!--identificadors del budget que hem guardat abans-->
								<xsl:value-of select="$budgetPureId"/>
								<xsl:value-of select="$separator" />			
								<xsl:value-of select="$budgetExternalId"/>
								<xsl:value-of select="$separator" />	
								<xsl:value-of select="$budgetCostCode"/>
								<xsl:value-of select="$separator" />
								<xsl:value-of select="$classificationPureId"/>
								<xsl:value-of select="$separator" />								
								<xsl:value-of select="$classificationUri"/>
								<xsl:value-of select="$separator" />
								
								
								
								<!--Dades del budget-->				
							
								<xsl:value-of select="fn:string[@key='externalId']"/>
								<xsl:value-of select="$separator" />
								<xsl:value-of select="fn:number[@key='year']"/>						
								<xsl:value-of select="$separator" />
								<xsl:value-of select="fn:number[@key='budget']"/>
								
								<xsl:value-of select="$newline" />
									
							</xsl:for-each>	
						        
						</xsl:for-each>	
				
			</xsl:for-each> 
			 
		</xsl:for-each> 
	</xsl:template>  
</xsl:stylesheet>