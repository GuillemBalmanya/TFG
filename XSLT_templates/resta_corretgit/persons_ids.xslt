<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" />
    <xsl:variable name="separator" select="'&#59;'" />
    <xsl:variable name="newline" select="'&#10;'" />

    <xsl:template match = "/">
        <xsl:text>uuid;value;type</xsl:text>
        <xsl:value-of select="$newline" />
        <xsl:for-each select="result/items/person/ids">
            <xsl:variable name="uuid" select="../@uuid" />
            <xsl:for-each select="id">
                <xsl:value-of select = "$uuid"/>
                <xsl:value-of select="$separator" />
                <xsl:value-of select = "replace(value, '&#10;', '')"/>
                <xsl:value-of select="$separator" />
                <!--<xsl:value-of select = "replace(type/term/text[@locale='ca_ES'], '&#xD;&#xA;','')"/>-->
                <xsl:value-of select = "type/term/text[@locale='ca_ES']"/>
                <xsl:value-of select="$newline" />
            </xsl:for-each> 
        </xsl:for-each> 
   </xsl:template>  
</xsl:stylesheet>