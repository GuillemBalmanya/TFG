<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:uab="http://www.uab.cat">

	<xsl:include href="functions.xslt"/>

	<xsl:output method="text" />

	<xsl:template match="/">    

		<xsl:text>uuid;text_ca_ES;text_en_GB;text_es_ES;typePureId;typeUri;natureType_uri;fundingOpportunity_Uuid;fundingOpportunity_ExternalId;managingOrganisationalUnit_Uuid;managingOrganisationalUnit_ExternaId;idFenix;referenceCode;applicant_IP_uuid;awardedbyfunder;submittedtofunder;expectedPeriod_startDate;expectedPeriod_endDate;submissionDate;awardDate;totalAppliedAmount;funderReply</xsl:text>

		<xsl:value-of select="$newline" />
		<xsl:for-each select="result/items/application">
			<!-- Identificador únic de la sol·licitud-->
			<xsl:value-of select = "@uuid"/>
			<xsl:value-of select = "$separator" />

			<!-- Títol de la sol·licitud (ca;en;es) -->
			<xsl:value-of select="uab:clean_ca_en_es(title/text)"/>
			<xsl:value-of select="$separator" />  

			<!--Id tipus -->
			<!-- No inclou descriptors perquè consten a classification-schemes (és correcte?) -->
			<xsl:value-of select="type/@pureId"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="type/@uri"/>
			<xsl:value-of select="$separator" />			

			<!-- Nature type -->
			<!-- Atenció: a la documentació tenim application/natureType/@uri però natureType és dins d'application/natureTypes -->
			<xsl:value-of select="natureTypes/natureType/@uri"/>
			<xsl:value-of select="$separator" />
			

			<!--Id de la convocatòria -->
			<!-- Entenc que fa referència a l'Id que obtenim a funding-opportunities.csv -->
			<xsl:value-of select="fundingOpportunity/@uuid"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="fundingOpportunity/@externalId"/>
			<xsl:value-of select="$separator" />

			<!-- Id i nom de la unitat gestionadora de la sol·licitud -->
			<!-- Trec els noms en ca_en_es perquè entenc que haurien de ser a organisational-units.csv -->
			<xsl:value-of select="managingOrganisationalUnit/@uuid"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="managingOrganisationalUnit/@externalId"/>
			<xsl:value-of select="$separator" />
			
			<!-- Codi fènix -->
			
			<xsl:value-of select="ids/id/type[@uri='/dk/atira/pure/upm/classifiedsource/id_fenix']/../value"/>
			<xsl:value-of select="$separator" />			

			<!-- Codi oficial -->
			<!-- Atenció: a la documentació consta com a ids/id[type/@uri = '/dk/atira/pure/upm/classifiedsource/referencecode']/value/text() -->
			<xsl:value-of select="ids/id/type[@uri='/dk/atira/pure/upm/classifiedsource/referencecode']/../value"/>
			<xsl:value-of select="$separator" />
			
			

			<!-- Applicants. Agafem només l'IP . Primera linia de l'Albert comentada: agafaria el NIU, però volen el uuid-->
			<!--<xsl:value-of select="applicants/applicant/personRole[@uri='/dk/atira/pure/application/roles/application/pi']/../person/@externalId"/>-->
			<xsl:value-of select="applicants/applicant/personRole[@uri='/dk/atira/pure/application/roles/application/pi']/../person/@uuid"/>
			<xsl:value-of select="$separator" />
			
			<!-- En taules relacionades: -->
			<!-- Organisational units -->
			<!-- Fundings -->
			<!-- RelatedAwards -->

			<!-- Dates -->
			<xsl:value-of select="statuses/status/status[@uri='/dk/atira/pure/application/status/awardedbyfunder']/../date"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="statuses/status/status[@uri='/dk/atira/pure/application/status/submittedtofunder']/../date"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="expectedPeriod/startDate"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="expectedPeriod/endDate"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="submissionDate"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="awardDate"/>
			<xsl:value-of select="$separator" />			
			
			<!-- Quantitats -->
			<xsl:value-of select="totalAppliedAmount"/>
			<xsl:value-of select="$separator" />
			
			<!-- Resposta -->
			<xsl:value-of select="funderReply"/>

			<xsl:value-of select="$newline" /> 	
		</xsl:for-each> 
	</xsl:template>  
</xsl:stylesheet>