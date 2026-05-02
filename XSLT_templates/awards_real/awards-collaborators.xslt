<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:uab="http://www.uab.cat">

	<xsl:include href="functions.xslt"/>
	<xsl:output method="text" />

	<xsl:template match="/">    

		<xsl:text>awardUuid;awardText_ca_ES;awardText_en_GB;awardText_es_ES;colPureId;colTypePureId;colType_term_text_ca_ES;colType_term_text_en_GB;colType_term_text_es_ES;leadCollaborator;orgUuid;org_name_ca_ES;org_name_en_GB;org_name_es_ES;orgTypePureId;org_type_ca_ES;org_type_en_GB;org_type_es_ES</xsl:text>
		<xsl:value-of select="$newline" />
		
		<xsl:for-each select="result/items/award">
		
			<!-- Guardem uuid i titol de l'award -->
			<xsl:variable name="uuid" select="@uuid" />				
			<xsl:variable name="title" select="uab:clean_ca_en_es(title/text)"/>

			
			<!-- Recorrem els award collaborators -->	
			<xsl:for-each select="collaborators/collaborator">
				<!--identificador unic de l'ajut o conveni que hem guardat abans-->
				<xsl:value-of select="$uuid"/>
				<xsl:value-of select="$separator" />

				<!--Titol de l'ajut o conveni en cat ang i es que hem guardat abans-->
				
				<xsl:value-of select="$title"/>
				<xsl:value-of select="$separator" />  
				
				<!--dades dels collaborators (entitats que participen i rol que fan al projecte)-->
				<xsl:value-of select="@pureId"/>
				<xsl:value-of select="$separator" />	
				<xsl:value-of select="type/@pureId"/>
				<xsl:value-of select="$separator" />				
				<xsl:value-of select="uab:clean_ca_en_es(type/term/text)"/>
				<xsl:value-of select="$separator" />
				<xsl:value-of select="leadCollaborator"/>
				<xsl:value-of select="$separator" />
				
				<xsl:choose>
					<xsl:when test="organisationalUnit">
						<xsl:value-of select="organisationalUnit/@uuid"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="uab:clean_ca_en_es(organisationalUnit/name/text)"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="organisationalUnit/type/@pureId"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="uab:clean_ca_en_es(organisationalUnit/type/term/text)"/>
						<xsl:value-of select="$separator" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="externalOrganisation/@uuid"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="uab:clean_ca_en_es(externalOrganisation/name/text)"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="externalOrganisation/type/@pureId"/>
						<xsl:value-of select="$separator" />
						<xsl:value-of select="uab:clean_ca_en_es(externalOrganisation/type/term/text)"/>
						<xsl:value-of select="$separator" />
					</xsl:otherwise>
				</xsl:choose>
				
				
				
				
				

				<!--dades dels collaborators (entitats que participen i rol que fan al projecte)
				<xsl:value-of select="@pureId"/>
				<xsl:value-of select="$separator" />	
				<xsl:value-of select="type/@pureId"/>
				<xsl:value-of select="$separator" />				
				<xsl:value-of select="uab:clean_ca_en_es(type/term/text)"/>
				<xsl:value-of select="$separator" />
				<xsl:value-of select="leadCollaborator"/>
				<xsl:value-of select="$separator" />
				<xsl:value-of select="externalOrganisation/@uuid"/>
				<xsl:value-of select="$separator" />
				<xsl:value-of select="uab:clean_ca_en_es(externalOrganisation/name/text)"/>
				<xsl:value-of select="$separator" />	
				<xsl:value-of select="externalOrganisation/type/@pureId"/>
				<xsl:value-of select="$separator" />				
				<xsl:value-of select="uab:clean_ca_en_es(externalOrganisation/type/term/text)"/>	-->			
				<xsl:value-of select="$newline" />
				
			</xsl:for-each> 
			 
		</xsl:for-each> 
	</xsl:template>  
</xsl:stylesheet>