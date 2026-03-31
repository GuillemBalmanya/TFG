<!-- Versió JSON: llegeix dades de fitxer JSON via json-to-xml() -->
<!-- ATENCIÓ! AL 2021 CANVIEN L'ORIGEN A STATUS, JA NO DE KEYWORDS-->

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

		<xsl:text>uuid;externalId;text_ca_ES;text_en_GB;text_es_ES;estatId;estat_term_text_ca_ES;estat_term_text_en_GB;estat_term_text_es_ES</xsl:text>
		<xsl:value-of select="$newline" />

		<xsl:for-each select="$json-xml/fn:map/fn:array[@key='items']/fn:map">

			<!-- Guardem uuid i titol de l'award -->
			<xsl:variable name="uuid" select="fn:string[@key='uuid']" />
			<xsl:variable name="externalId" select="fn:string[@key='externalId']"/>
			<xsl:variable name="title" select="uab:clean_ca_en_es(fn:map[@key='title'])"/>

			<!-- Recorrem els keywordGroups -->
			<!-- XML: keywordGroups/keywordGroup → JSON: keywordGroups[] -->
			<xsl:for-each select="fn:array[@key='keywordGroups']/fn:map">
				<!-- Filtre per logicalName (equivalent a @logicalName='/uab/awards/estat_ajut') -->
				<xsl:if test="fn:string[@key='logicalName']='/uab/awards/estat_ajut'">
					<!--identificador unic de l'award que hem guardat abans-->
					<xsl:value-of select="$uuid"/>
					<xsl:value-of select="$separator" />
					<xsl:value-of select="$externalId"/>
					<xsl:value-of select="$separator" />

					<!--Titol de l'award en cat ang i es que hem guardat abans-->
					<xsl:value-of select="$title"/>
					<xsl:value-of select="$separator" />

					<!--estat de l'award-->
					<!-- structuredKeyword/@pureId → structuredKeyword.pureId -->
					<xsl:value-of select="fn:array[@key='keywordContainers']/fn:map/fn:map[@key='structuredKeyword']/fn:number[@key='pureId']"/>
					<xsl:value-of select="$separator" />
					<!-- structuredKeyword/term/text → structuredKeyword.term (fn:map locale) -->
					<xsl:value-of select="uab:clean_ca_en_es(fn:array[@key='keywordContainers']/fn:map/fn:map[@key='structuredKeyword']/fn:map[@key='term'])"/>

					<xsl:value-of select="$newline" />
				</xsl:if>
			</xsl:for-each>

		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
