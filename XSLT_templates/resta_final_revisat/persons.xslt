<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:uab="http://www.uab.cat">

	<xsl:include href="functions.xslt"/>

	<xsl:output method="text" />

	<xsl:template match="/">
		<xsl:text>person_uuid;firstname;lastname;genderId;gender_ca_ES;dateOfBirth;nationality;employeeStartDate;employee_niu;dni;nif_nie_passport;nie;orcid;num_funcionari;scopusauthor;researcher_id</xsl:text>
		<xsl:value-of select="$newline" />
		<xsl:for-each select="result/items/person">
			<xsl:value-of select="@uuid"/>
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
			<xsl:value-of select="uab:clean(ids/id[type/@uri='/dk/atira/pure/person/personsources/employee']/value)"/>
			<xsl:value-of select="$separator" />				
			<xsl:value-of select="uab:clean(ids/id[type/@uri='/dk/atira/pure/person/personsources/dni']/value)"/>
			<xsl:value-of select="$separator" />
			<xsl:value-of select="uab:clean(ids/id[type/@uri='/dk/atira/pure/person/personsources/nif_nie_passport']/value)"/>	
			<xsl:value-of select="$separator" />		
			<xsl:value-of select="uab:clean(ids/id[type/@uri='/dk/atira/pure/person/personsources/nie']/value)"/>	
			<xsl:value-of select="$separator" />				
			<xsl:value-of select="orcid" />	
			<xsl:value-of select="$separator" />				
			<xsl:value-of select="uab:clean(ids/id[type/@uri='/dk/atira/pure/person/personsources/n_m_funcionari']/value)"/>
			<xsl:value-of select="$separator" />				
			<xsl:value-of select="uab:clean(ids/id[type/@uri='/dk/atira/pure/person/personsources/scopusauthor']/value)"/>
			<xsl:value-of select="$separator" />				
			<xsl:value-of select="uab:clean(ids/id[type/@uri='/dk/atira/pure/person/personsources/researcher']/value)"/>		
			<xsl:value-of select="$newline" />
		</xsl:for-each>
	</xsl:template> 	
</xsl:stylesheet>


