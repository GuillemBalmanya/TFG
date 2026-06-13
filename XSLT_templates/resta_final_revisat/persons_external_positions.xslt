<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:uab="http://www.uab.cat">

    <xsl:include href="functions.xslt" />

    <xsl:output method="text" />

    <xsl:template match="/">
        <!-- Cabecera CSV -->
        <xsl:text>external_position_Pureid;personUUid;appointment_ca;appointment_en;appointement_es;external_organisation_uuid;startDate;endDate</xsl:text>

        <xsl:value-of select="$newline" />

        <xsl:for-each
            select="result/items/person">

            <!-- Guardem uuid de la persona -->
			<xsl:variable
                name="uuid" select="@uuid" />

            <!-- Iteramos sobre cada asociación -->
        <xsl:for-each
                select="externalPositions/externalPosition">

                <xsl:value-of select="@pureId" />
           
            <xsl:value-of
                    select="$separator" />	
                    
                    <xsl:value-of select="$uuid" />
            <xsl:value-of
                    select="$separator" />
            <xsl:value-of
                    select="uab:clean_ca_en_es(appointmentValue/text)" />
            <xsl:value-of
                    select="$separator" />				
            <xsl:value-of select="externalOrganisation/@uuid" />
            <xsl:value-of
                    select="$separator" />		
                    <xsl:value-of
                    select="concat(period/startDate/year, '&#45;',
                        format-number(number(period/startDate/month), '00'), '&#45;', 
                        format-number(number(period/startDate/day), '00'))"></xsl:value-of>     
            <xsl:value-of
                    select="$separator" />		
            <xsl:value-of
                    select="concat(period/endDate/year, '&#45;',
                            format-number(number(period/endDate/month), '00'), '&#45;', 
                            format-number(number(period/endDate/day), '00'))"></xsl:value-of>     
                
                
            <xsl:value-of
                    select="$newline" />

            </xsl:for-each>

        </xsl:for-each>

    </xsl:template>

</xsl:stylesheet>