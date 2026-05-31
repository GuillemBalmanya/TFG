<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:uab="http://www.uab.cat" version="1.0">
<xsl:include href="functions.xslt"/>
<xsl:output method="text"/>
<xsl:template match="/">
<xsl:text>external-organisation_uuid;external-organisation_name_ca_ES;keywordGroup_pureID;</xsl:text>
<xsl:text>keywordContainer_pureID;keywordId;structuredKeyword_term_text_ca_ES;</xsl:text>
<xsl:text>structuredKeyword_term_text_en_GB;structuredKeyword_term_text_es_ES</xsl:text>
<xsl:value-of select="$newline"/>
<xsl:for-each select="result/items/externalOrganisation/keywordGroups/keywordGroup">
<xsl:value-of select="../../@uuid"/>
<xsl:value-of select="$separator"/>
<xsl:value-of select="uab:clean_es(../../name/text)"/>
<xsl:value-of select="$separator"/>
<xsl:value-of select="@pureId"/>
<xsl:value-of select="$separator"/>
<xsl:for-each select="keywordContainers/keywordContainer">
<xsl:value-of select="@pureId"/>
<xsl:value-of select="$separator"/>
<xsl:value-of select="structuredKeyword/@pureId"/>
<xsl:value-of select="$separator"/>
<xsl:value-of select="uab:clean_ca_en_es(structuredKeyword/term/text)"/>
<xsl:value-of select="$newline"/>
</xsl:for-each>
</xsl:for-each>
</xsl:template>
</xsl:stylesheet>