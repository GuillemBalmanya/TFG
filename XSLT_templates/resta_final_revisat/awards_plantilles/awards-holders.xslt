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
	    <xsl:variable name="startDate"
  		select="fn:map[@key='actualPeriod']/fn:string[@key='startDate']"/>

 	    <xsl:variable name="endDate"
  		select="fn:map[@key='actualPeriod']/fn:string[@key='endDate']"/>
            
            <!-- Recorrem els award holders -->
            <xsl:for-each select="fn:array[@key='awardHolders']/fn:map">
                <!--identificador unic de l'ajut o conveni que hem guardat abans-->
                <xsl:value-of select="$uuid"/>
                <xsl:value-of select="$separator" />

                <!--Titol de l'ajut o conveni en cat ang i es que hem guardat abans-->
                
                <xsl:value-of select="$title"/>
                <xsl:value-of select="$separator" />

                <!--dades dels holders (membres de l'equip)-->
                <xsl:value-of select="fn:map[@key='person']/fn:string[@key='uuid']"/>
                <xsl:value-of select="$separator" />
                <xsl:value-of select="fn:map[@key='externalPerson']/fn:string[@key='uuid']"/>
                <xsl:value-of select="$separator" />
                <xsl:value-of select="fn:map[@key='externalPerson']/fn:map[@key='type']/fn:number[@key='pureId']"/>
                <xsl:value-of select="$separator" />
                <xsl:value-of select="fn:map[@key='person']/fn:string[@key='externalId']"/>
                <xsl:value-of select="$separator" />
                <xsl:value-of select="fn:map[@key='externalPerson']/fn:string[@key='externalId']"/>
                <xsl:value-of select="$separator" />
                <xsl:value-of select="uab:clean(fn:map[@key='name']/fn:string[@key='firstName'])"/>
                <xsl:value-of select="$separator" />
                <xsl:value-of select="uab:clean(fn:map[@key='name']/fn:string[@key='lastName'])"/>
                <xsl:value-of select="$separator" />
                <xsl:value-of select="fn:map[@key='role']/fn:number[@key='pureId']"/>
                <xsl:value-of select="$separator" />
                <xsl:value-of select="fn:map[@key='role']/fn:string[@key='uri']"/>
                <xsl:value-of select="$separator" />
                <xsl:value-of select="uab:clean_ca_en_es(fn:map[@key='role']/fn:map[@key='term'])"/>
                <xsl:value-of select="$separator" />
                <xsl:value-of select="$startDate"/>
                <xsl:value-of select="$separator" />
                <xsl:value-of select="$endDate"/>
                <xsl:value-of select="$separator" />
                <xsl:value-of select="fn:number[@key='plannedResearcherCommitmentPercentage']"/>
                
                <xsl:value-of select="$newline" />
                
            </xsl:for-each>
             
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>