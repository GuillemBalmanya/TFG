<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:uab="http://www.uab.cat">

	<!-- Variables globals -->
 	<xsl:variable name="separator" select="'&#59;'" />
	<xsl:variable name="newline" select="'&#10;'" /> 
	 <!-- Limita a N caràcters el substring de les funcions retalla i cutclean -->
	<xsl:variable name="numchars" select="255" />

	<!-- Esborra CR i LF, i canvia punt i coma per guió -->
	<xsl:function name="uab:clean">
		<xsl:param name="string"/>
		<xsl:value-of select="replace(replace($string,'(&#10;|&#13;)',''),'(&#59;)','-')"/>
	</xsl:function>
	
    <!-- Limita a N caràcters definits a la variable $numchars (al principi) el contingut que retorna -->
	<xsl:function name="uab:retalla">
		<xsl:param name="string"/>
		<xsl:value-of select="substring($string,1,$numchars)"/>
	</xsl:function>
	

	<!-- 
		FUNCIONS DE LOCALE PER JSON (json-to-xml)
		==========================================
		En JSON, les locales es representen com un fn:map amb claus ca_ES, en_GB, es_ES:
		  <fn:map key="title">
		    <fn:string key="ca_ES">Títol</fn:string>
		    <fn:string key="en_GB">Title</fn:string>
		    <fn:string key="es_ES">Título</fn:string>
		  </fn:map>
		
		Les funcions reben el fn:map (p.ex. fn:map[@key='title']) i naveguen
		amb fn:string[@key='ca_ES'] en lloc de l'antic $element[@locale='ca_ES'].
	-->

	<!-- Neteja el valor de l'element amb clau 'ca_ES' dins el fn:map -->
	<xsl:function name="uab:clean_ca">
		<xsl:param name="element"/>
		<xsl:value-of select="uab:clean($element/fn:string[@key='ca_ES'])"/>
	</xsl:function>

	<!-- Neteja i retalla el valor de l'element amb clau 'ca_ES' dins el fn:map -->
	<xsl:function name="uab:cutclean_ca">
		<xsl:param name="element"/>
		<xsl:value-of select="uab:clean(substring($element/fn:string[@key='ca_ES'],1,$numchars))"/>
	</xsl:function>

	<!-- Neteja el valor de l'element amb clau 'en_GB' dins el fn:map -->
	<xsl:function name="uab:clean_en">
		<xsl:param name="element"/>
		<xsl:value-of select="uab:clean($element/fn:string[@key='en_GB'])"/>
	</xsl:function>


	<!-- Neteja i retalla el valor de l'element amb clau 'en_GB' dins el fn:map -->
	<xsl:function name="uab:cutclean_en">
		<xsl:param name="element"/>
		<xsl:value-of select="uab:clean(substring($element/fn:string[@key='en_GB'],1,$numchars))"/>
	</xsl:function>

	<!-- Neteja el valor de l'element amb clau 'es_ES' dins el fn:map -->
	<xsl:function name="uab:clean_es">
		<xsl:param name="element"/>
		<xsl:value-of select="uab:clean($element/fn:string[@key='es_ES'])"/>
	</xsl:function>
	
	
	<!-- Neteja i retalla el valor de l'element amb clau 'es_ES' dins el fn:map -->
	<xsl:function name="uab:cutclean_es">
		<xsl:param name="element"/>
		<xsl:value-of select="uab:clean(substring($element/fn:string[@key='es_ES'],1,$numchars))"/>
	</xsl:function>
	
	<!-- OBSOLET OC20230531 Neteja els valors de l'element amb claus ca_ES, en_GB i es_ES i els torna separats per punt i coma -->
	<xsl:function name="uab:oldclean_ca_en_es">
		<xsl:param name="element"/>
		<xsl:value-of select="concat(uab:clean_ca($element), $separator, uab:clean_en($element), $separator, uab:clean_es($element))"/>
	</xsl:function>
	
	<!-- Neteja i retalla els valors de l'element amb claus ca_ES, en_GB i es_ES i els torna separats per punt i coma -->
	<xsl:function name="uab:clean_ca_en_es">
		<xsl:param name="element"/>
		<xsl:value-of select="concat(uab:cutclean_ca($element), $separator, uab:cutclean_en($element), $separator, uab:cutclean_es($element))"/>
	</xsl:function>
	

</xsl:stylesheet>
