<!-- Versió JSON: llegeix dades de fitxer JSON via json-to-xml() -->
<!-- Template RAO2: quasi idèntic a RAO, amb lògica diferent de justificació econòmica -->
<!-- 20250704 correció OC de la Justificació econòmica -->

<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:uab="http://www.uab.cat"
	exclude-result-prefixes="fn uab xs">

	<xsl:include href="functions.xslt" />

	<xsl:output method="text" />

	<xsl:param name="json-file" as="xs:string"/>

	<xsl:template match="/">

		<xsl:variable name="json-text" select="unparsed-text($json-file)" />
		<xsl:variable name="json-xml" select="json-to-xml($json-text)" />

		<xsl:text>uuid;text_ca_ES;text_en_GB;text_es_ES;typePureId;typeUri;type_term_text_ca_ES;type_term_text_en_GB;type_term_text_es_ES;managingOrganisationalUnit_Uuid;managingOrganisationalUnit_ExternaId;MOU_name_text_ca_ES;MOU_name_text_en_GB;MOU_name_text_es_ES;SN_collaborative;totalAwardedAmount;totalSpendAmount;actualPeriodStartDate;actualPeriodEndtDate;expectedPeriodStartDate;expectedPeriodEndtDate;awardDate;estatId;internallyApprovedDate;relinquished;relinquishmentDate;relinquishmentReason;declined;declinationDate;declinedReason;sn_aCarrecId;sn_aCarrec_term_text_ca_ES;sn_aCarrec_term_text_en_GB;sn_aCarrec_term_text_es_ES;workflow;pureId;natureTypePureId;natureTypeUri;natureType_term_text_ca_ES;natureType_term_text_en_GB;natureType_term_text_es_ES;createdDate;mofifiedDate;recompte; Justificacio</xsl:text>

		<!-- Guardem count dels awards -->
		<xsl:variable name="recompte" select="$json-xml/fn:map/fn:number[@key='count']" />
		<xsl:value-of
			select="$newline" />
		<xsl:for-each select="$json-xml/fn:map/fn:array[@key='items']/fn:map">
			<!--identificador
			unic de l'ajut o conveni-->
			<xsl:value-of
				select="fn:string[@key='uuid']" />
			<xsl:value-of select="$separator" />


			<!--Titol
			de l'ajut o conveni en cat, ang i fr-->
			<xsl:value-of
				select="uab:clean_ca_en_es(fn:map[@key='title'])" />
			<xsl:value-of select="$separator" />

			<!--Id
			i tipus (ajut o conveni) en cat ang i fr-->
			<xsl:value-of
				select="fn:map[@key='type']/fn:number[@key='pureId']" />
			<xsl:value-of select="$separator" />
			<xsl:value-of
				select="fn:map[@key='type']/fn:string[@key='uri']" />
			<xsl:value-of select="$separator" />
			<xsl:value-of
				select="uab:clean_ca_en_es(fn:map[@key='type']/fn:map[@key='term'])" />
			<xsl:value-of select="$separator" />

			<!--Id
			i nom de la unitat gestionadora de l'ajut o conveni en cat, angl i fr-->
			<xsl:value-of
				select="fn:map[@key='managingOrganisationalUnit']/fn:string[@key='uuid']" />
			<xsl:value-of select="$separator" />
			<xsl:value-of
				select="fn:map[@key='managingOrganisationalUnit']/fn:string[@key='externalId']" />
			<xsl:value-of select="$separator" />
			<xsl:value-of
				select="uab:clean_ca_en_es(fn:map[@key='managingOrganisationalUnit']/fn:map[@key='name'])" />
			<xsl:value-of
				select="$separator" />

			<!--Colaboratiu
			veritable o fals  designa si un ajut o conveni es coordinat-->
			<xsl:value-of select="fn:boolean[@key='collaborative']" />
			<xsl:value-of
				select="$separator" />

			<!--Imports
			el primer es fa servir per l'import global. Pot anar canviant-->
			<xsl:value-of select="fn:string[@key='totalAwardedAmount']" />
			<xsl:value-of
				select="$separator" />
			<xsl:value-of select="fn:string[@key='totalSpendAmount']" />
			<xsl:value-of
				select="$separator" />

			<!--Periodes-->

			<xsl:value-of select="fn:map[@key='actualPeriod']/fn:string[@key='startDate']" />
			<xsl:value-of
				select="$separator" />
			<xsl:value-of select="fn:map[@key='actualPeriod']/fn:string[@key='endDate']" />
			<xsl:value-of
				select="$separator" />
			<xsl:value-of select="fn:map[@key='expectedPeriod']/fn:string[@key='startDate']" />
			<xsl:value-of
				select="$separator" />
			<xsl:value-of select="fn:map[@key='expectedPeriod']/fn:string[@key='endDate']" />
			<xsl:value-of
				select="$separator" />
			<xsl:value-of select="fn:string[@key='awardDate']" />
			<xsl:value-of
				select="$separator" />

			<!--estat-->

			<xsl:value-of select="fn:map[@key='statusDetails']/fn:map[@key='status']/fn:string[@key='key']" />
			<xsl:value-of
				select="$separator" />
			<xsl:value-of select="fn:map[@key='statusDetails']/fn:string[@key='internallyApprovedDate']" />
			<xsl:value-of
				select="$separator" />
			<xsl:value-of select="fn:map[@key='statusDetails']/fn:boolean[@key='relinquished']" />
			<xsl:value-of
				select="$separator" />
			<xsl:value-of select="fn:map[@key='statusDetails']/fn:string[@key='relinquishmentDate']" />
			<xsl:value-of
				select="$separator" />
			<xsl:value-of
				select="uab:clean(fn:map[@key='statusDetails']/fn:string[@key='relinquishmentReason'])" />
			<xsl:value-of
				select="$separator" />
			<xsl:value-of select="uab:clean(fn:map[@key='statusDetails']/fn:boolean[@key='declined'])" />
			<xsl:value-of
				select="$separator" />
			<xsl:value-of select="fn:map[@key='statusDetails']/fn:string[@key='declinationDate']" />
			<xsl:value-of
				select="$separator" />
			<xsl:value-of select="uab:clean(fn:map[@key='statusDetails']/fn:string[@key='declinedReason'])" />
			<xsl:value-of
				select="$separator" />

			<!--tipus
			representacio-->
			<xsl:value-of
				select="uab:clean(fn:array[@key='keywordGroups']/fn:map[fn:string[@key='logicalName']='/uab/awards/a_carrec']/fn:array[@key='keywordContainers']/fn:map/fn:map[@key='structuredKeyword']/fn:number[@key='pureId'])" />
			<xsl:value-of
				select="$separator" />
			<xsl:value-of
				select="uab:clean_ca_en_es(fn:array[@key='keywordGroups']/fn:map[fn:string[@key='logicalName']='/uab/awards/a_carrec']/fn:array[@key='keywordContainers']/fn:map/fn:map[@key='structuredKeyword']/fn:map[@key='term'])" />

			<!--workflow
			(ifcagr)-->
			<xsl:value-of
				select="$separator" />
			<xsl:value-of select="fn:map[@key='workflow']/fn:string[@key='step']" />

			<!--identificador
			unic de l'ajut o conveni-->
			<xsl:value-of
				select="$separator" />
			<xsl:value-of select="fn:number[@key='pureId']" />

			<!--Id
			natureType (ajut o conveni) en cat ang i fr-->
			<xsl:value-of
				select="$separator" />
			<xsl:value-of select="fn:map[@key='natureType']/fn:number[@key='pureId']" />
			<xsl:value-of
				select="$separator" />
			<xsl:value-of select="fn:map[@key='natureType']/fn:string[@key='uri']" />
			<xsl:value-of
				select="$separator" />
			<xsl:value-of
				select="uab:clean_ca_en_es(fn:map[@key='natureType']/fn:map[@key='term'])" />
			<xsl:value-of
				select="$separator" />
			<xsl:value-of select="fn:string[@key='createdDate']" />
			<xsl:value-of
				select="$separator" />
			<xsl:value-of select="fn:string[@key='modifiedDate']" />
			<xsl:value-of
				select="$separator" />

			<!--recompte
			d'awards que hem guardat abans-->
			<xsl:value-of select="$recompte" />
			<xsl:value-of
				select="$separator" />

			<!-- 20250704 correció OC de la Justificació econòmica en funció de si es conveni o projecte.
			     No carrega convenis correctament.
			     Lògica: si existeix keywordGroup justificacio_economica, comprovar si és /si o /no.
			     Si no existeix, comprovar classificacio_ajut amb pureId 31912012. -->
			<xsl:choose>
				<xsl:when
					test="fn:array[@key='keywordGroups']/fn:map[fn:string[@key='logicalName']='/uab/awards/justificacio_economica']">
					<xsl:choose>
						<xsl:when
							test="fn:array[@key='keywordGroups']/fn:map[fn:string[@key='logicalName']='/uab/awards/justificacio_economica']/fn:array[@key='keywordContainers']/fn:map/fn:map[@key='structuredKeyword'][fn:string[@key='uri']='/uab/awards/justificacio_economica/si']">
							<xsl:text>S</xsl:text>
						</xsl:when>
						<xsl:when
							test="fn:array[@key='keywordGroups']/fn:map[fn:string[@key='logicalName']='/uab/awards/justificacio_economica']/fn:array[@key='keywordContainers']/fn:map/fn:map[@key='structuredKeyword'][fn:string[@key='uri']='/uab/awards/justificacio_economica/no']">
							<xsl:text>N</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>N</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when
					test="fn:array[@key='keywordGroups']/fn:map[fn:string[@key='logicalName']='/uab/awards/classificacio_ajut']/fn:array[@key='keywordContainers']/fn:map/fn:map[@key='structuredKeyword']/fn:number[@key='pureId'] = 31912012">
					<xsl:text>S</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>N</xsl:text>
				</xsl:otherwise>
			</xsl:choose>

			<!-- 20250704 Justificació econòmica -->

			<xsl:value-of
				select="$separator" />
			<xsl:value-of
				select="$newline" />

		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
