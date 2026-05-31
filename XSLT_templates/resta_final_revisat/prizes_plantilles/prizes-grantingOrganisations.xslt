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

		<xsl:text>prizeUuid;OrganisationalUnitUuid;nameText_ca;nameText_en;nameText_es;typeUuid;typeUri;typeText_ca;typeText_en;typeText_es</xsl:text>

		<xsl:value-of select="$newline" />

		<xsl:for-each select="$json-xml/fn:map/fn:array[@key='items']/fn:map">

			<!-- Guardem uuid del prize -->
			<xsl:variable name="prizeUuid" select="fn:string[@key='uuid']" />

			<xsl:for-each select="fn:array[@key='grantingOrganizations']/fn:map">

				<xsl:value-of select="$prizeUuid"/>
				<xsl:value-of select="$separator" />
				<xsl:choose>
					<xsl:when test="fn:map[@key='organizationRef']">
						<xsl:value-of select="fn:map[@key='organizationRef']/fn:string[@key='uuid']"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="uab:clean_ca_en_es(fn:map[@key='organizationRef']/fn:map[@key='name'])"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="fn:map[@key='organizationRef']/fn:map[@key='type']/fn:number[@key='pureId']"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="fn:map[@key='organizationRef']/fn:map[@key='type']/fn:string[@key='uri']"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="uab:clean_ca_en_es(fn:map[@key='organizationRef']/fn:map[@key='type']/fn:map[@key='term'])"/>
						<xsl:value-of select="$separator" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="fn:map[@key='externalOrganizationRef']/fn:string[@key='uuid']"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="uab:clean_ca_en_es(fn:map[@key='externalOrganizationRef']/fn:map[@key='name'])"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="fn:map[@key='externalOrganizationRef']/fn:map[@key='type']/fn:number[@key='pureId']"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="fn:map[@key='externalOrganizationRef']/fn:map[@key='type']/fn:string[@key='uri']"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="uab:clean_ca_en_es(fn:map[@key='externalOrganizationRef']/fn:map[@key='type']/fn:map[@key='term'])"/>
						<xsl:value-of select="$separator" />
					</xsl:otherwise>
				</xsl:choose>
				<xsl:value-of select="$newline" />
				
			</xsl:for-each>

		</xsl:for-each>

	</xsl:template> 
</xsl:stylesheet>
