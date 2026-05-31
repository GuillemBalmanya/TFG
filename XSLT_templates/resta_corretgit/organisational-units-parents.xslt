<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" />
    <xsl:variable name="separator" select="'&#59;'" />
    <xsl:variable name="newline" select="'&#10;'" />
 
    <xsl:template match = "/">
        <xsl:text>uuid;name_ca_ES;parent_uuid;parent_name_ca_ES;parent_name_en_GB;parent_type_pureId;parent_type_term_ca_ES;parent_type_term_en_GB;parent_type_term_es_ES</xsl:text>
        <xsl:value-of select="$newline" />
			<xsl:for-each select="result/items/organisationalUnit/parents">
		        <xsl:value-of select = "../@uuid"/>
                <xsl:value-of select = "$separator" />
				<xsl:value-of select = "replace(replace(../name/text[@locale='ca_ES'],'(&#10;|&#13;)',''),'(&#59;)','-')"/>
                <xsl:value-of select = "$separator" />
				<xsl:value-of select = "parent/@uuid"/>
                <xsl:value-of select = "$separator" />
				<xsl:value-of select = "replace(replace(parent/name/text[@locale='ca_ES'],'(&#10;|&#13;)',''),'(&#59;)','-')"/>
                <xsl:value-of select = "$separator" />
                <xsl:value-of select = "replace(replace(parent/name/text[@locale='en_GB'],'(&#10;|&#13;)',''),'(&#59;)','-')"/>
                <xsl:value-of select = "$separator" />
				<xsl:value-of select = "parent/type/@pureId"/>
                <xsl:value-of select = "$separator" />
				<xsl:value-of select = "replace(replace(parent/type/term/text[@locale='ca_ES'],'(&#10;|&#13;)',''),'(&#59;)','-')"/>
                <xsl:value-of select = "$separator" />
				<xsl:value-of select = "replace(replace(parent/type/term/text[@locale='en_GB'],'(&#10;|&#13;)',''),'(&#59;)','-')"/>
                <xsl:value-of select = "$separator" />
				<xsl:value-of select = "replace(replace(parent/type/term/text[@locale='es_ES'],'(&#10;|&#13;)',''),'(&#59;)','-')"/>
                <xsl:value-of select = "$separator" />				
				<xsl:value-of select="$newline" />
			</xsl:for-each>
    </xsl:template> 
</xsl:stylesheet>	

