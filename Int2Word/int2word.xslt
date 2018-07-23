<?xml version="1.0" encoding="Windows-1250"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" version="1.0" encoding="Windows-1250" indent="yes"/>

<xsl:variable name="int2word" select=" '1jeden|2dva|3tri|4štyri|5päť|6šesť|7sedem|8osem|9deväť|10desať|11jedenásť|12dvanásť|13trinásť|14štrnásť|15pätnásť|16šestnásť|17sedemnásť|18osemnásť|19devätnásť|' "/>
<xsl:variable name="tens2word" select=" '2dvadsať|3tridsať|4štyridsať|5päťdesiat|6šesťdesiat|7sedemdesiat|8osemdesiat|9deväťdesiat|' "/>
<!-- <xsl:variable name="thousands2word" select=" '3Thousand|6Million|9Billion|12Trillion|15Quadrillion|18Quintillion|21Sextillion|24Septillion|27Octillion|30Nonillion|33Decillion|36Undecillion|39Duodecillion|42Tredecillion|45Quattuordecillion|48Quindecillion|51Sexdecillion|54Septendecillion|57Octodecillion|60Novemdecillion|63Vigintillion|' "/> -->
<xsl:variable name="thousands2word" select=" '3tisíc|' "/>

<xsl:template name="int2word">
<xsl:param name="in-integer" select="1"/>
<!-- this is the number you want to convert to a word or words -->
<xsl:variable name="the-number" select="translate($in-integer, ',.', '')"/>
<!-- remove any formatting characters -->
<xsl:variable name="num-length" select="string-length($the-number)"/>
<xsl:variable name="group-length">
<xsl:choose>
<xsl:when test="($num-length mod 3) = 0">3</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$num-length mod 3"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:variable name="first-group" select="substring($the-number, 1, $group-length)"/>
<xsl:variable name="the-rest" select="substring($the-number, $group-length + 1, $num-length)"/>
<xsl:choose>
<xsl:when test="not($the-rest = '')">
<xsl:call-template name="hundreds2words">
<xsl:with-param name="group" select="$first-group"/>
</xsl:call-template>
<xsl:if test="number($first-group)">
<xsl:value-of select="concat(substring-before(substring-after($thousands2word, string-length($the-rest)), '|'),'')"/>
</xsl:if>
<xsl:if test="number($the-rest)">
<xsl:call-template name="int2word">
<xsl:with-param name="in-integer" select="$the-rest"/>
</xsl:call-template>
</xsl:if>
</xsl:when>
<xsl:otherwise>
<xsl:call-template name="hundreds2words">
<xsl:with-param name="group" select="$first-group"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<!--Every group of three in American numbering is the basis for counting hundreds of - - thousands, millions, etc. -->
<xsl:template name="hundreds2words">
<xsl:param name="group"/>
<xsl:variable name="first-digit" select="substring(number($group), 1, 1)"/>
<xsl:variable name="remaining-digits">
<xsl:choose>
<xsl:when test="(19 &lt; number($group)) and (number($group) &lt; 100) "><xsl:value-of select="substring(number($group), 2, 1)"/></xsl:when>
<xsl:when test="(99 &lt; number($group)) and (number($group) &lt; 1000) "><xsl:value-of select="substring(number($group), 2, 2)"/></xsl:when>
</xsl:choose>
</xsl:variable>
<xsl:choose>
<xsl:when test="not($remaining-digits = '')">
<xsl:choose>
<xsl:when test="string-length($remaining-digits) = 1">
<xsl:value-of select="concat(substring-before(substring-after($tens2word, $first-digit), '|'), '')"/>
</xsl:when>
<xsl:when test="string-length($remaining-digits) = 2">
<xsl:value-of select="concat(substring-before(substring-after($int2word, $first-digit), '|'), '')"/>
<xsl:value-of select=" 'sto' "/>
</xsl:when>
</xsl:choose>
<xsl:call-template name="hundreds2words">
<xsl:with-param name="group" select="number($remaining-digits)"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:choose>
<xsl:when test="not(number($first-digit))"/>
<xsl:otherwise>
<xsl:value-of select="concat(substring-before(substring-after($int2word, number($group)), '|'), '')"/>
</xsl:otherwise>
</xsl:choose>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
</xsl:stylesheet>