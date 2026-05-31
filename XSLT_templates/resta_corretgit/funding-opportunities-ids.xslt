<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:uab="http://www.uab.cat">

	<xsl:include href="functions.xslt"/>
	<xsl:output method="text" />

	<xsl:template match="/">    

		<xsl:text>uuid;externalId;text_ca_ES;text_en_GB;text_es_ES;idPureId;idExternalId;name;typePureId;TypeUri;Type_term_text_ca_ES;Type_term_text_en_GB;Type_term_text_es_ES</xsl:text>
		<xsl:value-of select="$newline" />

		
		
		<xsl:for-each select="result/items/fundingOpportunity">
		
			<!-- Guardem uuid i titol de la convocatoria -->
			<xsl:variable name="uuid" select="@uuid" />				
			<xsl:variable name="externalId"  select = "@externalId"/>
			<xsl:variable name="title" select="uab:clean_ca_en_es(title/text)"/>

			
			<!-- Recorrem els ids de les convocatories -->	
			<xsl:for-each select="associatedIds/associatedId">
				<!--identificador unic de la convocatoria que hem guardat abans-->
				<xsl:value-of select="$uuid"/>
				<xsl:value-of select="$separator" />
				<xsl:value-of select="$externalId"/>
				<xsl:value-of select="$separator" />				

				<!--Titol de la convocatoria en cat ang i es que hem guardat abans-->
				
				<xsl:value-of select="$title"/>
				<xsl:value-of select="$separator" />  

				<!--Id it tipus de oonvocatoria en cat ang i fr-->
				<xsl:value-of select="@pureId"/>
				<xsl:value-of select="$separator" />
				<xsl:value-of select="uab:clean(@externalId)"/>
				<xsl:value-of select="$separator" />
				<xsl:value-of select="uab:clean(value)"/>
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