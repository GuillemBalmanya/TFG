<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:uab="http://www.uab.cat"
	exclude-result-prefixes="fn uab xs">

    <xsl:variable name="newline" select="'&#10;'"/>
    <xsl:variable name="separator" select="';'"/>

    <xsl:function name="uab:clean_ca_en_es" as="xs:string">
        <xsl:param name="map" as="element(fn:map)?"/>
        <xsl:sequence select="if ($map) then fn:string-join(($map/fn:string[@key='ca_ES'], $map/fn:string[@key='en_GB'], $map/fn:string[@key='es_ES']), '|') else ''"/>
    </xsl:function>

    <xsl:function name="uab:clean" as="xs:string">
        <xsl:param name="str" as="xs:string?"/>
        <xsl:sequence select="if ($str) then $str else ''"/>
    </xsl:function>
</xsl:stylesheet>
