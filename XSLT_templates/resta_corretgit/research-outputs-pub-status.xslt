<!-- Aquest xslt ens porta l'estat de publicacio dels articles en revistes-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:uab="http://www.uab.cat">

	<xsl:include href="functions.xslt"/>

	<xsl:output method="text" />

	<xsl:template match="/">
		<xsl:text>pubUuid;publicationStatusPureId;publicationStatusUri;publicationStatus_ca_ES;publicationStatus_en_GB;publicationStatus_es_ES;publicationDateYear;publicationDateMonth;publicationDateDay</xsl:text>
		
		<xsl:value-of select="$newline" />
		
		<xsl:for-each select="result/items/*">
		
			<!-- Guardem uuid de la publicacio -->
			<xsl:variable name="pubUuid" select="@uuid" />

				<!-- Recorrem es publication-statuses de la publicacio-->
				<xsl:for-each select="publicationStatuses">
						
					<!-- Identificador de la ctj que hem guardat abans-->
					
					<xsl:value-of select="$pubUuid"/>
					<xsl:value-of select="$separator" />
					<xsl:value-of select="publicationStatus/publicationStatus/@pureId"/>
					<xsl:value-of select="$separator" />
					<xsl:value-of select="publicationStatus/publicationStatus/@uri"/>
					<xsl:value-of select="$separator" />	
					<xsl:value-of select="uab:clean_ca_en_es(publicationStatus/publicationStatus/term/text)"/>
					<xsl:value-of select="$separator" />					
					<xsl:value-of select="publicationStatus/publicationDate/year"/>
					<xsl:value-of select="$separator" />	
					<xsl:value-of select="publicationStatus/publicationDate/month"/>
					<xsl:value-of select="$separator" />
					<xsl:value-of select="publicationStatus/publicationDate/day"/>
					<xsl:value-of select="$separator" />					
					<xsl:value-of select="$newline" />
				</xsl:for-each>
			
		</xsl:for-each>
	
	</xsl:template> 
</xsl:stylesheet>	

