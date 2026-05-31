<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:uab="http://www.uab.cat"
	exclude-result-prefixes="fn uab xs">
	<xsl:include href="functions.xslt"/>
	<xsl:output method="text" />
	<xsl:param name="json-file" as="xs:string"/>
	<xsl:template match="/" name="xsl:initial-template">
		<xsl:variable name="json-text" select="unparsed-text($json-file)" />
		<xsl:variable name="json-xml" select="json-to-xml($json-text)" />
		<xsl:text>ocUuid;ocTypePureId;ocTypeUri;ocType_ca_ES;ocType_en_GB;ocType_es_ES;ocTitle;ocExtenalId;ocHostPublicationTitle;ocEdition;ocISBN;ocCategoyrPureId;ocCategoryUri;ocCategory_ca_ES;ocCategory_en_GB;ocCategory_es_ES;ocLanguage;ocPlaceOfPublication;ocPublisher;ocPublicationSerie;ocVolume;ocWorkflowStep;ocCreatedDate;ocCreatedBy</xsl:text>
		<xsl:value-of select="$newline" />
		<xsl:for-each select="$json-xml/fn:map/fn:array[@key='items']/fn:map[fn:string[@key='typeDiscriminator']='OtherContribution']">
			<xsl:value-of select="fn:string[@key='uuid']"/><xsl:value-of select="$separator" />
			<xsl:value-of select="fn:map[@key='type']/fn:number[@key='pureId']"/><xsl:value-of select="$separator" />
			<xsl:value-of select="fn:map[@key='type']/fn:string[@key='uri']"/><xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean_ca_en_es(fn:map[@key='type']/fn:map[@key='term'])"/><xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean(fn:map[@key='title']/fn:string[@key='value'])"/><xsl:value-of select="$separator" />
			<xsl:value-of select="fn:string[@key='externalId']"/><xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean(fn:string[@key='hostPublicationTitle'])"/><xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean(fn:string[@key='edition'])"/><xsl:value-of select="$separator" />
			<xsl:value-of select="fn:array[@key='isbns']/fn:map[1]/fn:string[@key='value']"/><xsl:value-of select="$separator" />
			<xsl:value-of select="fn:map[@key='category']/fn:number[@key='pureId']"/><xsl:value-of select="$separator" />
			<xsl:value-of select="fn:map[@key='category']/fn:string[@key='uri']"/><xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean_ca_en_es(fn:map[@key='category']/fn:map[@key='term'])"/><xsl:value-of select="$separator" />
			<xsl:value-of select="fn:string[@key='language']"/><xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean(fn:string[@key='placeOfPublication'])"/><xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean(fn:map[@key='publisher']/fn:map[@key='name']/fn:string[@key='text'])"/><xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean(fn:array[@key='publicationSeries']/fn:map[1]/fn:map[@key='publicationSerie']/fn:string[@key='name'])"/><xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean(fn:string[@key='volume'])"/><xsl:value-of select="$separator" />
			<xsl:value-of select="fn:map[@key='workflow']/fn:string[@key='workflowStep']"/><xsl:value-of select="$separator" />
			<xsl:value-of select="fn:string[@key='createdDate']"/><xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean(fn:string[@key='createdBy'])"/><xsl:value-of select="$newline" />
		</xsl:for-each>
	</xsl:template> 
</xsl:stylesheet>