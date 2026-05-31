<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:uab="http://www.uab.cat">

	<xsl:include href="functions.xslt"/>

	<xsl:output method="text" />

	<xsl:template match="/">    

		<xsl:text>uuid;externalId;typePureId;typeUri;typeText_ca_ES;typeText_en_GB;typeText_es_ES;tittleText_ca_ES;tittleText_en_GB;tittleText_es_ES;announcementUrl;awardCeiling; openingDate; deadline;pureId</xsl:text>

		<xsl:value-of select="$newline" />
		<xsl:for-each select="result/items/fundingOpportunity">
			<!-- Identificador únic de la convocatòria-->
			<xsl:value-of select = "@uuid"/>
			<xsl:value-of select = "$separator" />
			<xsl:value-of select = "@externalId"/>
			<xsl:value-of select = "$separator" />
			
			<!--Id tipus -->
			<xsl:value-of select="type/@pureId"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="type/@uri"/>
			<xsl:value-of select="$separator" />
	
			<!-- No caldria incloure descriptors perquè consten a classification-schemes, pero per aclarir la consulta de la taula els agafem -->
			<xsl:value-of select="uab:clean_ca_en_es(type/term/text)"/>
			<xsl:value-of select="$separator" />
			
			<!-- Títol de la convocatoria (ca;en;es) -->
			<xsl:value-of select="uab:clean_ca_en_es(title/text)"/>
			<xsl:value-of select="$separator" />  

			<!-- En taules relacionades: -->
			<!-- AssociatedIds -->
			<!-- fundingOrganisations -->
			<!-- Applications -->
			<!-- Keywordgroups -->
			
			<!-- URL de la convocatoria -->
			<xsl:value-of select="uab:clean(announcementUrl)"/>
			<xsl:value-of select="$separator" /> 
			
			
			<!-- import de la convocatoria -->
			<xsl:value-of select="awardCeiling"/>
			<xsl:value-of select="$separator" /> 			
					
			<!-- Dates -->
			<xsl:value-of select="openingDate"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="deadline"/>
			<xsl:value-of select="$separator" />
			
			<!-- PureID -->
			<xsl:value-of select="@pureId"/>
			<xsl:value-of select="$separator" />
			
			<xsl:value-of select="$newline" /> 	
		</xsl:for-each> 
	</xsl:template>  
</xsl:stylesheet>