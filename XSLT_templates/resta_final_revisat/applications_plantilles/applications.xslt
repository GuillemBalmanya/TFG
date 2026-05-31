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

		<xsl:text>uuid;text_ca_ES;text_en_GB;text_es_ES;typePureId;typeUri;natureType_uri;fundingOpportunity_Uuid;fundingOpportunity_ExternalId;managingOrganisationalUnit_Uuid;managingOrganisationalUnit_ExternaId;idFenix;referenceCode;applicant_IP_uuid;awardedbyfunder;submittedtofunder;expectedPeriod_startDate;expectedPeriod_endDate;submissionDate;awardDate;totalAppliedAmount;funderReply</xsl:text>

		<xsl:value-of select="$newline" />
		<xsl:for-each select="$json-xml/fn:map/fn:array[@key='items']/fn:map">
			<!-- Identificador únic de la sol·licitud-->
			<xsl:value-of select="fn:string[@key='uuid']"/>
			<xsl:value-of select="$separator" />

			<!-- Títol de la sol·licitud (ca;en;es) -->
			<xsl:value-of select="uab:clean_ca_en_es(fn:map[@key='title'])"/>
			<xsl:value-of select="$separator" />  

			<!--Id tipus -->
			<xsl:value-of select="fn:map[@key='type']/fn:number[@key='pureId']"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="fn:map[@key='type']/fn:string[@key='uri']"/>
			<xsl:value-of select="$separator" />			

			<!-- Nature type -->
			<xsl:value-of select="fn:array[@key='natureTypes']/fn:map[1]/fn:string[@key='uri']"/>
			<xsl:value-of select="$separator" />
			
			<!--Id de la convocatòria -->
			<xsl:value-of select="fn:map[@key='fundingOpportunity']/fn:string[@key='uuid']"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="fn:map[@key='fundingOpportunity']/fn:string[@key='externalId']"/>
			<xsl:value-of select="$separator" />

			<!-- Id i nom de la unitat gestionadora de la sol·licitud -->
			<xsl:value-of select="fn:map[@key='managingOrganization']/fn:string[@key='uuid']"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="fn:map[@key='managingOrganization']/fn:string[@key='externalId']"/>
			<xsl:value-of select="$separator" />
			
			<!-- Codi fènix -->
			<xsl:value-of select="fn:array[@key='identifiers']/fn:map[fn:map[@key='type']/fn:string[@key='uri']='/dk/atira/pure/upm/classifiedsource/id_fenix']/fn:string[@key='value']"/>
			<xsl:value-of select="$separator" />			

			<!-- Codi oficial -->
			<xsl:value-of select="fn:array[@key='identifiers']/fn:map[fn:map[@key='type']/fn:string[@key='uri']='/dk/atira/pure/upm/classifiedsource/referencecode']/fn:string[@key='value']"/>
			<xsl:value-of select="$separator" />
			
			<!-- Applicants. Agafem només l'IP -->
			<xsl:value-of select="fn:array[@key='applicants']/fn:map[fn:map[@key='role']/fn:string[@key='uri']='/dk/atira/pure/application/roles/application/pi']/fn:map[@key='person']/fn:string[@key='uuid']"/>
			<xsl:value-of select="$separator" />
			
			<!-- Dates -->
			<xsl:value-of select="fn:array[@key='statuses']/fn:map[fn:map[@key='status']/fn:string[@key='uri']='/dk/atira/pure/application/status/awardedbyfunder']/fn:string[@key='date']"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="fn:array[@key='statuses']/fn:map[fn:map[@key='status']/fn:string[@key='uri']='/dk/atira/pure/application/status/submittedtofunder']/fn:string[@key='date']"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="fn:map[@key='expectedPeriod']/fn:string[@key='startDate']"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="fn:map[@key='expectedPeriod']/fn:string[@key='endDate']"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="fn:string[@key='submissionDate']"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="fn:string[@key='awardDate']"/>
			<xsl:value-of select="$separator" />			
			
			<!-- Quantitats -->
			<xsl:value-of select="fn:map[@key='totalAppliedAmount']/fn:string[@key='value']"/>
			<xsl:value-of select="$separator" />
			
			<!-- Resposta -->
			<xsl:value-of select="fn:string[@key='funderReply']"/>

			<xsl:value-of select="$newline" /> 	
		</xsl:for-each> 
	</xsl:template>  
</xsl:stylesheet>
