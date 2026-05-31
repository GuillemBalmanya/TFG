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
		<xsl:text>uuid;name_ca_ES;parent_uuid;parent_name_ca_ES;parent_name_en_GB;parent_type_pureId;parent_type_term_ca_ES;parent_type_term_en_GB;parent_type_term_es_ES</xsl:text>
		<xsl:value-of select="$newline" />
		
		<xsl:for-each select="$json-xml/fn:map/fn:array[@key='items']/fn:map">
			<xsl:variable name="uuid" select="fn:string[@key='uuid']" />
			<xsl:variable name="name_ca" select="replace(replace(uab:clean_ca(fn:map[@key='name']), '(&#10;|&#13;)', ''), '(&#59;)', '-')" />
			
			<xsl:for-each select="fn:array[@key='parents']/fn:map">
				<xsl:value-of select="$uuid" />
				<xsl:value-of select="$separator" />
				
				<xsl:value-of select="$name_ca" />
				<xsl:value-of select="$separator" />
				
				<xsl:value-of select="fn:string[@key='uuid']" />
				<xsl:value-of select="$separator" />
				
				<!-- The parent in the new API is not fully expanded. We only have uuid and systemName. So leave others empty -->
				<xsl:value-of select="$separator" />
				<xsl:value-of select="$separator" />
				<xsl:value-of select="$separator" />
				<xsl:value-of select="$separator" />
				<xsl:value-of select="$separator" />
				
				<xsl:value-of select="$newline" />
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
