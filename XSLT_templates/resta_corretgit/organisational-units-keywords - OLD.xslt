<!--<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:uab="http://www.uab.cat">

    <xsl:include href="functions.xslt"/>
	<xsl:output method="text" />
  <!-- EPS 20230602   <xsl:variable name="separator" select="'&#59;'" />
    <xsl:variable name="newline" select="'&#10;'" />-->
 
    <xsl:template match = "/">
        <xsl:text>organisational-unit_uuid;organisational-unit_name_ca_ES;keywordGroup_pureID;keywordContainer_pureID;keywordId;structuredKeyword_term_text_ca_ES</xsl:text>
        <xsl:value-of select="$newline" />
			<xsl:for-each select="result/items/organisationalUnit/keywordGroups">
		        <xsl:value-of select = "../@uuid"/>
                <xsl:value-of select = "$separator" />
<!-- EPS 20230602 <xsl:value-of select = "replace(../name/text[@locale='ca_ES'],'(&#10;|&#13;)','')"/> -->
                <xsl:value-of select="uab:cutclean_ca(../name/text)"/>
				<xsl:value-of select = "$separator" />
				<xsl:value-of select = "keywordGroup/@pureId"/>
                <xsl:value-of select = "$separator" />
				<xsl:value-of select = "keywordGroup/keywordContainers/keywordContainer/@pureId"/>
                <xsl:value-of select = "$separator" />	
				<xsl:value-of select = "keywordGroup/keywordContainers/keywordContainer/structuredKeyword/@pureId"/>
                <xsl:value-of select = "$separator" />					
           <!-- <xsl:value-of select = "replace(keywordGroup/keywordContainers/keywordContainer/structuredKeyword/term/text[@locale='ca_ES'],'(&#10;|&#13;)','')"/>-->
			    <xsl:value-of select="uab:clean_ca_en_es(keywordGroup/keywordContainers/keywordContainer/structuredKeyword/term/text)"/>
				<xsl:value-of select="$newline" />
			</xsl:for-each>
    </xsl:template> 
</xsl:stylesheet>	

