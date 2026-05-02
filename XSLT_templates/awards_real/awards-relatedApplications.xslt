<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:uab="http://www.uab.cat">

	<xsl:include href="functions.xslt"/>
	<xsl:output method="text" />

	<xsl:template match="/">    

		<xsl:text>uuid; text_ca_ES; text_en_GB; text_es_ES; relappUuid; relappExternalId; relapp_text_ca_ES; relapp_term_text_en_GB; relapp_term_text_es_ES; relappTyePureId; relappTypeUri; relapp_type_text_ca_ES; relapp_type_term_text_en_GB; relapp_type_term_text_es_ES</xsl:text>
		<xsl:value-of select="$newline" />

		
		
		<xsl:for-each select="result/items/award">
		
			<!-- Guardem uuid i titol de l'award -->
			<xsl:variable name="uuid" select="@uuid" />				
			<xsl:variable name="title" select="uab:clean_ca_en_es(title/text)"/>

			
			<!-- Recorrem les relatedApplications - sollicituds vinculades a l'ajut concedit -->	
			<xsl:for-each select="relatedApplications/relatedApplication">
			
				<!--identificador unic de l'ajut o conveni que hem guardat abans-->
				<xsl:value-of select="$uuid"/>
				<xsl:value-of select="$separator" />

				<!--Titol de l'ajut o conveni en cat ang i es que hem guardat abans-->				
				<xsl:value-of select="$title"/>
				<xsl:value-of select="$separator" />  

				<!--dades de les relatedApplications - sollicituds vinculades a l'ajut concedit-->
				<xsl:value-of select="@uuid"/>
				<xsl:value-of select="$separator" />
				<xsl:value-of select="@externalId"/>
				<xsl:value-of select="$separator" />
				<xsl:value-of select="uab:clean_ca_en_es(name/text)"/>
				<xsl:value-of select="$separator" />				
				<xsl:value-of select="type/@pureId"/>
				<xsl:value-of select="$separator" />
				<xsl:value-of select="type/@uri"/>
				<xsl:value-of select="$separator" />				
				<xsl:value-of select="uab:clean_ca_en_es(type/term/text)"/>
				
				<xsl:value-of select="$newline" />
				
			</xsl:for-each> 
			 
		</xsl:for-each> 
	</xsl:template>  
</xsl:stylesheet>