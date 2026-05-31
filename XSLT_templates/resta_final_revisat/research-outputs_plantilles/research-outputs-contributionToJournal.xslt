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
		<xsl:text>ctjUuid;ctjTitle;ctjTypePureId;ctjTypeUri;ctjType_ca_ES;ctjType_en_GB;ctjType_es_ES;ctjCategoyrPureId;ctjCategoryUri;ctjCategory_ca_ES;ctjCategory_en_GB;ctjCategory_es_ES;ctjPeerReview;ctjtotalNumberOfAuthors;pages;journalNumber;volume;ctjLanguage;ctjJounalTitle;ctjISSN;ctjJournalUuid;createdBy;createdDate</xsl:text>
		<xsl:value-of select="$newline" />
		<xsl:for-each select="$json-xml/fn:map/fn:array[@key='items']/fn:map[fn:string[@key='typeDiscriminator']='ContributionToJournal']">
			<xsl:value-of select="fn:string[@key='uuid']"/><xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean(fn:map[@key='title']/fn:string[@key='value'])"/><xsl:value-of select="$separator" />
			<xsl:value-of select="fn:map[@key='type']/fn:number[@key='pureId']"/><xsl:value-of select="$separator" />
			<xsl:value-of select="fn:map[@key='type']/fn:string[@key='uri']"/><xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean_ca_en_es(fn:map[@key='type']/fn:map[@key='term'])"/><xsl:value-of select="$separator" />
			<xsl:value-of select="fn:map[@key='category']/fn:number[@key='pureId']"/><xsl:value-of select="$separator" />
			<xsl:value-of select="fn:map[@key='category']/fn:string[@key='uri']"/><xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean_ca_en_es(fn:map[@key='category']/fn:map[@key='term'])"/><xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean(fn:boolean[@key='peerReview'])"/><xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean(fn:number[@key='totalNumberOfAuthors'])"/><xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean(fn:string[@key='pages'])"/><xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean(fn:string[@key='journalNumber'])"/><xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean(fn:string[@key='volume'])"/><xsl:value-of select="$separator" />
			<xsl:value-of select="fn:string[@key='language']"/><xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean(fn:map[@key='journalAssociation']/fn:map[@key='title']/fn:string[@key='value'])"/><xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean(fn:map[@key='journalAssociation']/fn:map[@key='issn']/fn:string[@key='value'])"/><xsl:value-of select="$separator" />
			<xsl:value-of select="fn:map[@key='journalAssociation']/fn:map[@key='journal']/fn:string[@key='uuid']"/><xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean(fn:string[@key='createdBy'])"/><xsl:value-of select="$separator" />
			<xsl:value-of select="fn:string[@key='createdDate']"/><xsl:value-of select="$newline" />
		</xsl:for-each>
	</xsl:template> 
</xsl:stylesheet>