<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:uab="http://www.uab.cat" version="1.0">
<xsl:include href="functions.xslt"/>
<xsl:output method="text"/>
<xsl:template match="/">
<xsl:text>id;pureId;text_ca_ES;text_en_GB;text_es_ES;type_pureId;type_ca_ES;type_en_GB;type_es_ES;natureType_pureId;natureType_ca_ES;natureType_en_GB;natureType_es_ES;caracter_pureId;caracter_ca_ES;caracter_en_GB;caracter_es_ES;Address;Postal_code;city;country_pureId;country_ca_ES;country_en_GB;country_es_ES;ou_pureid;id_egreta_uo</xsl:text>
<xsl:value-of select="$newline"/>
<xsl:for-each select="result/items/externalOrganisation">
<!-- identificador unic de l'entitat -->
<xsl:value-of select="@uuid"/>
<xsl:value-of select="$separator"/>
<!-- identificador unic de l'entitat -->
<xsl:value-of select="@pureId"/>
<xsl:value-of select="$separator"/>
<!-- nom de l'entitat en cat, ang i fr -->
<xsl:value-of select="uab:clean_ca_en_es(name/text)"/>
<xsl:value-of select="$separator"/>
<!-- tipus de l'entitat -->
<xsl:value-of select="type/@pureId"/>
<xsl:value-of select="$separator"/>
<!-- tipus de l'entitat en cat, ang i fr -->
<xsl:value-of select="uab:clean_ca_en_es(type/term/text)"/>
<xsl:value-of select="$separator"/>
<!-- naturalesa de l'entitat -->
<xsl:value-of select="natureTypes/natureType/@pureId"/>
<xsl:value-of select="$separator"/>
<!-- naturalesa de l'entitat en cat, ang i fr -->
<xsl:value-of select="uab:clean_ca_en_es(natureTypes/natureType/term/text)"/>
<xsl:value-of select="$separator"/>
<!-- caracter de l'entitat -->
<xsl:value-of select="keywordGroups/keywordGroup[@logicalName='/uab/externalorganisations/caracter']/keywordContainers/keywordContainer/structuredKeyword/@pureId"/>
<xsl:value-of select="$separator"/>
<!-- caracter de l'entitat en cat, ang i fr -->
<xsl:value-of select="uab:clean_ca_en_es(keywordGroups/keywordGroup[@logicalName='/uab/externalorganisations/caracter']/keywordContainers/keywordContainer/structuredKeyword/term/text)"/>
<xsl:value-of select="$separator"/>
<!-- poblacio de l'entitat -->
<xsl:value-of select="address/address1"/>
<xsl:value-of select="$separator"/>
<!-- poblacio de l'entitat -->
<xsl:value-of select="address/postalCode"/>
<xsl:value-of select="$separator"/>
<!-- codi postal de l'entitat -->
<xsl:value-of select="address/city"/>
<xsl:value-of select="$separator"/>
<!-- codi pais de l'entitat -->
<xsl:value-of select="address/country/@pureId"/>
<xsl:value-of select="$separator"/>
<!-- pais de l'entitat en cat, ang i fr -->
<xsl:value-of select="uab:clean_ca_en_es(address/country/term/text)"/>
<xsl:value-of select="$separator"/>
<!-- id_egreta_uo -->
<xsl:value-of select="ids/id[type/term/text[@locale='ca_ES' and .='ID EGRETA UO']]/@pureId"/>
<xsl:value-of select="$separator"/>
<xsl:value-of select="$newline"/>
</xsl:for-each>
</xsl:template>
</xsl:stylesheet>