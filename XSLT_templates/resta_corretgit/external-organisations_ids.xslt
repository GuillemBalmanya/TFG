<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:uab="http://www.uab.cat">

	<xsl:include href="functions.xslt"/>

	<xsl:output method="text" />

	<xsl:template match="/">    

	
        <xsl:text>id;text_ca_ES;text_en_GB;text_es_ES;id_pureId;id_value;idType_ca_ES;idType_en_GB;idType_es_ES</xsl:text>
        <xsl:value-of select="$newline" />
        <xsl:for-each select="result/items/externalOrganisation/ids">
                
			<!--identificador unic de l'entitat-->				
				<xsl:value-of select = "../@uuid"/>
                <xsl:value-of select="$separator" />
				
			<!--nom de l'entitat en cat, ang i fr-->
			
			    <xsl:value-of select="uab:clean_ca_en_es(../name/text)"/>
				<xsl:value-of select="$separator" />
				
			<!--id-->				
                <xsl:value-of select = "id/@pureId"/>
                <xsl:value-of select="$separator" />
				<xsl:value-of select = "id/value"/>
                <xsl:value-of select="$separator" />
				
			<!--tipus d'id en cat, ang i fr-->
		
				<xsl:value-of select="uab:clean_ca_en_es(id/type/term/text)"/>
				<xsl:value-of select="$separator" />
		    	<xsl:value-of select="$newline" />					
			
				
        </xsl:for-each>
   </xsl:template> 
</xsl:stylesheet>