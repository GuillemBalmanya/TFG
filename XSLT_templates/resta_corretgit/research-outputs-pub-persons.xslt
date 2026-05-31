<!-- Aquest xslt ens porta les persones de les publicacions-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:uab="http://www.uab.cat">

	<xsl:include href="functions.xslt"/>

	<xsl:output method="text" />

	<xsl:template match="/">
		<xsl:text>pubUuid;PersonUuid;personRoleUuid;personRoleUri;personRoleText_ca;personRoleText_en;personRoleText_es</xsl:text>

		<xsl:value-of select="$newline" />

		<xsl:for-each select="result/items/*">

			<!-- Guardem uuid de la publicacio -->
			<xsl:variable name="pubUuid" select="@uuid" />

			<!-- Recorrem les persones de les publicacions -->
			<xsl:for-each select="personAssociations/personAssociation">

				<!-- Identificador de la publicacio que hem guardat abans-->

				<xsl:value-of select="$pubUuid"/>
				<xsl:value-of select="$separator" />
				<xsl:choose>
					<xsl:when test="person">
						<xsl:value-of select="person/@uuid"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="externalPerson/@uuid"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:value-of select="$separator" />
				<xsl:value-of select="personRole/@pureId"/>
				<xsl:value-of select="$separator" />
				<xsl:value-of select="personRole/@uri"/>
				<xsl:value-of select="$separator" />
				<xsl:value-of select="uab:clean_ca_en_es(personRole/term/text)"/>
				<xsl:value-of select="$separator" />
				<xsl:value-of select="$newline" />
			</xsl:for-each>

		 </xsl:for-each>

	</xsl:template> 
</xsl:stylesheet>	

