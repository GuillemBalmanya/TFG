<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:uab="http://www.uab.cat">

	<xsl:include href="functions.xslt"/>

	<xsl:output method="text" />

	<xsl:template match="/">
		<xsl:text>uuid;baseUri;desc_ca_ES;containedClassification_pureId;containedClassification_uri;containedClassification_disabled;containedClassification_value_ca_ES;containedClassification_value_en_GB;containedClassification_value_es_ES;classificationRelation_relatedTo_pure_id;classificationRelation_relatedTo_uri;classificationRelation_relatedTo_value_ca_ES;classificationRelation_relatedTo_value_en_GB;classificationRelation_relatedTo_value_es_ES</xsl:text>
		<xsl:value-of select="$newline" />
		<xsl:for-each select="result/items/classificationScheme">
			<xsl:variable name="uuid" select="@uuid" />
			<xsl:variable name="baseUri" select="baseUri" />     
			<xsl:variable name="description" select="uab:clean_es(description/text)"/>
			<xsl:for-each select="containedClassifications/containedClassification">
				<xsl:value-of select="$uuid"/>
				<xsl:value-of select="$separator" />
				<xsl:value-of select="$baseUri"/>
				<xsl:value-of select="$separator" />
				<xsl:value-of select="$description"/>
				<xsl:value-of select="$separator" />					
				<xsl:value-of select="@pureId"/>
				<xsl:value-of select="$separator" />				
				<xsl:value-of select="@uri"/>
				<xsl:value-of select="$separator" />
				<xsl:value-of select="@disabled"/>				
				<xsl:value-of select="$separator" />
				<xsl:value-of select="uab:clean_ca_en_es(term/text)"/>
				<xsl:value-of select="$newline" />  
			</xsl:for-each>
		</xsl:for-each> 
	</xsl:template>  
</xsl:stylesheet>