<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:uab="http://www.uab.cat"
	exclude-result-prefixes="fn uab xs">

	<xsl:include href="functions.xslt"/>

	<xsl:output method="text" />
	
	<xsl:param name="json-file" as="xs:string"/>

	<xsl:template match="/">
		<xsl:variable name="json-text" select="unparsed-text($json-file)" />
		<xsl:variable name="json-xml" select="json-to-xml($json-text)" />
		<xsl:text>eventUuid;externalId;typePureId;typeUri;typeText_ca;typeText_en;typeText_es;titleText_ca;titleText_en;titleText_es;startDate;endtDate;degreeOfRecognitionPureId;degreeOfRecognitionUri;degreeOfRecognitionText_ca;degreeOfRecognitionText_en;degreeOfRecognitionText_es;locatione;city;countryPureId;countryUri;countryText_ca;countryText_en;countryText_es;workflowStep;createdBy;createdDate</xsl:text>
		
		<xsl:value-of select="$newline" />
		<xsl:for-each select="$json-xml/fn:map/fn:array[@key='items']/fn:map">
			<xsl:value-of select="fn:string[@key='uuid']"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="fn:string[@key='externalId']"/>
			<xsl:value-of select="$separator" />
<!-- tipus de colaboracio-->	
			<xsl:value-of select="fn:map[@key='type']/fn:number[@key='pureId']"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="fn:map[@key='type']/fn:string[@key='uri']"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean_ca_en_es(fn:map[@key='type']/fn:map[@key='term'])"/>
			<xsl:value-of select="$separator" />			
			<xsl:value-of select="uab:clean_ca_en_es(fn:map[@key='title'])"/>
			<xsl:value-of select="$separator" />	
<!--		<xsl:value-of select="uab:clean_ca_en_es(descriptions/description/value/text)"/>
			<xsl:value-of select="$separator" />	-->		
<!-- periode (ara lifecycle a la JSON API)-->			
			<xsl:value-of select="fn:map[@key='lifecycle']/fn:string[@key='startDate']"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="fn:map[@key='lifecycle']/fn:string[@key='endDate']"/>
			<xsl:value-of select="$separator" />		
<!-- tipus de participacio i persones la trobarem al xslt personAssociations-->	
<!-- ambit-->	
			<xsl:value-of select="fn:map[@key='degreeOfRecognition']/fn:number[@key='pureId']"/>			
			<xsl:value-of select="$separator" />
			<xsl:value-of select="fn:map[@key='degreeOfRecognition']/fn:string[@key='uri']"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean_ca_en_es(fn:map[@key='degreeOfRecognition']/fn:map[@key='term'])"/>
			<xsl:value-of select="$separator" />	
<!-- lloc-->
			<xsl:value-of select="uab:clean(fn:string[@key='location'])"/>
			<xsl:value-of select="$separator" />	

			<xsl:value-of select="uab:clean(fn:string[@key='city'])"/>
			<xsl:value-of select="$separator" />	
			
			<xsl:value-of select="fn:map[@key='country']/fn:number[@key='pureId']"/>			
			<xsl:value-of select="$separator" />
			<xsl:value-of select="fn:map[@key='country']/fn:string[@key='uri']"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean_ca_en_es(fn:map[@key='country']/fn:map[@key='term'])"/>
			<xsl:value-of select="$separator" />				
<!-- validacio-->
			<xsl:value-of select="fn:map[@key='workflow']/fn:string[@key='workflowStep']"/>
			<xsl:value-of select="$separator" />

<!-- info creacio-->				
			<xsl:value-of select="uab:clean(fn:string[@key='createdBy'])"/>
			<xsl:value-of select="$separator" />			
			<xsl:value-of select="fn:string[@key='createdDate']"/>
			<xsl:value-of select="$separator" />	

			<xsl:value-of select="$newline" />
		</xsl:for-each>
	</xsl:template> 
</xsl:stylesheet>
