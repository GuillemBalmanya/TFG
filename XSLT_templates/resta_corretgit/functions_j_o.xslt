<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:uab="http://www.uab.cat">

    <!-- Variables globals -->
    <xsl:variable name="separator" select="';'"/>
    <xsl:variable name="newline" select="'&#10;'"/> 
    <xsl:variable name="numchars" select="255"/>

    <!-- Neteja genèrica: elimina saltos de línia i punts i comes -->
    <xsl:function name="uab:clean">
        <xsl:param name="string" as="xs:string?"/>
        <xsl:sequence select="if (exists($string)) then replace(replace(normalize-space($string), '[\r\n]', ''), ';', '-') else ''"/>
    </xsl:function>

    <!-- Trunca una cadena a $numchars caràcters -->
    <xsl:function name="uab:retalla">
        <xsl:param name="string" as="xs:string?"/>
        <xsl:sequence select="substring($string, 1, $numchars)"/>
    </xsl:function>

    <!-- Accés per idioma: ca_ES -->
    <xsl:function name="uab:clean_ca">
        <xsl:param name="map" as="map(*)?"/>
        <xsl:sequence select="uab:clean($map?ca_ES)"/>
    </xsl:function>

    <xsl:function name="uab:cutclean_ca">
        <xsl:param name="map" as="map(*)?"/>
        <xsl:sequence select="uab:clean(substring($map?ca_ES, 1, $numchars))"/>
    </xsl:function>

    <!-- Accés per idioma: en_GB -->
    <xsl:function name="uab:clean_en">
        <xsl:param name="map" as="map(*)?"/>
        <xsl:sequence select="uab:clean($map?en_GB)"/>
    </xsl:function>

    <xsl:function name="uab:cutclean_en">
        <xsl:param name="map" as="map(*)?"/>
        <xsl:sequence select="uab:clean(substring($map?en_GB, 1, $numchars))"/>
    </xsl:function>

    <!-- Accés per idioma: es_ES -->
    <xsl:function name="uab:clean_es">
        <xsl:param name="map" as="map(*)?"/>
        <xsl:sequence select="uab:clean($map?es_ES)"/>
    </xsl:function>

    <xsl:function name="uab:cutclean_es">
        <xsl:param name="map" as="map(*)?"/>
        <xsl:sequence select="uab:clean(substring($map?es_ES, 1, $numchars))"/>
    </xsl:function>

    <!-- Agrupació per idiomes: ca, en, es -->
    <xsl:function name="uab:clean_ca_en_es">
        <xsl:param name="map" as="map(*)?"/>
        <xsl:sequence select="concat(uab:cutclean_ca($map), $separator, uab:cutclean_en($map), $separator, uab:cutclean_es($map))"/>
    </xsl:function>

</xsl:stylesheet>
