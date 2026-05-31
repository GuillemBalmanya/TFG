<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="text" />
    <xsl:variable name="separator" select="'&#59;'" />
    <xsl:variable name="newline" select="'&#10;'" />
	
    <xsl:template match = "/">        
	<xsl:text>uuid;baseUri;desc_ca_ES;containedClassification_pureId;containedClassification_uri;containedClassification_value_ca_ES;containedClassification_value_en_GB;containedClassification_value_es_ES;classificatnRelation_relatedTo_pure_id;classificationRelation_relatedTo_uri;classificationRelation_relatedTo_value_ca_ES;classificationRelation_relatedTo_value_en_GB;classificationRelation_relatedTo_value_es_ES;classRel_relationType_pure_id;lassRel_relationType_uri;classRel_relationType_value_ca_ES;classRel_relationType_value_en_GB;classRel_relationType_value_es_ES	</xsl:text>
        <xsl:value-of select="$newline" />
        <xsl:for-each select="result/items/classificationScheme">
                <xsl:variable name="uuid" select="@uuid" />
                <xsl:variable name="baseUri" select="baseUri" />     
                <xsl:variable name="description" select="replace(replace(description/text[@locale='es_ES'],'(&#10;|&#13;)',''),'(&#59;)','-')"/>
                <xsl:for-each select="containedClassifications/containedClassification/classificationRelations/classificationRelation">
<!--identificador unic del programa  amb fills o sense-->				
                    <xsl:value-of select = "$uuid"/>
                    <xsl:value-of select = "$separator" />
					<xsl:value-of select = "$baseUri"/>
					<xsl:value-of select = "$separator" />
					<xsl:value-of select = "$description"/>
					<xsl:value-of select = "$separator" />	
					
<!--identificador unic del programa  pare-->

					<xsl:value-of select = "../../@pureId"/>	
					<xsl:value-of select = "$separator" />
					<xsl:value-of select = "replace(replace(../../@uri,'(&#10;|&#13;)',''),'(&#59;)','-')"/>
					<!--	<xsl:value-of select = "../../@uri"/>-->
					<xsl:value-of select = "$separator" />
					<xsl:value-of select = "../../replace(replace(../../term/text[@locale='ca_ES'],'(&#10;|&#13;)',''),'(&#59;)','-')"/>
					<xsl:value-of select = "$separator" />
					<xsl:value-of select = "replace(replace(../../term/text[@locale='en_GB'],'(&#10;|&#13;)',''),'(&#59;)','-')"/>
					<xsl:value-of select = "$separator" />
					<xsl:value-of select = "replace(replace(../../term/text[@locale='es_ES'],'(&#10;|&#13;)',''),'(&#59;)','-')"/>
					<xsl:value-of select = "$separator" />					
			
<!--identificador unic del programa  fill-->					
					<xsl:value-of select = "relatedTo/@pureId"/>	
					<xsl:value-of select = "$separator" />
					<xsl:value-of select = "relatedTo/@uri"/>
					<xsl:value-of select = "$separator" />
					<xsl:value-of select = "replace(replace(relatedTo/term/text[@locale='ca_ES'],'(&#10;|&#13;)',''),'(&#59;)','-')"/>
					<xsl:value-of select = "$separator" />
					<xsl:value-of select = "replace(replace(relatedTo/term/text[@locale='en_GB'],'(&#10;|&#13;)',''),'(&#59;)','-')"/>
					<xsl:value-of select = "$separator" />
					<xsl:value-of select = "replace(replace(relatedTo/term/text[@locale='es_ES'],'(&#10;|&#13;)',''),'(&#59;)','-')"/>
					<xsl:value-of select = "$separator" />
					
<!--identificador del tipus de relacio (fill)-->						
					<xsl:value-of select = "relationType/@pureId"/>
					<xsl:value-of select = "$separator" />
					<xsl:value-of select = "relationType/@uri"/>
					<xsl:value-of select = "$separator" />
					<xsl:value-of select = "replace(replace(relationType/term/text[@locale='ca_ES'],'(&#10;|&#13;)',''),'(&#59;)','-')"/>
					<xsl:value-of select = "$separator" />
					<xsl:value-of select = "replace(replace(relationType/term/text[@locale='en_GB'],'(&#10;|&#13;)',''),'(&#59;)','-')"/>
					<xsl:value-of select = "$separator" />
					<xsl:value-of select = "replace(replace(relationType/term/text[@locale='es_ES'],'(&#10;|&#13;)',''),'(&#59;)','-')"/>	
					<xsl:value-of select = "$newline" />				
                </xsl:for-each>
        </xsl:for-each> 
   </xsl:template>  
</xsl:stylesheet>