<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:uab="http://www.uab.cat">

	<xsl:include href="functions.xslt"/>

	<xsl:output method="text" />

	<xsl:template match="/">
		<xsl:text>externalPerson_uuid;externalPerson_pureId;firstname;lastname;genderId;gender_ca_ES;dateOfBirth;nationality;employeeStartDate;mendeleyprofile;dni;nif_nie_passport;nie;orcid;external_erm;scopusauthor;researcher_id;hesastaff;digitalauthor</xsl:text>
		<xsl:value-of select="$newline" />
		<xsl:for-each select="result/items/externalPerson">
			<xsl:value-of select="@uuid"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="@pureId"/>
			<xsl:value-of select="$separator" />			
			<xsl:value-of select="uab:clean(name/firstName)"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean(name/lastName)"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="gender/@pureId"  />
			<xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean(gender/term/text[@locale='ca_ES'])"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="dateOfBirth" />
			<xsl:value-of select="$separator" />
			<xsl:value-of select="nationality/@pureId" />
			<xsl:value-of select="$separator" />				
			<xsl:value-of select="employeeStartDate" />
			<xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean(ids/id[type/@uri='/dk/atira/pure/externalperson/externalpersonsources/mendeleyprofile']/value)"/>
			<xsl:value-of select="$separator" />				
			<xsl:value-of select="uab:clean(ids/id[type/@uri='/dk/atira/pure/externalperson/externalpersonsources/dni']/value)"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean(ids/id[type/@uri='/dk/atira/pure/externalperson/externalpersonsources/nif_nie_passport']/value)"/>	
			<xsl:value-of select="$separator" />		
			<xsl:value-of select="uab:clean(ids/id[type/@uri='/dk/atira/pure/externalperson/externalpersonsources/nie']/value)"/>	
			<xsl:value-of select="$separator" />				
			<xsl:value-of select="uab:clean(ids/id[type/@uri='/dk/atira/pure/externalperson/externalpersonsources/orcid_id']/value)"/>	
			<xsl:value-of select="$separator" />				
			<xsl:value-of select="uab:clean(ids/id[type/@uri='/dk/atira/pure/externalperson/externalpersonsources/external_erm']/value)"/>
			<xsl:value-of select="$separator" />				
			<xsl:value-of select="uab:clean(ids/id[type/@uri='/dk/atira/pure/externalperson/externalpersonsources/scopusauthor']/value)"/>
			<xsl:value-of select="$separator" />				
			<xsl:value-of select="uab:clean(ids/id[type/@uri='/dk/atira/pure/externalperson/externalpersonsources/researcher']/value)"/>
			<xsl:value-of select="$separator" />				
			<xsl:value-of select="uab:clean(ids/id[type/@uri='/dk/atira/pure/externalperson/externalpersonsources/hesastaff']/value)"/>	
			<xsl:value-of select="$separator" />				
			<xsl:value-of select="uab:clean(ids/id[type/@uri='/dk/atira/pure/externalperson/externalpersonsources/digitalauthor']/value)"/>	
			<xsl:value-of select="$newline" />
		</xsl:for-each>
	</xsl:template> 	
</xsl:stylesheet>


