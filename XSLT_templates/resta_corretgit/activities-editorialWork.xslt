<!--Aquest xslt ens porta les activitats de tipus otherActivity (altres activitarts etc) codi EXP. Cal relacionar-la amb activities-persons
Al DATA es troba a la DT_COLABORACIO-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:uab="http://www.uab.cat">

	<xsl:include href="functions.xslt"/>

	<xsl:output method="text" />

	<xsl:template match="/">
		<xsl:text>membershipyUuid;externalId;typePureId;typeUri;typeText_ca;typeText_en;typeText_es;titleText_ca;titleText_en;titleText_es;descriptionText_ca;descriptionText_en;descriptionText_es;startDateYear;startDateMonth;startDateDay;endtDateYear;endtDateMonth;endtDateDay;degreeOfRecognitionPureId;degreeOfRecognitionUri;degreeOfRecognitionText_ca;degreeOfRecognitionText_en;degreeOfRecognitionText_es;workflowStep;createdBy;createdDate;event</xsl:text>
		
		<xsl:value-of select="$newline" />
		<xsl:for-each select="result/items/editorialWork">
			<xsl:value-of select="@uuid"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="@externalId"/>
			<xsl:value-of select="$separator" />
<!-- tipus de colaboracio-->	
			<xsl:value-of select="type/@pureId"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="type/@uri"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean_ca_en_es(type/term/text)"/>
			<xsl:value-of select="$separator" />			
			<xsl:value-of select="uab:clean_ca_en_es(title/text)"/>
			<xsl:value-of select="$separator" />	
			<xsl:value-of select="uab:clean_ca_en_es(descriptions/description/value/text)"/>
			<xsl:value-of select="$separator" />			
<!-- periode-->			
			<xsl:value-of select="period/startDate/year"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="period/startDate/month"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="period/startDate/day"/>
			<xsl:value-of select="$separator" />				
			<xsl:value-of select="period/endDate/year"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="period/endDate/month"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="period/endDate/day"/>
			<xsl:value-of select="$separator" />		
<!-- tipus de participacio i persones la trobarem al xslt personAssociations-->	
<!-- ambit-->	
			<xsl:value-of select="degreeOfRecognition/@pureId"/>			
			<xsl:value-of select="$separator" />
			<xsl:value-of select="degreeOfRecognition/@uri"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean_ca_en_es(degreeOfRecognition/term/text)"/>
			<xsl:value-of select="$separator" />	
<!-- validacio-->
			<xsl:value-of select="workflow/@workflowStep"/>
			<xsl:value-of select="$separator" />

<!-- info creacio-->				
			<xsl:value-of select="uab:clean(info/createdBy)"/>
			<xsl:value-of select="$separator" />			
			<xsl:value-of select="info/createdDate"/>
			<xsl:value-of select="$separator" />
<!-- event al que s'assisteix-->
			<xsl:value-of select="event/@uuid"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="$newline" />
		</xsl:for-each>
	</xsl:template> 
</xsl:stylesheet>	

