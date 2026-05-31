<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:uab="http://www.uab.cat">

	<xsl:include href="functions.xslt"/>
	<xsl:output method="text" />

	<xsl:template match="/">    

		<xsl:text>uuid;relatedAward_uuid</xsl:text>
		<xsl:value-of select="$newline" />

		<xsl:for-each select="result/items/application">
			<!-- Guardem uuid de l'application -->
			<xsl:variable name="uuid" select="@uuid" />

			<!-- Recorrem els fundings -->
			<xsl:for-each select="relatedAwards/relatedAward">

				<!-- Identificador sol·licitud que hem guardat abans-->
				<xsl:value-of select="$uuid"/>
				<xsl:value-of select="$separator" />

				<!-- uuid de l'award -->
				<xsl:value-of select="@uuid"/>
				<xsl:value-of select="$separator"/>
				
				<xsl:value-of select="$newline" /> 								

			</xsl:for-each>

		</xsl:for-each> 
	</xsl:template>  
</xsl:stylesheet>