<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:uab="http://www.uab.cat">

	<xsl:include href="functions.xslt"/>
	<xsl:output method="text" />

	<xsl:template match="/">    

		<xsl:text>awardUuid;periodeUri;inici_es;fi_es;inici_ca;fi_ca;inici_en;fi_en</xsl:text>
		<xsl:value-of select="$newline" />




		<xsl:for-each select="result/items/award">
			<!-- Guardem uuid de l'award -->
			<xsl:variable name="awardUuid" select="@uuid" />


			<!-- Recorrem els keywords -->	
			<xsl:for-each select="keywordGroups/keywordGroup">
				<xsl:if test="@logicalName='/uab/awards/period_number'">

					<xsl:for-each select="keywordContainers/keywordContainer">

						<!--identificador unic de l'award que hem guardat abans-->
						<xsl:value-of select="$awardUuid"/>
						<xsl:value-of select="$separator" />
						<!--periodes del budget-->

						<xsl:value-of select="structuredKeyword/@uri"/>
						<xsl:value-of select="$separator" />

						<xsl:value-of select="freeKeywords/freeKeyword[@locale='es_ES']/freeKeywords/freeKeyword[1]"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="freeKeywords/freeKeyword[@locale='es_ES']/freeKeywords/freeKeyword[2]"/>
						<xsl:value-of select="$separator" />

						<xsl:value-of select="freeKeywords/freeKeyword[@locale='ca_ES']/freeKeywords/freeKeyword[1]"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="freeKeywords/freeKeyword[@locale='ca_ES']/freeKeywords/freeKeyword[2]"/>
						<xsl:value-of select="$separator" />

						<xsl:value-of select="freeKeywords/freeKeyword[@locale='en_GB']/freeKeywords/freeKeyword[1]"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="freeKeywords/freeKeyword[@locale='en_GB']/freeKeywords/freeKeyword[2]"/>
						<xsl:value-of select="$separator" />

						<xsl:value-of select="$newline" />
					</xsl:for-each>	
				</xsl:if>
			</xsl:for-each>				


		</xsl:for-each> 
	</xsl:template>  
</xsl:stylesheet>