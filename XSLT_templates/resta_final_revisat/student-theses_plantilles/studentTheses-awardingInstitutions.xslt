<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:uab="http://www.uab.cat"
    exclude-result-prefixes="xs fn uab">

	<xsl:include href="functions.xslt"/>

	<xsl:output method="text" />

	<xsl:param name="json-file" as="xs:string"/>

	<xsl:template name="xsl:initial-template">
		<xsl:variable name="json-text" select="unparsed-text($json-file)"/>
		<xsl:variable name="json-xml" select="json-to-xml($json-text)"/>
		
		<xsl:text>thesisUuid;organisationalUnitUuid;externalId;nameText_ca;nameText_en;nameText_es;typeUuid;typeUri;typeText_ca;typeText_en;typeText_es</xsl:text>

		<xsl:value-of select="$newline" />

		<xsl:for-each select="$json-xml/fn:map/fn:array[@key='items']/fn:map">

			<!-- Guardem uuid de l'activitat -->
			<xsl:variable name="thesisUuid" select="fn:string[@key='uuid']" />

			<!-- Recorrem les institucions de les tesis -->
			<xsl:for-each select="fn:array[@key='awardingInstitutions']/fn:map">

				<!-- Identificador de la tesi que hem guardat abans-->

				<xsl:value-of select="$thesisUuid"/>
				<xsl:value-of select="$separator" />
				<xsl:choose>
					<xsl:when test="fn:map[@key='organization']">
						<xsl:value-of select="fn:map[@key='organization']/fn:string[@key='uuid']"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="fn:map[@key='organization']/fn:string[@key='externalId']"/>
						<xsl:value-of select="$separator" />						
						<xsl:value-of select="uab:clean_ca_en_es(fn:map[@key='organization']/fn:map[@key='name'])"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="fn:map[@key='organization']/fn:map[@key='type']/fn:string[@key='pureId']"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="fn:map[@key='organization']/fn:map[@key='type']/fn:string[@key='uri']"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="uab:clean_ca_en_es(fn:map[@key='organization']/fn:map[@key='type']/fn:map[@key='term'])"/>
					</xsl:when>
					<xsl:when test="fn:map[@key='organizationRef']">
						<xsl:value-of select="fn:map[@key='organizationRef']/fn:string[@key='uuid']"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="fn:map[@key='organizationRef']/fn:string[@key='externalId']"/>
						<xsl:value-of select="$separator" />						
						<xsl:value-of select="uab:clean_ca_en_es(fn:map[@key='organizationRef']/fn:map[@key='name'])"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="fn:map[@key='organizationRef']/fn:map[@key='type']/fn:string[@key='pureId']"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="fn:map[@key='organizationRef']/fn:map[@key='type']/fn:string[@key='uri']"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="uab:clean_ca_en_es(fn:map[@key='organizationRef']/fn:map[@key='type']/fn:map[@key='term'])"/>
					</xsl:when>
					<xsl:when test="fn:map[@key='externalOrganization']">
						<xsl:value-of select="fn:map[@key='externalOrganization']/fn:string[@key='uuid']"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="fn:map[@key='externalOrganization']/fn:string[@key='externalId']"/>
						<xsl:value-of select="$separator" />						
						<xsl:value-of select="uab:clean_ca_en_es(fn:map[@key='externalOrganization']/fn:map[@key='name'])"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="fn:map[@key='externalOrganization']/fn:map[@key='type']/fn:string[@key='pureId']"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="fn:map[@key='externalOrganization']/fn:map[@key='type']/fn:string[@key='uri']"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="uab:clean_ca_en_es(fn:map[@key='externalOrganization']/fn:map[@key='type']/fn:map[@key='term'])"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="fn:map[@key='externalOrganizationRef']/fn:string[@key='uuid']"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="fn:map[@key='externalOrganizationRef']/fn:string[@key='externalId']"/>	
						<xsl:value-of select="$separator" />						
						<xsl:value-of select="uab:clean_ca_en_es(fn:map[@key='externalOrganizationRef']/fn:map[@key='name'])"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="fn:map[@key='externalOrganizationRef']/fn:map[@key='type']/fn:string[@key='pureId']"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="fn:map[@key='externalOrganizationRef']/fn:map[@key='type']/fn:string[@key='uri']"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="uab:clean_ca_en_es(fn:map[@key='externalOrganizationRef']/fn:map[@key='type']/fn:map[@key='term'])"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:value-of select="$newline" />
				
			</xsl:for-each>

		</xsl:for-each>

	</xsl:template> 
</xsl:stylesheet>