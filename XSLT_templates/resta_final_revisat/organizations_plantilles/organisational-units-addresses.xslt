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
		<xsl:text>organisational-unit_uuid;organisational-unit_name_ca_ES;country_pureID;country_term_text_ca_ES;postalcode;city</xsl:text>
		<xsl:value-of select="$newline" />
		
		<xsl:for-each select="$json-xml/fn:map/fn:array[@key='items']/fn:map">
			<xsl:variable name="uuid" select="fn:string[@key='uuid']" />
			<xsl:variable name="name_ca" select="replace(uab:clean_ca(fn:map[@key='name']), '(&#10;|&#13;)', '')" />
			
			<xsl:for-each select="fn:array[@key='addresses']/fn:map">
				<xsl:value-of select="$uuid" />
				<xsl:value-of select="$separator" />
				<xsl:value-of select="$name_ca" />
				<xsl:value-of select="$separator" />
				
				<!-- API changed: country has uri, not pureId. We use uri -->
				<xsl:value-of select="fn:map[@key='country']/fn:string[@key='uri']" />
				<xsl:value-of select="$separator" />
				
				<xsl:value-of select="replace(uab:clean_ca(fn:map[@key='country']/fn:map[@key='term']), '(&#10;|&#13;)', '')" />
				<xsl:value-of select="$separator" />
				
				<xsl:value-of select="fn:string[@key='postalcode']" />
				<xsl:value-of select="$separator" />
				
				<xsl:value-of select="replace(fn:string[@key='city'], '(&#10;|&#13;)', '')" />
				<xsl:value-of select="$newline" />
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
