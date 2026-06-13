<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" />
    <xsl:variable name="separator" select="'&#59;'" />
    <xsl:variable name="newline" select="'&#10;'" /> 
    <xsl:template match = "/">        
	<xsl:text>uuid;employment_pureId;employment_uri;employment_ca_ES;employment_en_GB;organisationalUnit_uuid;organisationalUnit_externalId;organisationalUnit_name_ca_ES;organisationalUnit_name_en_GB;startDate;endDate;dedicaction_pureId;dedication_ca_ES;dedication_en_GB;area_coneix_pureId;area_coneix_ca_ES;area_coneix_en_GB;contractType_pureId;contractType_ca_ES;contractType_en_GB;staffType_pureId;staffType_ca_ES;staffType_en_GB</xsl:text>
        <xsl:value-of select="$newline" />
        <xsl:for-each select="result/items/person/staffOrganisationAssociations">
            <xsl:variable name="uuid" select="../@uuid" />
            <xsl:for-each select="staffOrganisationAssociation">
                <xsl:value-of select = "$uuid"/>
                <xsl:value-of select="$separator" />
				
				<!--Categoria laboral - employmentType-->
				
                <xsl:value-of select = "employmentType/@pureId"/>
                <xsl:value-of select="$separator" />
                <xsl:value-of select = "employmentType/@uri"/>				
                <xsl:value-of select="$separator" />
                <xsl:value-of select = "replace(replace(employmentType/term/text[@locale='ca_ES'],'(&#10;|&#13;)',''),'(&#59;)','-')"/>
                <xsl:value-of select="$separator" />
                <xsl:value-of select = "replace(replace(employmentType/term/text[@locale='en_GB'],'(&#10;|&#13;)',''),'(&#59;)','-')"/>
				 <xsl:value-of select="$separator" />
				 
				 <!--Estament - organisational-unit-->
				 
				 
                <xsl:value-of select = "organisationalUnit/@uuid"/>
                <xsl:value-of select="$separator" />
                <xsl:value-of select = "organisationalUnit/@externalId"/>
                <xsl:value-of select="$separator" />				
                <xsl:value-of select = "replace(replace(organisationalUnit/name/text[@locale='ca_ES'],'(&#10;|&#13;)',''),'(&#59;)','-')"/>
                <xsl:value-of select="$separator" />
                <xsl:value-of select = "replace(replace(organisationalUnit/name/text[@locale='en_GB'],'(&#10;|&#13;)',''),'(&#59;)','-')"/>
                <xsl:value-of select="$separator" />
				
				<!--Periode del contracte-->
				
                <xsl:value-of select = "period/startDate"/>
                <xsl:value-of select="$separator" />
                <xsl:value-of select = "period/endDate"/>
                <xsl:value-of select="$separator" />
				
				<!--Dedicacio-->
				
				<xsl:value-of select = "keywordGroups/keywordGroup[type/@uri='/uab/persons/staff/dedication']/keywordContainers/keywordContainer/structuredKeyword/@pureId"/>
                <xsl:value-of select="$separator" />				
				<xsl:value-of select = "replace(replace(keywordGroups/keywordGroup[type/@uri	='/uab/persons/staff/dedication']/keywordContainers/keywordContainer/structuredKeyword/term/text[@locale='ca_ES'],'(&#10;|&#13;)',''),'(&#59;)','-')"/>
				<xsl:value-of select="$separator" />
				<xsl:value-of select = "replace(replace(keywordGroups/keywordGroup[type/@uri	='/uab/persons/staff/dedication']/keywordContainers/keywordContainer/structuredKeyword/term/text[@locale='en_GB'],'(&#10;|&#13;)',''),'(&#59;)','-')"/>			
                <xsl:value-of select="$separator" />
				
				<!--Arees de coneixement-->
				
				<xsl:value-of select = "keywordGroups/keywordGroup[type/@uri='/uab/persons/area_coneix']/keywordContainers/keywordContainer/structuredKeyword/@pureId"/>
                <xsl:value-of select="$separator" />				
				<xsl:value-of select = "replace(replace(keywordGroups/keywordGroup[type/@uri	='/uab/persons/area_coneix']/keywordContainers/keywordContainer/structuredKeyword/term/text[@locale='ca_ES'],'(&#10;|&#13;)',''),'(&#59;)','-')"/>
				<xsl:value-of select="$separator" />
				<xsl:value-of select = "replace(replace(keywordGroups/keywordGroup[type/@uri	='/uab/persons/area_coneix']/keywordContainers/keywordContainer/structuredKeyword/term/text[@locale='en_GB'],'(&#10;|&#13;)',''),'(&#59;)','-')"/>	
				<xsl:value-of select="$separator" />
				
				<!--Tipus de contracte-->

                <xsl:value-of select = "contractType/@pureId"/>
                <xsl:value-of select="$separator" />				
                <xsl:value-of select = "replace(replace(contractType/term/text[@locale='ca_ES'],'(&#10;|&#13;)',''),'(&#59;)','-')"/>
                <xsl:value-of select="$separator" />
                <xsl:value-of select = "replace(replace(contractType/term/text[@locale='en_GB'],'(&#10;|&#13;)',''),'(&#59;)','-')"/>
                <xsl:value-of select="$separator" />				
				
				
				<!--Tipus de personal-->
				
                <xsl:value-of select = "staffType/@pureId"/>
                <xsl:value-of select="$separator" />				
                <xsl:value-of select = "replace(replace(staffType/term/text[@locale='ca_ES'],'(&#10;|&#13;)',''),'(&#59;)','-')"/>
                <xsl:value-of select="$separator" />
                <xsl:value-of select = "replace(replace(staffType/term/text[@locale='en_GB'],'(&#10;|&#13;)',''),'(&#59;)','-')"/>
                				
                <xsl:value-of select="$newline" />	
            </xsl:for-each>
        </xsl:for-each>
   </xsl:template> 
</xsl:stylesheet>