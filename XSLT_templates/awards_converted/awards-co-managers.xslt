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
<xsl:text>awuuid;awtext_ca_ES;awtext_en_GB;awtext_es_ES;cmuuid;cmexternalId;cmname_ca_ES;cmname_en_GB;cmname_es_ES;cmtype_pureId;cmtype_ca_ES</xsl:text>
        <xsl:value-of select="$newline" />

        
        
        <xsl:for-each select="$json-xml/fn:map/fn:array[@key='items']/fn:map">
        
            <!-- Guardem uuid i titol de l'award -->
            <xsl:variable name="uuid" select="fn:string[@key='uuid']" />
            <xsl:variable name="title" select="uab:clean_ca_en_es(fn:map[@key='title'])"/>

            
            <!-- Recorrem les coManagingOrganisationalUnits -->
            <xsl:for-each select="coManagingOrganisationalUnits/coManagingOrganisationalUnit">
                <!--identificador unic de l'ajut o conveni que hem guardat abans-->
                <xsl:value-of select="$uuid"/>
                <xsl:value-of select="$separator" />

                <!--Titol de l'ajut o conveni en cat ang i es que hem guardat abans-->
                
                <xsl:value-of select="$title"/>
                <xsl:value-of select="$separator" />

                <!--dades de les coManagingOrganisationalUnits (commanagers dels ajuts)-->
                <xsl:value-of select="fn:string[@key='uuid']"/>
                <xsl:value-of select="$separator" />
                <xsl:value-of select="fn:string[@key='externalId']"/>
                <xsl:value-of select="$separator" />
                <xsl:value-of select="uab:clean_ca_en_es(name)"/>
                <xsl:value-of select="$separator" />
                <xsl:value-of select="fn:map[@key='type']/fn:number[@key='pureId']"/>
                <xsl:value-of select="$separator" />
                <xsl:value-of select="uab:clean_ca(fn:map[@key='type']/fn:map[@key='term'])"/>
                <xsl:value-of select="$separator" />
                
                <xsl:value-of select="$newline" />

                
            </xsl:for-each>
             
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>