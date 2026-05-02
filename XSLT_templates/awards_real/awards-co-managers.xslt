<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:uab="http://www.uab.cat">

    <xsl:include href="functions.xslt"/>
    <xsl:output method="text" />

    <xsl:template match="/">

        <xsl:text>awuuid;awtext_ca_ES;awtext_en_GB;awtext_es_ES;cmuuid;cmexternalId;cmname_ca_ES;cmname_en_GB;cmname_es_ES;cmtype_pureId;cmtype_ca_ES</xsl:text>
        <xsl:value-of select="$newline" />

        
        
        <xsl:for-each select="result/items/award">
        
            <!-- Guardem uuid i titol de l'award -->
            <xsl:variable name="uuid" select="@uuid" />
            <xsl:variable name="title" select="uab:clean_ca_en_es(title/text)"/>

            
            <!-- Recorrem les coManagingOrganisationalUnits -->
            <xsl:for-each select="coManagingOrganisationalUnits/coManagingOrganisationalUnit">
                <!--identificador unic de l'ajut o conveni que hem guardat abans-->
                <xsl:value-of select="$uuid"/>
                <xsl:value-of select="$separator" />

                <!--Titol de l'ajut o conveni en cat ang i es que hem guardat abans-->
                
                <xsl:value-of select="$title"/>
                <xsl:value-of select="$separator" />

                <!--dades de les coManagingOrganisationalUnits (commanagers dels ajuts)-->
                <xsl:value-of select="@uuid"/>
                <xsl:value-of select="$separator" />
                <xsl:value-of select="@externalId"/>
                <xsl:value-of select="$separator" />
                <xsl:value-of select="uab:clean_ca_en_es(name/text)"/>
                <xsl:value-of select="$separator" />
                <xsl:value-of select="type/@pureId"/>
                <xsl:value-of select="$separator" />
                <xsl:value-of select="uab:clean_ca(type/term/text)"/>
                <xsl:value-of select="$separator" />
                
                <xsl:value-of select="$newline" />

                
            </xsl:for-each>
             
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>