<!-- Aquest xslt ens porta altres contribucions-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:uab="http://www.uab.cat">

	<xsl:include href="functions.xslt"/>

	<xsl:output method="text" />

	<xsl:template match="/">
		<xsl:text>patentUuid;TypePureId;TypeUri;Type_ca_ES;Type_en_GB;Type_es_ES;Title;ExtenalId;HostPublicationTitle;Edition;ISBN;CategoyrPureId;CategoryUri;Category_ca_ES;Category_en_GB;Category_es_ES;Language;PlaceOfPublication;Publisher;PublicationSerie;Volume;WorkflowStep;CreatedDate;CreatedBy</xsl:text>

		
		<xsl:value-of select="$newline" />
		
		<xsl:for-each select="result/items/patent">
			<!--ID_PUBLICACIO-->
		<xsl:value-of select="@uuid"/>
			<xsl:value-of select="$separator" />
			<!--ID_TIPUS_PUBLICACIO-->	
			<xsl:value-of select="type/@pureId"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="type/@uri"/>
			<xsl:value-of select="$separator" />			
			<xsl:value-of select="uab:clean_ca_en_es(type/term/text)"/>
			<xsl:value-of select="$separator" />
			<!--DS_PUBLICACIO-->
			<xsl:value-of select="uab:clean(title)"/>
			<xsl:value-of select="$separator" />
			<!--ID_LLIBRE-->
			<xsl:value-of select="@externalId"/>
			<xsl:value-of select="$separator" />	
			<!--DS_LLIBRE-->
			<xsl:value-of select="uab:clean(hostPublicationTitle)"/>
			<xsl:value-of select="$separator" />
			<!--DS_NOM_EDICIO-->
			<xsl:value-of select="uab:clean(edition)"/>
			<xsl:value-of select="$separator" />	
			<!--ID_ISBN-->
			<xsl:value-of select="isbns/isbn"/>
			<xsl:value-of select="$separator" />			
			<!--ID_TIPUS_LLIB_ART-->				
			<xsl:value-of select="category/@pureId"/>			
			<xsl:value-of select="$separator" />
			<xsl:value-of select="category/@uri"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean_ca_en_es(category/term/text)"/>
			<xsl:value-of select="$separator" />
			<!--ID_SUPORT no existeix-->
			<!--ID_IDIOMA-->	
			<xsl:value-of select="language"/>			
			<xsl:value-of select="$separator" />
			<!--ID_AMBIT no existeix-->	
			<!--ID_PAIS_EDIT no existeix-->	
			<!--ID_POBLACIO_EDICIO-->
			<xsl:value-of select="uab:clean(placeOfPublication)"/>			
			<xsl:value-of select="$separator" />
			<!--DS_NOM_EDITOR -1 -->
			<!--D_PUBLICACIO agafar-ho del xslt research-outputs-pub-status_oc.xslt-->
			<!--ID_NUM_EDICIONS no existeix-->
			<!--DS_EDITORIAL-->
			<xsl:value-of select="uab:clean(publisher/name/text)"/>			
			<xsl:value-of select="$separator" />	
			<!--DS_COLECCIO-->
			<xsl:value-of select="uab:clean(publicationSeries/publicationSerie/name)"/>			
			<xsl:value-of select="$separator" />				
			<!--ID_TIPUS_AUTOR  posar per defecte "P"-->
			<!--NUM_AUTORS no existeix, caldria fer count dels autors que trobarem a xslt research-outputs-pub-persons_oc.xslt-->
			<!--DS_NOM_AUTORS Concatenar separant amb ; els autors de xslt research-outputs-pub-persons_oc.xslt-->
			<!--SN_EDICIO_REVISADA deixar a -1 -->
			<!--ID_IDIOMA_ORIGINAL deixar a -1 -->
			<!--DS_EDITORIAL_ORIGINAL deixar a -1 -->
			<!--D_PUBLICACIO_ORIGINAL deixar a -1 -->
			<!--DS_CAPITOL_ORIGINAL deixar a -1 -->
			<!--ID_ALTRA_ACTIVITAT deixar a -1 -->
			<!--ID_ESTAT_PUBLICACIO deixar a -1 -->
			<!--DS_VOLUM-->
			<xsl:value-of select="uab:clean(volume)"/>
			<xsl:value-of select="$separator" />
			<!--DS_NUMERO deixar a -1 -->
			<!--ID_PROJECTE_REPORT deixar a -1 -->
			<!--DS_PROJECTE_REPORT deixar a -1 -->
			<!--SN_VALIDAT posar S si el valor es Validated-->
			<xsl:value-of select="workflow/@workflowStep"/>
			<xsl:value-of select="$separator" />
			<!--SN_AVALUAT  no existeix, per defecte N-->
			<!--IND_COUNT_PUBLICACIO posar 1 -->
			<!--DS_ANY_PUBLICACIO agafar-ho del xslt research-outputs-pub-status_oc.xslt-->
			<!--DS_ANY_PUBLICACIO_ORIGINAL deixar a -1-->
			<!--D_INTRODUCCIO-->
			<xsl:value-of select="info/createdDate"/>
			<xsl:value-of select="$separator" />	
			<!--DS_ANY_INTRODUCCIO fer substring de la data d'introduccio-->
			<!--ID_PERS_INTRODUCCIO-->
			<xsl:value-of select="uab:clean(info/createdBy)"/>
			<xsl:value-of select="$separator" />			
		
			<xsl:value-of select="$newline" />
		</xsl:for-each>
	
	</xsl:template> 
</xsl:stylesheet>	


