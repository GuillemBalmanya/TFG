<!-- Aquest xslt ens porta les institucions que han organitzat un event-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:uab="http://www.uab.cat">

	<xsl:include href="functions.xslt"/>

	<xsl:output method="text" />

	<xsl:template match="/">
		<xsl:text>eventUuid;organisationalUnitUuid;externalId;nameText_ca;nameText_en;nameText_es;typeUuid;typeUri;typeText_ca;typeText_en;typeText_es</xsl:text>

		<xsl:value-of select="$newline" />

		<xsl:for-each select="result/items/event">

			<!-- Guardem uuid de l'event -->
			<xsl:variable name="eventUuid" select="@uuid" />

			<!-- Recorrem les institucions dels events -->
			<xsl:for-each select="organisers/organiser">

				<!-- Identificador de l event que hem guardat abans-->

				<xsl:value-of select="$eventUuid"/>
				<xsl:value-of select="$separator" />
				<xsl:choose>
					<xsl:when test="organisationalUnit">
						<xsl:value-of select="organisationalUnit/@uuid"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="organisationalUnit/@externalId"/>
						<xsl:value-of select="$separator" />						
						<xsl:value-of select="uab:clean_ca_en_es(organisationalUnit/name/text)"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="organisationalUnit/type/@pureId"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="organisationalUnit/type/@uri"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="uab:clean_ca_en_es(organisationalUnit/type/term/text)"/>
						<xsl:value-of select="$separator" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="externalOrganisationalUnit/@uuid"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="externalOrganisationalUnit/@externalId"/>	
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

