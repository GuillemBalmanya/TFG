<!-- ATENCIÓ! AL MAIG DE 2021 CANVIEN L'ORIGEN A STATUS, JA NO DE KEYWORDS-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:uab="http://www.uab.cat">



                <xsl:include href="functions.xslt"/>
                <xsl:output method="text" />

                <xsl:template match="/">    

                <xsl:text>uuid;externalId;text_ca_ES;text_en_GB;text_es_ES;estatId;estat_term_text_ca_ES;estat_term_text_en_GB;estat_term_text_es_ES;internallyApprovedDate;relinquished;relinquishmentDate;relinquishmentReason;declined;declinationDate;declinedReason</xsl:text>
                               <xsl:value-of select="$newline" />

                               <xsl:for-each select="result/items/award">

                                               <!-- Guardem uuid i titol de l'award -->
                                               <xsl:value-of select="@uuid"/>
                                               <xsl:value-of select="$separator"/>
                                               <xsl:value-of select="@externalId"/>
                                               <xsl:value-of select="$separator"/>
                                               <xsl:value-of select="uab:clean_ca_en_es(title/text)"/>
                                               <xsl:value-of select="$separator"/>
                                               <xsl:value-of select="statusDetails/status/@key"/>
                                               <xsl:value-of select="$separator"/>
                                               <xsl:value-of select="uab:clean_ca_en_es(statusDetails/status/value/text)"/>
                                               <xsl:value-of select="$separator"/>
                                               <xsl:value-of select="statusDetails/internallyApprovedDate"/>
                                               <xsl:value-of select="$separator"/>
                                               <xsl:value-of select="statusDetails/relinquished"/>
                                               <xsl:value-of select="$separator"/>
                                               <xsl:value-of select="statusDetails/relinquishmentDate"/>
                                               <xsl:value-of select="$separator"/>
                                               <xsl:value-of select="statusDetails/relinquishmentReason"/>
                                               <xsl:value-of select="$separator"/>
                                               <xsl:value-of select="statusDetails/declined"/>
                                               <xsl:value-of select="$separator"/>
                                               <xsl:value-of select="statusDetails/declinationDate"/>
                                               <xsl:value-of select="$separator"/>
                                               <xsl:value-of select="statusDetails/declinedReason"/>
                                               <xsl:value-of select="$separator"/>
                                        <xsl:value-of select="$newline" /> 	
                               </xsl:for-each> 
                </xsl:template>  
</xsl:stylesheet>
