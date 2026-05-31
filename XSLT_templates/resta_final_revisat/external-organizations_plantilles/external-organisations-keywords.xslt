<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:uab="http://www.uab.cat"
	exclude-result-prefixes="fn uab xs">
<xsl:include href="functions.xslt"/>
<xsl:output method="text"/>
<xsl:param name="json-file" as="xs:string"/>

<xsl:template match="/">
<xsl:variable name="json-text" select="unparsed-text($json-file)" />
<xsl:variable name="json-xml" select="json-to-xml($json-text)" />
<xsl:text>external-organisation_uuid;external-organisation_name_ca_ES;keywordGroup_pureID;</xsl:text>
<xsl:text>keywordContainer_pureID;keywordId;structuredKeyword_term_text_ca_ES;</xsl:text>
<xsl:text>structuredKeyword_term_text_en_GB;structuredKeyword_term_text_es_ES</xsl:text>
<xsl:value-of select="$newline"/>
<xsl:for-each select="$json-xml/fn:map/fn:array[@key='items']/fn:map">
  <xsl:variable name="uuid" select="fn:string[@key='uuid']"/>
  <xsl:variable name="name_ca" select="uab:clean_es(fn:map[@key='name'])"/>
  <xsl:for-each select="fn:array[@key='keywordGroups']/fn:map">
    <xsl:variable name="kg_pureId" select="fn:number[@key='pureId']"/>
    <!-- API changed: from keywordContainers to classifications -->
    <xsl:for-each select="fn:array[@key='classifications']/fn:map">
      <xsl:value-of select="$uuid"/>
      <xsl:value-of select="$separator"/>
      <xsl:value-of select="$name_ca"/>
      <xsl:value-of select="$separator"/>
      <xsl:value-of select="$kg_pureId"/>
      <xsl:value-of select="$separator"/>
      <!-- keywordContainer pureId is gone. Print empty -->
      <xsl:value-of select="$separator"/>
      <!-- structuredKeyword pureId is gone. Print uri -->
      <xsl:value-of select="fn:string[@key='uri']"/>
      <xsl:value-of select="$separator"/>
      <xsl:value-of select="uab:clean_ca_en_es(fn:map[@key='term'])"/>
      <xsl:value-of select="$newline"/>
    </xsl:for-each>
  </xsl:for-each>
</xsl:for-each>
</xsl:template>
</xsl:stylesheet>
