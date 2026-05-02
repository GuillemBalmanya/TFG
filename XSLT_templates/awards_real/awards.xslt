<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:uab="http://www.uab.cat">

	<xsl:include href="functions.xslt" />

	<xsl:output method="text" />

	<xsl:template match="/">

		<xsl:text>uuid;text_ca_ES;text_en_GB;text_es_ES;typePureId;typeUri;type_term_text_ca_ES;type_term_text_en_GB;type_term_text_es_ES;managingOrganisationalUnit_Uuid;managingOrganisationalUnit_ExternaId;MOU_name_text_ca_ES;MOU_name_text_en_GB;MOU_name_text_es_ES;SN_collaborative;totalAwardedAmount;totalSpendAmount;actualPeriodStartDate;actualPeriodEndtDate;expectedPeriodStartDate;expectedPeriodEndtDate;awardDate;estatId;internallyApprovedDate;relinquished;relinquishmentDate;relinquishmentReason;declined;declinationDate;declinedReason;sn_aCarrecId;sn_aCarrec_term_text_ca_ES;sn_aCarrec_term_text_en_GB;sn_aCarrec_term_text_es_ES;workflow;pureId;natureTypePureId;natureTypeUri;natureType_term_text_ca_ES;natureType_term_text_en_GB;natureType_term_text_es_ES;recompte;justificacioEconomica</xsl:text>
		<!-- Guardem count dels awards -->
		<xsl:variable name="recompte" select="result/count" />	
		<xsl:value-of
			select="$newline" />
		<xsl:for-each select="result/items/award">
			<!--identificador
			unic de l'ajut o conveni-->
			<xsl:value-of
				select="@uuid" />
			<xsl:value-of select="$separator" />


			<!--Titol
			de l'ajut o conveni en cat, ang i fr-->
			<xsl:value-of
				select="uab:clean_ca_en_es(title/text)" />
			<xsl:value-of select="$separator" />

			<!--Id
			it tipus (ajut o conveni) en cat ang i fr-->
			<xsl:value-of
				select="type/@pureId" />
			<xsl:value-of select="$separator" />
			<xsl:value-of
				select="type/@uri" />
			<xsl:value-of select="$separator" />			
			<xsl:value-of
				select="uab:clean_ca_en_es(type/term/text)" />	
			<xsl:value-of select="$separator" />

			<!--Id
			i nom de la unitat gestionadora de l'ajut o conveni en cat, angl i fr-->
			<xsl:value-of
				select="managingOrganisationalUnit/@uuid" />
			<xsl:value-of select="$separator" />
			<xsl:value-of
				select="managingOrganisationalUnit/@externalId" />
			<xsl:value-of select="$separator" />
			<xsl:value-of
				select="uab:clean_ca_en_es(managingOrganisationalUnit/name/text)" />		
			<xsl:value-of
				select="$separator" />

			<!--Colaboratiu
			veritable o fals  designa si un ajut o conveni es coordinat-->
			<xsl:value-of select="collaborative" />
			<xsl:value-of
				select="$separator" />

			<!--Imports
			el primer es fa servir per l'import global. Pot anar canviant-->
			<xsl:value-of select="totalAwardedAmount" />	
			<xsl:value-of
				select="$separator" />
			<xsl:value-of select="totalSpendAmount" />
			<xsl:value-of
				select="$separator" />

			<!--Periodes-->

			<xsl:value-of select="actualPeriod/startDate" />
			<xsl:value-of
				select="$separator" />
			<xsl:value-of select="actualPeriod/endDate" />
			<xsl:value-of
				select="$separator" />	
			<xsl:value-of select="expectedPeriod/startDate" />
			<xsl:value-of
				select="$separator" />
			<xsl:value-of select="expectedPeriod/endDate" />			
			<xsl:value-of
				select="$separator" />
			<xsl:value-of select="awardDate" />	
			<xsl:value-of
				select="$separator" />

			<!--estat-->

			<!--<xsl:value-of
			select="keywordGroups/keywordGroup
			[@logicalName='/uab/awards/estat_ajut']/keywordContainers/keywordContainer/structuredKeyword/@pureId"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean_ca_en_es(keywordGroups/keywordGroup
			[@logicalName='/uab/awards/estat_ajut']/keywordContainers/keywordContainer/structuredKeyword/term/text)"/>
			<xsl:value-of select="$separator" /> -->
			
                                               <xsl:value-of select="statusDetails/status/@key" />
                                               <xsl:value-of
				select="$separator" />
                                               <xsl:value-of select="statusDetails/internallyApprovedDate" />
                                               <xsl:value-of
				select="$separator" />
                                               <xsl:value-of select="statusDetails/relinquished" />
                                               <xsl:value-of
				select="$separator" />
                                               <xsl:value-of select="statusDetails/relinquishmentDate" />
                                               <xsl:value-of
				select="$separator" />
                                               <xsl:value-of
				select="uab:clean(statusDetails/relinquishmentReason)" />	
                                               <xsl:value-of
				select="$separator" />
                                               <xsl:value-of select="uab:clean(statusDetails/declined)" />
                                               <xsl:value-of
				select="$separator" />
                                               <xsl:value-of select="statusDetails/declinationDate" />
                                               <xsl:value-of
				select="$separator" />
                                               <xsl:value-of select="uab:clean(statusDetails/declinedReason)" />
                                               <xsl:value-of
				select="$separator" />


			<!--tipus
			representacio-->
			
			<xsl:value-of
				select="uab:clean(keywordGroups/keywordGroup [@logicalName='/uab/awards/a_carrec']/keywordContainers/keywordContainer/structuredKeyword/@pureId)" />
			<xsl:value-of
				select="$separator" />
			<xsl:value-of
				select="uab:clean_ca_en_es(keywordGroups/keywordGroup [@logicalName='/uab/awards/a_carrec']/keywordContainers/keywordContainer/structuredKeyword/term/text)" />

			<!--workflow
			(ifcagr)-->
			<xsl:value-of
				select="$separator" />
			<xsl:value-of select="workflow/@workflowStep" />

			<!--identificador
			unic de l'ajut o conveni (afegim al final per poder fer comparatives amb llistat AGR que
			tenen pureId-->
			<xsl:value-of
				select="$separator" />
			<xsl:value-of select="@pureId" />

			<!--Id
			natureType (ajut o conveni) en cat ang i fr-->
			<xsl:value-of
				select="$separator" />
			<xsl:value-of select="natureType/@pureId" />
			<xsl:value-of
				select="$separator" />
			<xsl:value-of select="natureType/@uri" />
			<xsl:value-of
				select="$separator" />			
			<xsl:value-of
				select="uab:clean_ca_en_es(natureType/term/text)" />	
			<xsl:value-of
				select="$separator" />
			<!--recvompte
			d'awards que hem guardat abans-->
			<xsl:value-of select="$recompte" />
			<xsl:value-of
				select="$separator" />
				
			<!-- 20250528 Juastificació econòmica en funció de si es conveni o projecte-->
			<!--<xsl:choose>
			<xsl:when
								test="keywordGroups/keywordGroup[@logicalName='/uab/awards/justificacio_economica']">
			<xsl:text>S</xsl:text>
			</xsl:when>
			<xsl:when
								test="keywordGroups/keywordGroup[@logicalName='/uab/awards/classificacio_ajut']/keywordContainers/keywordContainer/structuredKeyword/@pureId = '31912012'">
			<xsl:text>S</xsl:text>
			</xsl:when>
			<xsl:otherwise>
			<xsl:text>N</xsl:text>
			</xsl:otherwise>
			</xsl:choose>-->
			<!-- 20250528 Juastificació econòmica en funció de si es conveni o projecte-->			
			 
			<!-- 20250704 correció OC de la Justificació econòmica en funció de si es conveni o projecte. No carrega convenis correctament-->
			<xsl:choose>
			<xsl:when test="keywordGroups/keywordGroup[@logicalName='/uab/awards/justificacio_economica']">
			<xsl:choose>
			<xsl:when test="keywordGroups/keywordGroup[@logicalName='/uab/awards/justificacio_economica']/keywordContainers/keywordContainer/structuredKeyword[@uri='/uab/awards/justificacio_economica/si']">
			<xsl:text>S</xsl:text>
			</xsl:when>
			<xsl:when test="keywordGroups/keywordGroup[@logicalName='/uab/awards/justificacio_economica']/keywordContainers/keywordContainer/structuredKeyword[@uri='/uab/awards/justificacio_economica/no']">
			<xsl:text>N</xsl:text>
			</xsl:when>
			<xsl:otherwise>
			<xsl:text>N</xsl:text>
			</xsl:otherwise>
			</xsl:choose>
			</xsl:when>
			<xsl:when test="keywordGroups/keywordGroup[@logicalName='/uab/awards/classificacio_ajut']/keywordContainers/keywordContainer/structuredKeyword/@pureId = '31912012'">
			<xsl:text>S</xsl:text>
			</xsl:when>
			<xsl:otherwise>
			<xsl:text>N</xsl:text>
			</xsl:otherwise>
			</xsl:choose>
 

			<xsl:value-of
				select="$separator" />

			<xsl:value-of select="$newline" />
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>