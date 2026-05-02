<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:uab="http://www.uab.cat">

	<xsl:include href="functions.xslt"/>
	<xsl:output method="text" />

	<xsl:template match="/">    

		<xsl:text>uuid;fcFundingPureId; fcFunder_uuid;fcName_text_ca_ES;fcName_text_en_GB;fcName_text_es_ES;colType_term_text_ca_ES;colType_term_text_en_GB;colType_term_text_es_ES;fcInstitutionalPart</xsl:text>
		<xsl:value-of select="$newline" />
		
				
		

		<xsl:for-each select="result/items/award">
			<!-- Guardem uuid de l'application -->
			<xsl:variable name="awardUuid" select="@uuid" />

			<!-- Recorrem els fundings -->
			<xsl:for-each select="fundings/funding/fundingCollaborators/fundingCollaborator">

				<!-- Identificador sol·licitud que hem guardat abans-->
				<xsl:value-of select="$awardUuid"/>
				<xsl:value-of select="$separator" />
				
				<!-- pureId i externalId del funding -->
				<xsl:value-of select="@pureId"/>
				<xsl:value-of select="$separator"/>

				<!-- uuid del funder -->
				<xsl:value-of select="collaborator/@uuid"/>
				<xsl:value-of select="$separator"/>
				<xsl:value-of select="uab:clean_ca_en_es(collaborator/name/text)"/>
				<xsl:value-of select="$separator" />

				<!--tipus de funder  -->
				<xsl:value-of select="uab:clean_ca_en_es(collaborator/type/term/text)"/>
				<xsl:value-of select="$separator" />
				
				<!-- institutionalPart -->
				<xsl:value-of select="institutionalPart"/>
				<xsl:value-of select="$separator"/>
				
				<xsl:value-of select="$newline" /> 								

			</xsl:for-each>

		</xsl:for-each> 
	</xsl:template>  
</xsl:stylesheet>