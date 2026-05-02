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
<xsl:text>awardUuid;periodeUri;inici_es;fi_es;inici_ca;fi_ca;inici_en;fi_en</xsl:text>
		<xsl:value-of select="$newline" />




		<xsl:for-each select="$json-xml/fn:map/fn:array[@key='items']/fn:map">
			<!-- Guardem uuid de l'award -->
			<xsl:variable name="awardUuid" select="fn:string[@key='uuid']" />


			<!-- Recorrem els keywords -->	
			<xsl:for-each select="fn:array[@key='keywordGroups']/fn:map">
				<xsl:if test="@logicalName='/uab/awards/period_number'">

					<xsl:for-each select="fn:array[@key='keywordContainers']/fn:map">

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