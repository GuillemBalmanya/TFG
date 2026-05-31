<!-- Aquest xslt ens porta les persones en activitats-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:uab="http://www.uab.cat">

	<xsl:include href="functions.xslt"/>

	<xsl:output method="text" />

	<xsl:template match="/">
		<xsl:text>prizeUuid;OrganisationalUnitUuid;nameText_ca;nameText_en;nameText_es;typeUuid;typeUri;typeText_ca;typeText_en;typeText_es</xsl:text>

		<xsl:value-of select="$newline" />

		<xsl:for-each select="result/items/prize">

			<!-- Guardem uuid de l'activitat -->
			<xsl:variable name="prizeUuid" select="@uuid" />

			<!-- Recorrem les persones de les activitats -->
			<xsl:for-each select="grantingOrganisations/grantingOrganisation">

				<!-- Identificador de l'activitat que hem guardat abans-->

				<xsl:value-of select="$prizeUuid"/>
				<xsl:value-of select="$separator" />
				<xsl:choose>
					<xsl:when test="OrganisationalUnit">
						<xsl:value-of select="OrganisationalUnit/@uuid"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="uab:clean_ca_en_es(OrganisationalUnit/name/text)"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="OrganisationalUnit/type/@pureId"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="OrganisationalUnit/type/@uri"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="uab:clean_ca_en_es(OrganisationalUnit/type/term/text)"/>
						<xsl:value-of select="$separator" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="externalOrganisationalUnit/@uuid"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="uab:clean_ca_en_es(externalOrganisationalUnit/name/text)"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="externalOrganisationalUnit/type/@pureId"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="externalOrganisationalUnit/type/@uri"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="uab:clean_ca_en_es(externalOrganisationalUnit/type/term/text)"/>
						<xsl:value-of select="$separator" />
					</xsl:otherwise>
				</xsl:choose>
				<xsl:value-of select="$newline" />
				
			</xsl:for-each>

		</xsl:for-each>

	</xsl:template> 
</xsl:stylesheet>	

