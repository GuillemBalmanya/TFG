<!-- Aquest xslt ens porta les tesis, tant les dirigides com les propies que els investigadors han posat a EGRETA-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:uab="http://www.uab.cat">

	<xsl:include href="functions.xslt"/>

	<xsl:output method="text" />


	<xsl:template match="/">
		<xsl:text>studentThesisUuid;externalId;typePureId;typeUri;typeText_ca;typeText_en;typeText_es;titleText;language_ca;language_en;language_es;awardDateYear;awardDateMonth;awardDateDay;degreeOfRecognitionPureId;degreeOfRecognitionUri;degreeOfRecognitionText_ca;degreeOfRecognitionText_en;degreeOfRecognitionText_es;workflowStep;createdBy;createdDate</xsl:text>
		
		<xsl:value-of select="$newline" />
		<xsl:for-each select="result/items/studentThesis">
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
			<xsl:value-of select="uab:clean(title)"/>
			<xsl:value-of select="$separator" />	
			<xsl:value-of select="uab:clean_ca_en_es(language/term/text)"/>
			<xsl:value-of select="$separator" />	
<!-- data de la tesi-->			
			<xsl:value-of select="awardDate/year"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="awardDate/month"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="awardDate/day"/>
			<xsl:value-of select="$separator" />		
<!-- Els directors de tesis els trobarem a al xslt thesisSupervisors-->
<!-- Les persones la trobarem al xslt thesisPersonsAssociations-->	
<!-- ambit-->	
			<xsl:value-of select="degreeOfRecognition/@pureId"/>			
			<xsl:value-of select="$separator" />
			<xsl:value-of select="degreeOfRecognition/@uri"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean_ca_en_es(degreeOfRecognition/term/text)"/>
			<xsl:value-of select="$separator" />	

<!--lloc-->
<!-- 		<xsl:value-of select="uab:clean(location)"/>
			<xsl:value-of select="$separator" />	

			<xsl:value-of select="uab:clean(city)"/>
			<xsl:value-of select="$separator" />	
			
			<xsl:value-of select="country/@pureId"/>			
			<xsl:value-of select="$separator" />
			<xsl:value-of select="country/@uri"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean_ca_en_es(country/term/text)"/>
			<xsl:value-of select="$separator" />	-->
<!-- validacio-->
			<xsl:value-of select="workflow/@workflowStep"/>
			<xsl:value-of select="$separator" />

<!-- info creacio-->				
			<xsl:value-of select="uab:clean(info/createdBy)"/>
			<xsl:value-of select="$separator" />			
			<xsl:value-of select="info/createdDate"/>
			<xsl:value-of select="$separator" />	

			<xsl:value-of select="$newline" />
		</xsl:for-each>
	</xsl:template> 
</xsl:stylesheet>	


