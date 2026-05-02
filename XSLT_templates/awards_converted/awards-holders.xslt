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
<xsl:text>uuid;text_ca_ES;text_en_GB;text_es_ES;awhUuid;externalAwhUuid;externalAwhTypePureId;awhExternalId;externalAwhExternalId;awhFirstName;awhLastName;awhRolePureId; awhRoleUri; awhRole_term_text_ca_ES;awhRole_term_text_en_GB;awhRole_term_text_es_ES;startDate;endDate;PRCPercentage</xsl:text>
        <xsl:value-of select="$newline" />

        
        
        <xsl:for-each select="$json-xml/fn:map/fn:array[@key='items']/fn:map">
        
            <!-- Guardem uuid i titol de l'award -->
            <xsl:variable name="uuid" select="fn:string[@key='uuid']" />
            <xsl:variable name="title" select="uab:clean_ca_en_es(fn:map[@key='title'])"/>

            
            <!-- Recorrem els award holders -->
            <xsl:for-each select="awardholders/awardholder">
                <!--identificador unic de l'ajut o conveni que hem guardat abans-->
                <xsl:value-of select="$uuid"/>
                <xsl:value-of select="$separator" />

                <!--Titol de l'ajut o conveni en cat ang i es que hem guardat abans-->
                
                <xsl:value-of select="$title"/>
                <xsl:value-of select="$separator" />

                <!--dades dels holders (membres de l'equip)-->
                <xsl:value-of select="person/fn:string[@key='uuid']"/>
                <xsl:value-of select="$separator" />
                <xsl:value-of select="externalPerson/fn:string[@key='uuid']"/>
                <xsl:value-of select="$separator" />
                <xsl:value-of select="externalPerson/fn:map[@key='type']/fn:number[@key='pureId']"/>
                <xsl:value-of select="$separator" />
                <xsl:value-of select="person/@externalId"/>
                <xsl:value-of select="$separator" />
                <xsl:value-of select="externalPerson/@externalId"/>
                <xsl:value-of select="$separator" />
                <xsl:value-of select="uab:clean(name/firstName)"/>
                <xsl:value-of select="$separator" />
                <xsl:value-of select="uab:clean(name/lastName)"/>
                <xsl:value-of select="$separator" />
                <xsl:value-of select="personRole/fn:number[@key='pureId']"/>
                <xsl:value-of select="$separator" />
                <xsl:value-of select="personRole/@uri"/>
                <xsl:value-of select="$separator" />
                <xsl:value-of select="uab:clean_ca_en_es(personRole/term)"/>
                <xsl:value-of select="$separator" />
                <xsl:value-of select="period/startDate"/>
                <xsl:value-of select="$separator" />
                <xsl:value-of select="period/endDate"/>
                <xsl:value-of select="$separator" />
                <xsl:value-of select="plannedResearcherCommitmentPercentage"/>
                
                <xsl:value-of select="$newline" />
                
            </xsl:for-each>
             
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>