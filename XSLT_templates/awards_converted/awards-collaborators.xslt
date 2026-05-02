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
<xsl:text>awardUuid;awardText_ca_ES;awardText_en_GB;awardText_es_ES;colPureId;colTypePureId;colType_term_text_ca_ES;colType_term_text_en_GB;colType_term_text_es_ES;leadCollaborator;orgUuid;org_name_ca_ES;org_name_en_GB;org_name_es_ES;orgTypePureId;org_type_ca_ES;org_type_en_GB;org_type_es_ES</xsl:text>
		<xsl:value-of select="$newline" />
		
		<xsl:for-each select="$json-xml/fn:map/fn:array[@key='items']/fn:map">
		
			<!-- Guardem uuid i titol de l'award -->
			<xsl:variable name="uuid" select="fn:string[@key='uuid']" />				
			<xsl:variable name="title" select="uab:clean_ca_en_es(fn:map[@key='title'])"/>

			
			<!-- Recorrem els award collaborators -->	
			<xsl:for-each select="fn:array[@key='collaborators']/fn:map">
				<!--identificador unic de l'ajut o conveni que hem guardat abans-->
				<xsl:value-of select="$uuid"/>
				<xsl:value-of select="$separator" />

				<!--Titol de l'ajut o conveni en cat ang i es que hem guardat abans-->
				
				<xsl:value-of select="$title"/>
				<xsl:value-of select="$separator" />  
				
				<!--dades dels collaborators (entitats que participen i rol que fan al projecte)-->
				<xsl:value-of select="fn:number[@key='pureId']"/>
				<xsl:value-of select="$separator" />	
				<xsl:value-of select="fn:map[@key='type']/fn:number[@key='pureId']"/>
				<xsl:value-of select="$separator" />				
				<xsl:value-of select="uab:clean_ca_en_es(fn:map[@key='type']/fn:map[@key='term'])"/>
				<xsl:value-of select="$separator" />
				<xsl:value-of select="leadCollaborator"/>
				<xsl:value-of select="$separator" />
				
				<xsl:choose>
					<xsl:when test="organisationalUnit">
						<xsl:value-of select="organisationalUnit/fn:string[@key='uuid']"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="uab:clean_ca_en_es(organisationalUnit/name)"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="organisationalUnit/fn:map[@key='type']/fn:number[@key='pureId']"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="uab:clean_ca_en_es(organisationalUnit/fn:map[@key='type']/fn:map[@key='term'])"/>
						<xsl:value-of select="$separator" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="externalOrganisation/fn:string[@key='uuid']"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="uab:clean_ca_en_es(externalOrganisation/name)"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="externalOrganisation/fn:map[@key='type']/fn:number[@key='pureId']"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="uab:clean_ca_en_es(externalOrganisation/fn:map[@key='type']/fn:map[@key='term'])"/>
						<xsl:value-of select="$separator" />
					</xsl:otherwise>
				</xsl:choose>
				
				
				
				
				

				<!--dades dels collaborators (entitats que participen i rol que fan al projecte)
				<xsl:value-of select="fn:number[@key='pureId']"/>
				<xsl:value-of select="$separator" />	
				<xsl:value-of select="fn:map[@key='type']/fn:number[@key='pureId']"/>
				<xsl:value-of select="$separator" />				
				<xsl:value-of select="uab:clean_ca_en_es(fn:map[@key='type']/fn:map[@key='term'])"/>
				<xsl:value-of select="$separator" />
				<xsl:value-of select="leadCollaborator"/>
				<xsl:value-of select="$separator" />
				<xsl:value-of select="externalOrganisation/fn:string[@key='uuid']"/>
				<xsl:value-of select="$separator" />
				<xsl:value-of select="uab:clean_ca_en_es(externalOrganisation/name)"/>
				<xsl:value-of select="$separator" />	
				<xsl:value-of select="externalOrganisation/fn:map[@key='type']/fn:number[@key='pureId']"/>
				<xsl:value-of select="$separator" />				
				<xsl:value-of select="uab:clean_ca_en_es(externalOrganisation/fn:map[@key='type']/fn:map[@key='term'])"/>	-->			
				<xsl:value-of select="$newline" />
				
			</xsl:for-each> 
			 
		</xsl:for-each> 
	</xsl:template>  
</xsl:stylesheet>