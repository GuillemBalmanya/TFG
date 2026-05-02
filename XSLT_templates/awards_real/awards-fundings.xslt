<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:uab="http://www.uab.cat">

	<xsl:include href="functions.xslt"/>
	<xsl:output method="text" />

	<xsl:template match="/">    

		<xsl:text>uuid;fundingPureId; fundingExternalId;funder_uuid;fundingClassification_uri;fundingProjectScheme;financial;awardedAmount;institutionalPart;visibility</xsl:text>
		<xsl:value-of select="$newline" />
		
				
		

		<xsl:for-each select="result/items/award">
			<!-- Guardem uuid de l'application -->
			<xsl:variable name="awardUuid" select="@uuid" />

			<!-- Recorrem els fundings -->
			<xsl:for-each select="fundings/funding">

				<!-- Identificador sol·licitud que hem guardat abans-->
				<xsl:value-of select="$awardUuid"/>
				<xsl:value-of select="$separator" />
				
				<!-- pureId i externalId del funding -->
				<xsl:value-of select="@pureId"/>
				<xsl:value-of select="$separator"/>
				<xsl:value-of select="@externalId"/>
				<xsl:value-of select="$separator"/>				

				<!-- uuid del funder -->
				<xsl:value-of select="funder/@uuid"/>
				<xsl:value-of select="$separator"/>

				<!--  -->
				<xsl:value-of select="fundingClassifications/fundingClassification/@uri"/>
				<xsl:value-of select="$separator"/>
				
				<!-- fundingProjectScheme -->
				<!-- EPS 20230601<xsl:value-of select="fundingProjectScheme"/> -->
				<xsl:value-of select="uab:clean(fundingProjectScheme)"/>	
				<xsl:value-of select="$separator"/>
				
				<!-- financial -->
				<xsl:value-of select="financial"/>
				<xsl:value-of select="$separator"/>
				
				<!-- awardedAmount -->
				<xsl:value-of select="awardedAmount"/>
				<xsl:value-of select="$separator"/>
				
				<!-- institutionalPart -->
				<xsl:value-of select="institutionalPart"/>
				<xsl:value-of select="$separator"/>
				

				<!-- Budget & expenditures -->
				
				
				
				<!-- Visibility -->
				<xsl:value-of select="visibility/@key"/>
				
				<xsl:value-of select="$newline" /> 								

			</xsl:for-each>

		</xsl:for-each> 
	</xsl:template>  
</xsl:stylesheet>