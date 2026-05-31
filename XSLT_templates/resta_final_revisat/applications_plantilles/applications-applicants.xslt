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

		<xsl:text>uuid;externalId;text_ca_ES;text_en_GB;text_es_ES;appUuid;externalAppUuid;externalAppTypePureId;appExternalId;externalAppExternalId;appFirstName;appLastName;appRolePureId; appRoleUri; appRole_term_text_ca_ES;appRole_term_text_en_GB;appRole_term_text_es_ES</xsl:text>
		<xsl:value-of select="$newline" />

		<xsl:for-each select="$json-xml/fn:map/fn:array[@key='items']/fn:map">
		
			<!-- Guardem uuid i titol de la sol·licitud -->
			<xsl:variable name="uuid" select="fn:string[@key='uuid']" />				
			<xsl:variable name="externalId" select="fn:string[@key='externalId']" />	
			<xsl:variable name="title" select="uab:clean_ca_en_es(fn:map[@key='title'])"/>

			<!-- Recorrem els applicants -->	
			<xsl:for-each select="fn:array[@key='applicants']/fn:map">
				<!--identificador unic de la sol·licitud que hem guardat abans-->
				<xsl:value-of select="$uuid"/>
				<xsl:value-of select="$separator" />
				<xsl:value-of select="$externalId"/>
				<xsl:value-of select="$separator" />

				<!--Titol de la sol·licitud en cat ang i es que hem guardat abans-->
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
				
				<xsl:value-of select="$newline" />
				
			</xsl:for-each> 
			 
		</xsl:for-each> 
	</xsl:template>  
</xsl:stylesheet>
