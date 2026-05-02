<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:uab="http://www.uab.cat">

	<xsl:include href="functions.xslt"/>
	<xsl:output method="text" />

	<xsl:template match="/">    

		<xsl:text>awardUuid;fundingPureId; budgetPureId;budgetExternalId;costCode</xsl:text>
		<xsl:value-of select="$newline" />

		
		
		<xsl:for-each select="result/items/award/fundings">
		
			<!-- Guardem uuid de l'award -->
			
			<xsl:variable name="awardUuid" select="../@uuid" />
		
			<!-- Guardem uuid i titol del funding -->
			<!--<xsl:variable name="pureId" select="funding/@pureId" />				-->
			

			
			<!-- Recorrem els budgets i agafem el costcode -->	
			<xsl:for-each select="funding/budgetAndExpenditures/budgetAndExpenditure">
				<!--identificador unic de l'award que hem guardat abans-->
				
				<xsl:value-of select="$awardUuid"/>
				<xsl:value-of select="$separator" />
				
				
				
				
			<!--identificador unic del funding que busquem ara, dins del bucle-->	
			
			
				<xsl:value-of select="../../@pureId"/>
				<xsl:value-of select="$separator" />

								
				<!--Dades del budget-->
					
				<xsl:value-of select="@pureId"/>
				<xsl:value-of select="$separator" />
				<xsl:value-of select="@externalId"/>
				<xsl:value-of select="$separator" />
				<xsl:value-of select="costCode"/>
				
				<xsl:value-of select="$newline" />
				
					
			</xsl:for-each> 
			 
		</xsl:for-each> 
	</xsl:template>  
</xsl:stylesheet>