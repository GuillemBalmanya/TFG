<!-- Versió JSON: llegeix dades de fitxer JSON via json-to-xml() -->
<!-- Triple niuament: award → keywordGroups → keywordContainers -->
<!-- Accés posicional a freeKeywords amb locale -->

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

			<!-- Recorrem els keywordGroups -->
			<!-- XML: keywordGroups/keywordGroup[@logicalName='...'] -->
			<!-- JSON: keywordGroups[] on logicalName='...' -->
			<xsl:for-each select="fn:array[@key='keywordGroups']/fn:map">
				<xsl:if test="fn:string[@key='logicalName']='/uab/awards/period_number'">

					<!-- Recorrem keywordContainers -->
					<!-- XML: keywordContainers/keywordContainer -->
					<!-- JSON: keywordContainers[] -->
					<xsl:for-each select="fn:array[@key='keywordContainers']/fn:map">

						<!--identificador unic de l'award que hem guardat abans-->
						<xsl:value-of select="$awardUuid"/>
						<xsl:value-of select="$separator" />
						<!--periodes del budget-->

						<!-- structuredKeyword/@uri → structuredKeyword.uri -->
						<xsl:value-of select="fn:map[@key='structuredKeyword']/fn:string[@key='uri']"/>
						<xsl:value-of select="$separator" />

						<!--
							XML original: freeKeywords/freeKeyword[@locale='es_ES']/freeKeywords/freeKeyword[1]
							JSON structure:
							  "freeKeywords": [
							    {"locale": "es_ES", "pureId": 123, "freeKeywords": ["01/12/2024", "30/11/2027"]},
							    {"locale": "ca_ES", ...},
							    {"locale": "en_GB", ...}
							  ]
							json-to-xml():
							  <fn:array key="freeKeywords">
							    <fn:map>
							      <fn:string key="locale">es_ES</fn:string>
							      <fn:array key="freeKeywords">
							        <fn:string>01/12/2024</fn:string>
							        <fn:string>30/11/2027</fn:string>
							      </fn:array>
							    </fn:map>
							    ...
							  </fn:array>
						-->

						<!-- es_ES: inici i fi -->
						<xsl:value-of select="fn:array[@key='freeKeywords']/fn:map[fn:string[@key='locale']='es_ES']/fn:array[@key='freeKeywords']/fn:string[1]"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="fn:array[@key='freeKeywords']/fn:map[fn:string[@key='locale']='es_ES']/fn:array[@key='freeKeywords']/fn:string[2]"/>
						<xsl:value-of select="$separator" />

						<!-- ca_ES: inici i fi -->
						<xsl:value-of select="fn:array[@key='freeKeywords']/fn:map[fn:string[@key='locale']='ca_ES']/fn:array[@key='freeKeywords']/fn:string[1]"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="fn:array[@key='freeKeywords']/fn:map[fn:string[@key='locale']='ca_ES']/fn:array[@key='freeKeywords']/fn:string[2]"/>
						<xsl:value-of select="$separator" />

						<!-- en_GB: inici i fi -->
						<xsl:value-of select="fn:array[@key='freeKeywords']/fn:map[fn:string[@key='locale']='en_GB']/fn:array[@key='freeKeywords']/fn:string[1]"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="fn:array[@key='freeKeywords']/fn:map[fn:string[@key='locale']='en_GB']/fn:array[@key='freeKeywords']/fn:string[2]"/>
						<xsl:value-of select="$separator" />

						<xsl:value-of select="$newline" />
					</xsl:for-each>
				</xsl:if>
			</xsl:for-each>

		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
