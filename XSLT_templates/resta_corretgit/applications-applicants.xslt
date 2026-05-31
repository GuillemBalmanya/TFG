<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:uab="http://www.uab.cat">

	<xsl:include href="functions.xslt"/>
	<xsl:output method="text" />

	<xsl:template match="/">    

		<xsl:text>uuid;externalId;text_ca_ES;text_en_GB;text_es_ES;appUuid;externalAppUuid;externalAppTypePureId;appExternalId;externalAppExternalId;appFirstName;appLastName;appRolePureId; appRoleUri; appRole_term_text_ca_ES;appRole_term_text_en_GB;appRole_term_text_es_ES</xsl:text>
		<xsl:value-of select="$newline" />

		
		
		<xsl:for-each select="result/items/application">
		
			<!-- Guardem uuid i titol de la sol·licitud -->
			<xsl:variable name="uuid" select="@uuid" />				
			<xsl:variable name="externalId" select="@externalId" />	
			<xsl:variable name="title" select="uab:clean_ca_en_es(title/text)"/>

			
			<!-- Recorrem els applicants -->	
			<xsl:for-each select="applicants/applicant">
				<!--identificador unic de la sol·licitud q<ue hem guardat abans-->
				<xsl:value-of select="$uuid"/>
				<xsl:value-of select="$separator" />
				<xsl:value-of select="$externalId"/>
				<xsl:value-of select="$separator" />

				<!--Titol de la sol·licitud en cat ang i es que hem guardat abans-->
				
				<xsl:value-of select="$title"/>
				<xsl:value-of select="$separator" />  

				<!--dades dels holders (membres de l'equip)-->
				<xsl:value-of select="person/@uuid"/>
				<xsl:value-of select="$separator" />
				<xsl:value-of select="externalPerson/@uuid"/>
				<xsl:value-of select="$separator" />	
				<xsl:value-of select="externalPerson/type/@pureId"/>
				<xsl:value-of select="$separator" />				
				<xsl:value-of select="person/@externalId"/>
				<xsl:value-of select="$separator" />
				<xsl:value-of select="externalPerson/@externalId"/>
				<xsl:value-of select="$separator" />				
				<xsl:value-of select="uab:clean(name/firstName)"/>
				<xsl:value-of select="$separator" />				
				<xsl:value-of select="uab:clean(name/lastName)"/>
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