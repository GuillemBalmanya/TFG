<!-- Versió JSON: llegeix dades de fitxer JSON via json-to-xml() -->

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

		<xsl:text>uuid;text_ca_ES;text_en_GB;text_es_ES;idPureId;idValue;idTypePureId;idTypeUri;idType_term_text_ca_ES;idType_term_text_en_GB;idType_term_text_es_ES</xsl:text>
		<xsl:value-of select="$newline" />

		<xsl:for-each select="$json-xml/fn:map/fn:array[@key='items']/fn:map">

			<!-- Guardem uuid i titol de l'award -->
			<xsl:variable name="uuid" select="fn:string[@key='uuid']" />
			<xsl:variable name="title" select="uab:clean_ca_en_es(fn:map[@key='title'])"/>

			<!-- Recorrem els identifiers -->
			<!-- JSON: identifiers (en lloc de ids/id) -->
			<xsl:for-each select="fn:array[@key='identifiers']/fn:map">
				<!--identificador unic de l'ajut o conveni que hem guardat abans-->
				<xsl:value-of select="$uuid"/>
				<xsl:value-of select="$separator" />

				<!--Titol de l'ajut o conveni en cat ang i es que hem guardat abans-->
				<xsl:value-of select="$title"/>
				<xsl:value-of select="$separator" />

				<!--Id i tipus d'ajut o conveni en cat ang i fr-->
				<!-- @pureId → pureId (numèric) -->
				<xsl:value-of select="fn:number[@key='pureId']"/>
				<xsl:value-of select="$separator" />
				<!-- value: per PrimaryId/Id és "value", per ClassifiedId és "id" -->
				<xsl:value-of select="uab:clean(concat(fn:string[@key='value'], fn:string[@key='id']))"/>
				<xsl:value-of select="$separator" />
				<!-- type/@pureId → type.pureId -->
				<xsl:value-of select="fn:map[@key='type']/fn:number[@key='pureId']"/>
				<xsl:value-of select="$separator" />
				<!-- type/@uri → type.uri -->
				<xsl:value-of select="fn:map[@key='type']/fn:string[@key='uri']"/>
				<xsl:value-of select="$separator" />
				<!-- type/term/text → type.term (fn:map) -->
				<xsl:value-of select="uab:clean_ca_en_es(fn:map[@key='type']/fn:map[@key='term'])"/>

				<xsl:value-of select="$newline" />

			</xsl:for-each>

		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
