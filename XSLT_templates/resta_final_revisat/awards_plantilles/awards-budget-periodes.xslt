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




		<xsl:for-each select="fn:array[@key='keywordGroups']/fn:map">

  <xsl:if test="fn:string[@key='logicalName']='/uab/awards/period_number'">

    <xsl:for-each select="fn:array[@key='keywordContainers']/fn:map">

      <xsl:variable name="awardUuid" select="../../fn:string[@key='uuid']"/>

      <xsl:value-of select="$awardUuid"/>
      <xsl:value-of select="$separator"/>

      <!-- URI -->
      <xsl:value-of select="fn:map[@key='structuredKeyword']/fn:string[@key='uri']"/>
      <xsl:value-of select="$separator"/>

      <!-- ES -->
      <xsl:value-of select="fn:array[@key='freeKeywords']/fn:map[@key='es_ES']/fn:array[@key='freeKeywords']/fn:string[1]"/>
      <xsl:value-of select="$separator"/>
      <xsl:value-of select="fn:array[@key='freeKeywords']/fn:map[@key='es_ES']/fn:array[@key='freeKeywords']/fn:string[2]"/>
      <xsl:value-of select="$separator"/>

      <!-- CA -->
      <xsl:value-of select="fn:array[@key='freeKeywords']/fn:map[@key='ca_ES']/fn:array[@key='freeKeywords']/fn:string[1]"/>
      <xsl:value-of select="$separator"/>
      <xsl:value-of select="fn:array[@key='freeKeywords']/fn:map[@key='ca_ES']/fn:array[@key='freeKeywords']/fn:string[2]"/>
      <xsl:value-of select="$separator"/>

      <!-- EN -->
      <xsl:value-of select="fn:array[@key='freeKeywords']/fn:map[@key='en_GB']/fn:array[@key='freeKeywords']/fn:string[1]"/>
      <xsl:value-of select="$separator"/>
      <xsl:value-of select="fn:array[@key='freeKeywords']/fn:map[@key='en_GB']/fn:array[@key='freeKeywords']/fn:string[2]"/>
      <xsl:value-of select="$separator"/>

      <xsl:value-of select="$newline"/>

    </xsl:for-each>

  </xsl:if>

</xsl:for-each>			

	</xsl:template>  
</xsl:stylesheet>