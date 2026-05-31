<!-- Aquest xslt ens porta els articles en revistes-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:uab="http://www.uab.cat">

	<xsl:include href="functions.xslt"/>

	<xsl:output method="text" />

	<xsl:template match="/">
		<xsl:text>ctjUuid;ctjTitle;ctjTypePureId;ctjTypeUri;ctjType_ca_ES;ctjType_en_GB;ctjType_es_ES;ctjCategoyrPureId;ctjCategoryUri;ctjCategory_ca_ES;ctjCategory_en_GB;ctjCategory_es_ES;ctjPeerReview;ctjtotalNumberOfAuthors;pages;journalNumber;volume;ctjLanguage;ctjJounalTitle;ctjISSN;ctjJournalUuid;createdBy;createdDate</xsl:text>
		
		<xsl:value-of select="$newline" />
		
		<xsl:for-each select="result/items/contributionToJournal">
			<xsl:value-of select="@uuid"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean(title)"/>
			<xsl:value-of select="$separator" />			
			<xsl:value-of select="type/@pureId"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="type/@uri"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean_ca_en_es(type/term/text)"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="category/@pureId"/>			
			<xsl:value-of select="$separator" />
			<xsl:value-of select="category/@uri"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean_ca_en_es(category/term/text)"/>
			<xsl:value-of select="$separator" />	
<!-- desenvolupar publicationStatuses i personAssociations-->			
			<xsl:value-of select="uab:clean(peerReview)"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean(totalNumberOfAuthors)"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean(pages)"/>
			<xsl:value-of select="$separator" />	
			<xsl:value-of select="uab:clean(journalNumber)"/>			
			<xsl:value-of select="$separator" />	
			<xsl:value-of select="uab:clean(volume)"/>
			<xsl:value-of select="$separator" />			
			<xsl:value-of select="language"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean(journalAssociation/title)"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean(journalAssociation/issn)"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="journalAssociation/journal/@uuid"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean(info/createdBy)"/>
			<xsl:value-of select="$separator" />			
			<xsl:value-of select="info/createdDate"/>
			<xsl:value-of select="$separator" />					
		
			<xsl:value-of select="$newline" />
		</xsl:for-each>
	
	</xsl:template> 
</xsl:stylesheet>	

