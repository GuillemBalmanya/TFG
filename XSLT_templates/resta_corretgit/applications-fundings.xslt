<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:uab="http://www.uab.cat">

	<xsl:include href="functions.xslt"/>
	<xsl:output method="text" />

	<xsl:template match="/">    

		<xsl:text>uuid;funder_uuid;fundingClassification_uri;fundingProjectScheme;financial;appliedAmount;institutionalPart;visibility</xsl:text>
		<xsl:value-of select="$newline" />
		
				
		

		<xsl:for-each select="result/items/application">
			<!-- Guardem uuid de l'application -->
			<xsl:variable name="uuid" select="@uuid" />

			<!-- Recorrem els fundings -->
			<xsl:for-each select="fundings/funding">

				<!-- Identificador sol·licitud que hem guardat abans-->
				<xsl:value-of select="$uuid"/>
				<xsl:value-of select="$separator" />

				<!-- uuid del funder -->
				<xsl:value-of select="funder/@uuid"/>
				<xsl:value-of select="$separator"/>

				<!-- ATENCIÓ: Funding classifications: no tots en tenen i els que he vist només en tenen un tot i el plural -->
				<xsl:value-of select="fundingClassifications/fundingClassification/@uri"/>
				<xsl:value-of select="$separator"/>
				
				<!-- fundingProjectScheme -->
				<xsl:value-of select="fundingProjectScheme"/>
				<xsl:value-of select="$separator"/>
				
				<!-- financial -->
				<xsl:value-of select="financial"/>
				<xsl:value-of select="$separator"/>
				
				<!-- appliedAmount -->
				<xsl:value-of select="appliedAmount"/>
				<xsl:value-of select="$separator"/>
				
				<!-- institutionalPart -->
				<xsl:value-of select="institutionalPart"/>
				<xsl:value-of select="$separator"/>

				<!-- TODO: Budget & expenditures -->
				
				<!-- Visibility -->
				<xsl:value-of select="visibility/@key"/>
				
				<xsl:value-of select="$newline" /> 								

			</xsl:for-each>

		</xsl:for-each> 
	</xsl:template>  
</xsl:stylesheet>