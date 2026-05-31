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
	
        <xsl:text>id;text_ca_ES;text_en_GB;text_es_ES;id_pureId;id_value;idType_ca_ES;idType_en_GB;idType_es_ES</xsl:text>
        <xsl:value-of select="$newline" />
        <xsl:for-each select="$json-xml/fn:map/fn:array[@key='items']/fn:map">
            <xsl:variable name="uuid" select="fn:string[@key='uuid']"/>
            <xsl:variable name="name" select="uab:clean_ca_en_es(fn:map[@key='name'])"/>
            <xsl:for-each select="fn:array[@key='identifiers']/fn:map">
                
			<!--identificador unic de l'entitat-->				
				<xsl:value-of select="$uuid"/>
                <xsl:value-of select="$separator" />
				
			<!--nom de l'entitat en cat, ang i fr-->
			    <xsl:value-of select="$name"/>
				<xsl:value-of select="$separator" />
				
			<!--id-->				
                <xsl:value-of select="fn:number[@key='pureId']"/>
                <xsl:value-of select="$separator" />
				<xsl:choose>
                   <xsl:when test="fn:string[@key='value']">
                       <xsl:value-of select="fn:string[@key='value']"/>
                   </xsl:when>
                   <xsl:otherwise>
                       <xsl:value-of select="fn:string[@key='id']"/>
                   </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="$separator" />
				
			<!--tipus d'id en cat, ang i fr-->
				<xsl:value-of select="uab:clean_ca_en_es(fn:map[@key='type']/fn:map[@key='term'])"/>
				<xsl:value-of select="$separator" />
		    	<xsl:value-of select="$newline" />					
				
            </xsl:for-each>
        </xsl:for-each>
   </xsl:template> 
</xsl:stylesheet>
