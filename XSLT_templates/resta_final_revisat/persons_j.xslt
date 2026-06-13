<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:uab="http://www.uab.cat"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    expand-text="yes">

  <xsl:import href="Functions.xslt"/>
  <xsl:output method="text" encoding="UTF-8"/>

  <xsl:template name="main">
    <xsl:param name="jsonPath" as="xs:string"/>
    <xsl:variable name="json" select="unparsed-text('$jsonPath', 'UTF-8')"/>
    <xsl:variable name="parsed" select="parse-json($json)"/>
    <xsl:variable name="persons" select="$parsed?items"/>
    
    <xsl:text>person_uuid;firstname;lastname;genderId;gender_ca_ES;dateOfBirth;nationality;employeeStartDate;employee_niu;dni;nif_nie_passport;orcid;num_funcionari;scopusauthor;researcher_id</xsl:text>
    <xsl:text>&#10;</xsl:text>

    <xsl:for-each select="$persons?*">
      <xsl:variable name="ids" select=".?identifiers"/>
      <xsl:value-of select="string-join((
        string(.?uuid),
        uab:clean(.?name?firstName),
        uab:clean(.?name?lastName),
        string(.?gender?uri),
        uab:clean_ca(.?gender?term),
        if (.?dateOfBirth) then format-date(xs:date(.?dateOfBirth), '[D01]/[M01]/[Y0001]') else '',
        string(.?nationality?uri),
        if (.?employeeStartDate) then format-date(xs:date(.?employeeStartDate), '[D01]/[M01]/[Y0001]') else '',
        uab:clean(($ids?*[?type?uri = '/dk/atira/pure/person/personsources/employee'])[1]?id),
        uab:clean(($ids?*[?type?uri = '/dk/atira/pure/person/personsources/dni'])[1]?id),
        uab:clean(($ids?*[?type?uri = '/dk/atira/pure/person/personsources/nif_nie_passport'])[1]?id),
        uab:clean(($ids?*[?type?uri = '/dk/atira/pure/person/personsources/nie'])[1]?id),
        uab:clean(.?orcid),
        uab:clean(($ids?*[?type?uri = '/dk/atira/pure/person/personsources/n_m_funcionari'])[1]?id),
        uab:clean(($ids?*[?type?uri = '/dk/atira/pure/person/personsources/scopusauthor'])[1]?id),
        uab:clean(($ids?*[?type?uri = '/dk/atira/pure/person/personsources/researcher'])[1]?id)
      ), ';')"/>
      <xsl:text>&#10;</xsl:text>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
