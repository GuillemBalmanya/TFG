<!-- Aquest xslt ens porta les unitats organitatives (departaments, facultats, centres etc. No resol totes les necessitats de la LK_ESTAMENT. Cal relacionar-la amb 
organisational-units-keywords i organisational-units-parents-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:uab="http://www.uab.cat">

	<xsl:include href="functions.xslt"/>

	<xsl:output method="text" />

	<xsl:template match="/">
		<xsl:text>uuid;externalId;name_ca_ES;name_en_GB;name_es_ES;type_pureId;type_ca_ES;organisationid;fenix_code;nif;startDate;endDate;ambit_coneixPureId;ambit_coneix_term_text_ca_ES;ambit_coneix_term_text_en_GB;ambit_coneix_term_text_es_ES
</xsl:text>
		<xsl:value-of select="$newline" />
		<xsl:for-each select="result/items/organisationalUnit">
			<xsl:value-of select="@uuid"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="@externalId"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean_ca_en_es(name/text)"/>
			<xsl:value-of select="$separator" />	
			<xsl:value-of select="type/@pureId"/>
			<xsl:value-of select="$separator" />	
			<xsl:value-of select="uab:clean_ca(type/term/text)"/>
			<xsl:value-of select="$separator" />					
			<!--
			<xsl:for-each select="ids/id">
				<xsl:if test="type/@pureId = 176">
					<xsl:value-of select = "value" />
				</xsl:if>
			</xsl:for-each>
			<xsl:value-of select = "$separator" />
-->
			<xsl:value-of select="ids/id/type[@pureId=176]/../value"/>
			<xsl:value-of select="$separator" />

			<xsl:for-each select="ids/id">
				<xsl:if test="type/@pureId = 6541596">
					<xsl:value-of select="value" />
				</xsl:if>
			</xsl:for-each>
			
			<xsl:value-of select="$separator" />
			<xsl:for-each select="ids/id">
				<xsl:if test="type/@pureId=1700964">
					<xsl:value-of select="value" />
				</xsl:if>
			</xsl:for-each>
			
			<xsl:value-of select="$separator" />	
			<xsl:value-of select="period/startDate"/>					
			<xsl:value-of select="$separator" />	
			<xsl:value-of select="period/endDate"/>	
			<xsl:value-of select="$separator" />			
						
			<!--ambit-->
			
			<xsl:value-of select="keywordGroups/keywordGroup [@logicalName='/uab/organisations/ambit_coneix']/keywordContainers/keywordContainer/structuredKeyword/@pureId"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean_ca_en_es(keywordGroups/keywordGroup [@logicalName='/uab/organisations/ambit_coneix']/keywordContainers/keywordContainer/structuredKeyword/term/text)"/>
			<xsl:value-of select="$newline" />

		</xsl:for-each>
	</xsl:template> 
</xsl:stylesheet>	

