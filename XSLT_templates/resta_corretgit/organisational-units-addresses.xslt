<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" />
    <xsl:variable name="separator" select="'&#59;'" />
    <xsl:variable name="newline" select="'&#10;'" />
 
    <xsl:template match = "/">
        <xsl:text>organisational-unit_uuid;organisational-unit_name_ca_ES;country_pureID;country_term_text_ca_ES;postalcode;city</xsl:text>
        <xsl:value-of select="$newline" />
			<xsl:for-each select="result/items/organisationalUnit/addresses">
		        <xsl:value-of select = "../@uuid"/>
                <xsl:value-of select = "$separator" />
				<xsl:value-of select = "replace(../name/text[@locale='ca_ES'],'(&#10;|&#13;)','')"/>
                <xsl:value-of select = "$separator" />
				<xsl:value-of select = "address/country/@pureId"/>
                <xsl:value-of select = "$separator" />					
                <xsl:value-of select = "replace(address/country/term/text[@locale='ca_ES'],'(&#10;|&#13;)','')"/>
                <xsl:value-of select = "$separator" />
				<xsl:value-of select = "address/postalcode"/>
                <xsl:value-of select = "$separator" />					
                <xsl:value-of select = "replace(address/city,'(&#10;|&#13;)','')"/>				
				<xsl:value-of select="$newline" />
			</xsl:for-each>
    </xsl:template> 
</xsl:stylesheet>	

