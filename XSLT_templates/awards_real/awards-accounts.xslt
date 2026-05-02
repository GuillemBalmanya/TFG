<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:uab="http://www.uab.cat">

	<xsl:include href="functions.xslt"/>
	<xsl:output method="text" />

	<xsl:template match="/">    

		<xsl:text>awarduuId;fundingPureId; budgetPureId;budgetExternalId;costCode;classificationPureId;classificationUri;yearlyBugdetExternalId;year;budget</xsl:text>
		<xsl:value-of select="$newline" />

		
		
		<xsl:for-each select="result/items/award/fundings">
		
			<!-- Guardem uuid  del funding -->
			<!--<xsl:variable name="fundingPureId" select="funding/@pureId" />	-->
		
			<!-- Guardem uuid i titol de l'award -->
			<xsl:variable name="awarduuId" select="../@uuid" />				
			

			
			<!-- Recorrem els budgets i agafem el costcode -->	
			<xsl:for-each select="funding/budgetAndExpenditures/budgetAndExpenditure">
			
						<!-- Guardem uuid del funding -->
			<xsl:variable name="fundingPureId" select="../../@pureId" />	
				
					<xsl:variable name="budgetPureId" select="@pureId" />
					<xsl:variable name="budgetExternalId" select="@externalId" />					
					<xsl:variable name="budgetCostCode" select="costCode" />
					
						<xsl:for-each select="accounts/account">
								
								<xsl:variable name="classificationPureId"  select="classification/@pureId"/>
								<xsl:variable name="classificationUri"  select="classification/@uri"/>
								
								
				
							<xsl:for-each select="yearlyBudgets/yearlyBudget">
							
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
							
								<xsl:value-of select="@externalId"/>
								<xsl:value-of select="$separator" />
								<xsl:value-of select="year"/>						
								<xsl:value-of select="$separator" />
								<xsl:value-of select="budget"/>
								
								<xsl:value-of select="$newline" />
									
							</xsl:for-each>	
						        
						</xsl:for-each>	
				
			</xsl:for-each> 
			 
		</xsl:for-each> 
	</xsl:template>  
</xsl:stylesheet>