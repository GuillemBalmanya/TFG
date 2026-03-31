<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:uab="http://www.uab.cat"
	exclude-result-prefixes="fn uab">

	<xsl:include href="functions.xslt"/>

	<xsl:output method="text" />

	<!-- 
		Parametre extern: ruta al fitxer JSON.
		S'ha de passar per linia de comandes:
		  java -jar saxon9he.jar -s:xslt/awards/ok/json/dummy.xml 
		       -xsl:xslt/awards/ok/json/awards_oc_recompte.xslt 
		       -o:csv/awards/awards_recompte.csv 
		       json-file=xml/awards_test.json
		       
		IMPORTANT: La ruta del json-file es relativa al directori 
		des d'on s'executa la comanda (normalment la carpeta SAXON).
	-->
	<xsl:param name="json-file" as="xs:string" xmlns:xs="http://www.w3.org/2001/XMLSchema"/>

	<xsl:template match="/">

		<!-- 1. Llegim el contingut del fitxer JSON com a text -->
		<xsl:variable name="json-text" select="unparsed-text($json-file)" />

		<!-- 2. Convertim el JSON a una representacio XML (namespace fn:) 
		     Estructura resultant:
		       <fn:map>
		         <fn:number key="count">43196</fn:number>
		         <fn:map key="pageInformation">...</fn:map>
		         <fn:array key="items">...</fn:array>
		       </fn:map>
		-->
		<xsl:variable name="json-xml" select="json-to-xml($json-text)" />

		<!-- Capçalera CSV (mateixa que l'original) -->
		<xsl:text>recompte_count;recompte_variable</xsl:text>
		<xsl:value-of select="$newline" />

		<!-- 3. Naveguem l'estructura XML generada per json-to-xml() -->
		<xsl:for-each select="$json-xml/fn:map">

			<!-- Guardem count dels awards -->
			<xsl:variable name="recompte" select="fn:number[@key='count']" />
			<xsl:value-of select="$newline" />
			<!--recompte d'awards que hem guardat abans-->
			<xsl:value-of select="fn:number[@key='count']"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="$recompte"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="$newline" />
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
