<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:uab="http://www.uab.cat">

	<!-- Variables globals -->
 	<xsl:variable name="separator" select="'&#59;'" />
	<xsl:variable name="newline" select="'&#10;'" /> 
	 <!-- Limita a N caràcters el substring de les funcions retalla i cutclean -->
	<xsl:variable name="numchars" select="255" />

	<!-- Esborra CR i LF, i canvia punt i coma per guió -->
	<xsl:function name="uab:clean">
		<xsl:param name="string"/>
		<!-- <xsl:value-of select="replace(replace($string,'(&#10;|&#13;)',''),'(&#59;)','-')"/> 20230601 EPS i OC-->
		<xsl:value-of select="substring(replace(replace($string,'(&#10;|&#13;)',''),'(&#59;)','-'), 1, $numchars)"/>
	</xsl:function>
	
    <!-- Limita a N caràcters definits a la variable $numchars (al principi) el contingut que retorna -->
<xsl:function name="uab:retalla">

		<xsl:param name="string"/>
		<xsl:value-of select="substring($string,1,$numchars)"/>
	</xsl:function>
	

	<!-- Neteja el valor de l'element amb atribut locale='ca_ES' -->
	<xsl:function name="uab:clean_ca">
		<xsl:param name="element"/>
		<xsl:value-of select="uab:clean($element[@locale='ca_ES'])"/>
	</xsl:function>

	<!-- Neteja i retalla el valor de l'element amb atribut locale='ca_ES' -->
	<xsl:function name="uab:cutclean_ca">
		<xsl:param name="element"/>
		<xsl:value-of select="uab:clean(substring($element[@locale='ca_ES'],1,$numchars))"/>
	</xsl:function>

	<!-- Neteja el valor de l'element amb atribut locale='en_GB' -->
	<xsl:function name="uab:clean_en">
		<xsl:param name="element"/>
		<xsl:value-of select="uab:clean($element[@locale='en_GB'])"/>
	</xsl:function>


	<!-- Neteja i retalla el valor de l'element amb atribut locale='en_GB' -->
	<xsl:function name="uab:cutclean_en">
		<xsl:param name="element"/>
		<xsl:value-of select="uab:clean(substring($element[@locale='en_GB'],1,$numchars))"/>
	</xsl:function>

	<!-- Neteja el valor de l'element amb atribut locale='es_ES' -->
	<xsl:function name="uab:clean_es">
		<xsl:param name="element"/>
		<xsl:value-of select="uab:clean($element[@locale='es_ES'])"/>
	</xsl:function>
	
	
	<!-- Neteja i retalla el valor de l'element amb atribut locale='es_ES' -->
	<xsl:function name="uab:cutclean_es">
		<xsl:param name="element"/>
		<xsl:value-of select="uab:clean(substring($element[@locale='es_ES'],1,$numchars))"/>
	</xsl:function>
	

	<!-- OBSOLET OC20230531 Neteja els valors de l'element amb atribut locale='ca_ES', locale='en_GB' i locale='es_ES' i els torna separats per punt i coma -->
	<xsl:function name="uab:oldclean_ca_en_es">
		<xsl:param name="element"/>
		<xsl:value-of select="concat(uab:clean_ca($element), $separator, uab:clean_en($element), $separator, uab:clean_es($element))"/>
	</xsl:function>
	
		<!-- Neteja i retalla els valors de l'element amb atribut locale='ca_ES', locale='en_GB' i locale='es_ES' i els torna separats per punt i coma -->
	<xsl:function name="uab:clean_ca_en_es">
		<xsl:param name="element"/>
		<xsl:value-of select="concat(uab:cutclean_ca($element), $separator, uab:cutclean_en($element), $separator, uab:cutclean_es($element))"/>
	</xsl:function>
	

</xsl:stylesheet>