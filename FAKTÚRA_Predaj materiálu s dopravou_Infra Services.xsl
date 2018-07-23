<?xml version="1.0" encoding="Windows-1250"?>
<xsl:stylesheet version="1.0" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
 xmlns:msxsl="urn:schemas-microsoft-com:xslt"
 xmlns:date="http://exslt.org/dates-and-times"
 xmlns:str="http://exslt.org/strings"
 extension-element-prefixes="date str">
<!-- 
	<INFO>
		<SUBJECT> Faktúra na A4 </SUBJECT>
		<AUTHOR> Peter Kramář </AUTHOR>
		<EMAIL>pkramar@hoblapech.sk</EMAIL>
		<VERSION></VERSION>
	</INFO>
	<ORIGIN>
		<PODNIK> Motopark s.r.o. </PODNIK>
		<DATE></DATE>
		<SESTAVAN></SESTAVAN>
		<POPIS></POPIS>
		<HIST>      
		</HIST>
	</ORIGIN>
-->
                                                
<xsl:import href="Int2Word/int2word.xslt"/>
<xsl:import href="EXSLT/date/functions/day-in-week/date.day-in-week.xsl" />
<xsl:import href="EXSLT/str/functions/tokenize/str.tokenize.xsl" />

<xsl:decimal-format name="myFormat" decimal-separator="," grouping-separator=" " NaN="0,00"/>
<xsl:output method="html" encoding="windows-1250"/>
	
<!-- ***** VARIABLES START*****-->	
<xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyzš'" />
<xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZŠ'" />

<xsl:variable name="MonthName">
  <M cislo="01" dni="31">Január</M>
  <M cislo="02" dni="28">Február</M>
  <M cislo="03" dni="31">Marec</M>
  <M cislo="04" dni="30">Apríl</M>
  <M cislo="05" dni="31">Máj</M>
  <M cislo="06" dni="30">Jún</M>
  <M cislo="07" dni="31">Júl</M>
  <M cislo="08" dni="31">August</M>
  <M cislo="09" dni="30">September</M>
  <M cislo="10" dni="31">Október</M>
  <M cislo="11" dni="30">November</M>
  <M cislo="12" dni="31">December</M>
</xsl:variable>

<xsl:variable name="poznamka" select="//FEH/POZNAMKA"/>
                                                                                       <!--stavby:&#9; -->
<xsl:variable name="nazovStavby" select="substring-before(substring-after($poznamka,'Názov stavby:'),'#')"/>
<xsl:variable name="miestoVykonu" select="//FEH/VYKLADKA"/>
<xsl:variable name="objednavka" select="//FEH/OBJEDINFO1"/>

<xsl:variable name="mesiac" select="substring(//FAH/DZP, 1, 2)"/>
<xsl:variable name="rok" select="substring(//FAH/DZP, 7, 4)"/>

<xsl:variable name="mesiacDni">                      <!-- (y%400==0)|((y%4==0)&(y%100!=0)) -->
 <xsl:choose>
   <xsl:when test="($mesiac = '02') and (($rok mod 400 = 0) or (($rok mod 4 = 0) and ($rok mod 100 != 0)))">
     <xsl:value-of select="28 + 1"/>
   </xsl:when>
   <xsl:otherwise>
     <xsl:value-of select="msxsl:node-set($MonthName)/M[@cislo = $mesiac]/@dni"/>
   </xsl:otherwise>
 </xsl:choose>
</xsl:variable>

<xsl:variable name="datumDo" select="concat($mesiacDni,'.',$mesiac,'.',$rok)"/>
<xsl:variable name="objFilter" select="concat(//FEH/OBJEDMASKA,':',//FEH/OBJEDMASO)"/>

<xsl:variable name="hodiny" select="document(concat('http://localhost:3733/showses.php?defses=/data/Definice/Tisky/FAK/vykony.xml','&amp;od=01.01.2014','&amp;do=',$datumDo,'&amp;time=0','&amp;fobj=1','&amp;filtryo=',$objFilter))"/>
<xsl:variable name="sadzby" select="document(concat('http://localhost:3733/showses.php?defses=/data/Definice/Tisky/FAK/sadzby.xml','&amp;time=19','&amp;mesic=',number($mesiac),'&amp;rok=',$rok,'&amp;fobj=1','&amp;filtryo=',$objFilter))"/>
<xsl:variable name="pociatky" select="document(concat('http://localhost:3733/showses.php?defses=/data/Definice/Tisky/FAK/vykony2.xml','&amp;od=01.01.2014','&amp;do=',$datumDo,'&amp;time=0','&amp;fobj=1','&amp;filtryo=',$objFilter))"/>

<xsl:variable name="medziskladka" select="count(//FER[starts-with(SAZEBNIK, 'X')])"/>

                                        <!-- test, ci ide o faktoringovu fakturu obsahujucu cestnu klauzulu -->
<xsl:variable name="faktoring" select="substring-after(msxsl:node-set($origRoot)//FAH/FU,',') = ' Faktoring'"/>
                        
<xsl:variable name="staryFormat" select="concat(substring(//FAH/DF,7,4), substring(//FAH/DF,1,2)) &lt;= '201705'"/>                        
                        
<xsl:variable name="lpp">55</xsl:variable>    <!--LINES PER PAGE--><!-- LINE = INDIVIDUAL ROW--> <!-- povodne 54-->
<xsl:variable name="lppws">25</xsl:variable>  <!--LINES PER PAGE WITH SUMMARY-->      <!-- povodne 29 -->

<xsl:variable name="origRoot" select="/"/>    <!--*****ORIGINAL XML ROOT*****-->

<xsl:variable name="sortedXml">                      <!--*****SORTED XML*****-->
  <xsl:for-each select="//FER">           
    <xsl:sort select="concat(SAZEBNIK, SAZBA)" data-type="text" order="ascending"/>
       <xsl:variable name="sub" select="SUBSTR"/>      
       <RIADOK>             
         <xsl:copy-of select="."/>             
         <xsl:copy-of select="../VYKLADKA"/>
         
         <!-- #: spojenie sadzby za material (X..) so sadzbou za dopravu 
         <MSADZBA>
           <xsl:choose>
             <xsl:when test="starts-with(SAZEBNIK, 'X')">
               <xsl:variable name="Dkod" select="concat(DATUM, CAS, POCETJED, SUBSTR)"/>
               <xsl:variable name="Dsadzba" select="sum(..//FER[concat(DATUM, CAS, POCETJED, SUBSTR) = $Dkod and not(starts-with(SAZEBNIK, 'X'))]/SAZBA)"/>
               <xsl:value-of select="SAZBA + $Dsadzba"/>
             </xsl:when>
             
             <xsl:otherwise>
               <xsl:value-of select="SAZBA"/>
             </xsl:otherwise>
           </xsl:choose>
         </MSADZBA>
          #: end -->         
                   
<!--         <CISLO_OBJ>
           <xsl:choose>
             <xsl:when test="not(string-length(../OBJEDINFO1) = 0) and not(../OBJEDINFO1 = ../MATERINFO1)">
               <xsl:value-of select="../OBJEDINFO1"/>
             </xsl:when>
             <xsl:otherwise>
               <xsl:value-of select="SAZBA_POZNAMKA"/>
             </xsl:otherwise> 
           </xsl:choose>
         </CISLO_OBJ>
-->
         <CISLO_OBJ>
           <xsl:value-of select="../OBJEDINFO1"/>
         </CISLO_OBJ>
                                   
         <xsl:copy-of select="../SPZ"/>
         <xsl:copy-of select="../SUB[S_KOD = $sub]/S_NAZEV"/>                                             
       </RIADOK>
  </xsl:for-each>
</xsl:variable>
  
<xsl:variable name="suma">                             <!--*****SUMA XML*****-->
 <xsl:for-each select="msxsl:node-set($sortedXml)/RIADOK[not(concat(FER/SAZEBNIK, FER/SAZBA) = concat(preceding-sibling::RIADOK[1]/FER/SAZEBNIK, preceding-sibling::RIADOK[1]/FER/SAZBA)) and not(FER/SAZEBNIK = 'Z')]">          
  <xsl:variable name="subkod" select="concat(FER/SAZEBNIK, FER/SAZBA)"/>
<!--  
  <xsl:variable name="pocJedn" select="sum(//RIADOK[concat(FER/SAZEBNIK, FER/SAZBA) = $subkod]/FER/POCETJED)"/>
  <xsl:variable name="sumaBezDane" select="number(format-number(FER/SAZBA * $pocJedn,'#0.000'))"/>
-->

  <xsl:variable name="sumaBezDane">
    <xsl:if test="$staryFormat"><xsl:variable name="pocJedn" select="sum(//RIADOK[concat(FER/SAZEBNIK, FER/SAZBA) = $subkod]/FER/POCETJED)"/>
    <xsl:value-of select="number(format-number(FER/SAZBA * $pocJedn,'#0.000'))"/></xsl:if>
        
    <xsl:if test="not($staryFormat)"><xsl:value-of select="number(format-number(sum(//RIADOK[concat(FER/SAZEBNIK, FER/SAZBA) = $subkod]/FER/KC), '#0.00'))"/></xsl:if>    
  </xsl:variable>
  
  <!-- netreba rozlisovat stary a novy format, lebo pri starom sa nod DAN nepouziva a preto nevadi, ze sa tam da to, co plati pre novy format -->
  <xsl:variable name="sumaDane" select="number(format-number(sum(//RIADOK[concat(FER/SAZEBNIK, FER/SAZBA) = $subkod]/FER/DPHDAN), '#0.000'))"/>          
          
   <RIADOK>      
		<ZAKLAD>
			<xsl:value-of select="$sumaBezDane"/>
		</ZAKLAD>
		<DAN>
			<xsl:value-of select="$sumaDane"/>
		</DAN>    		           
   </RIADOK>                                                                  
 </xsl:for-each>  
</xsl:variable>

<xsl:variable name="lineCountXml">               <!--*****LINE COUNT XML*****-->
 <xsl:for-each select="msxsl:node-set($sortedXml)/RIADOK[not(concat(FER/SAZEBNIK, FER/SAZBA) = concat(preceding-sibling::RIADOK[1]/FER/SAZEBNIK, preceding-sibling::RIADOK[1]/FER/SAZBA)) and not(FER/SAZEBNIK = 'Z')]">  
  <xsl:variable name="subkod" select="concat(FER/SAZEBNIK, FER/SAZBA)"/>
 
  <xsl:variable name="sortedXmlObjedinfo">                      
   <xsl:for-each select="msxsl:node-set($sortedXml)/RIADOK[concat(FER/SAZEBNIK, FER/SAZBA) = $subkod]">           
    <xsl:sort select="CISLO_OBJ" data-type="text" order="ascending"/>                      
      <xsl:copy-of select="."/>             
   </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="ObjString">                      
   <xsl:for-each select="msxsl:node-set($sortedXmlObjedinfo)/RIADOK[not(CISLO_OBJ = preceding-sibling::RIADOK[1]/CISLO_OBJ)]">                                     
     <xsl:value-of select="CISLO_OBJ"/>
     <xsl:if test="position() != last()">,</xsl:if>             
   </xsl:for-each>
  </xsl:variable>
  
  <xsl:variable name="ObjCharsXml">    
    <xsl:call-template name="chars">
      <xsl:with-param name="text" select="$ObjString" />
      <xsl:with-param name="counter">1</xsl:with-param>
      <xsl:with-param name="fulltext" select="$ObjString"/>
      <xsl:with-param name="lineNum">1</xsl:with-param>
    </xsl:call-template>
  </xsl:variable>    

<!--  <xsl:variable name="ObjLineCount" select="count(msxsl:node-set($ObjCharsXml)/CH[@eol='true'])"/> -->

<xsl:variable name="ObjLineCount">
 <xsl:choose>
  <xsl:when test="count(msxsl:node-set($ObjCharsXml)/CH) &gt; 0">
    <xsl:value-of select="count(msxsl:node-set($ObjCharsXml)/CH[@eol='true'])"/>
  </xsl:when>
  <xsl:otherwise>
    <xsl:value-of select="0+1"/>  
  </xsl:otherwise>  
 </xsl:choose>
</xsl:variable>  
  
  <xsl:variable name="sortedXmlSPZ">                      
   <xsl:for-each select="msxsl:node-set($sortedXml)/RIADOK[concat(FER/SAZEBNIK, FER/SAZBA) = $subkod]">           
    <xsl:sort select="SPZ" data-type="text" order="ascending"/>                      
      <xsl:copy-of select="."/>             
   </xsl:for-each>
  </xsl:variable>                                             
     
  <RIADOK>                    
   <LINE>                                                          
     <xsl:value-of select="2 + $ObjLineCount + 1"/>
   </LINE>
   
   <xsl:for-each select="msxsl:node-set($sortedXmlSPZ)/RIADOK[not(SPZ = preceding-sibling::RIADOK[1]/SPZ)]">
     <xsl:variable name="sSPZ" select="SPZ"/>
       
     <xsl:variable name="sortedXmlDatum">                      
       <xsl:for-each select="msxsl:node-set($sortedXml)/RIADOK[concat(FER/SAZEBNIK, FER/SAZBA) = $subkod and SPZ = $sSPZ]">           
         <xsl:sort select="concat(substring(FER/DATUM,7),substring(FER/DATUM,1,2),substring(FER/DATUM,4,2))" data-type="text" order="ascending"/>                      
         <xsl:copy-of select="."/>             
       </xsl:for-each>
     </xsl:variable>
     
     <LINE>
       <xsl:attribute name="frakcia">true</xsl:attribute> 
       <xsl:value-of select="1 + count(msxsl:node-set($sortedXmlDatum)/RIADOK[not(FER/DATUM = preceding-sibling::RIADOK[1]/FER/DATUM)])"/>
     </LINE>       
   </xsl:for-each>
                                                                                                                                                                          
  </RIADOK>                                                                    
 </xsl:for-each>
</xsl:variable>   
                          <!--faktoring pridava 8 riadkov    *****INVOICE LINE COUNT*****--> 
<xsl:variable name="line_count" select="$faktoring*8 + sum(msxsl:node-set($lineCountXml)/RIADOK/LINE)"/>

<xsl:variable name="pageCount">
  <xsl:variable name="fullPageCount" select="1 + floor($line_count div $lpp)"/>
  <xsl:choose>
    <xsl:when test="($line_count mod $lpp) &gt; $lppws">
      <xsl:value-of select="$fullPageCount + 1"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$fullPageCount"/>
    </xsl:otherwise>
  </xsl:choose>  
</xsl:variable>
<!-- ***** VARIABLES END*****-->                                               
                                               
<xsl:template match="/">                       <!-- ***** HTML BEGINNING*****-->
<html>
<head>
	<META content="text/html" charset="Windows-1250" http-equiv="Content-Type"/>
	<META content="sk" http-equiv="Content-language"/>
	<title>Faktúra - A4</title>
	<LINK rel="stylesheet" href="faktura_mtp.css" type="text/css"/>
</head>

<BODY>
<xsl:call-template name="header">
 <xsl:with-param name="showDesc" select="1"/>
 <xsl:with-param name="pageNumber" select="1"/>
 <xsl:with-param name="pageCount" select="$pageCount"/>
</xsl:call-template>

<!-- jednotlivé výkony uvedené ve faktuře -->
                                                                                                                                                                                         
<xsl:for-each select="msxsl:node-set($sortedXml)/RIADOK[not(concat(FER/SAZEBNIK, FER/SAZBA) = concat(preceding-sibling::RIADOK[1]/FER/SAZEBNIK, preceding-sibling::RIADOK[1]/FER/SAZBA)) and not(FER/SAZEBNIK = 'Z')]">  
 <xsl:variable name="subkod" select="concat(FER/SAZEBNIK, FER/SAZBA)"/>
 <xsl:variable name="pocJedn" select="sum(//RIADOK[concat(FER/SAZEBNIK, FER/SAZBA) = $subkod]/FER/POCETJED)"/>
<!-- 
 <xsl:variable name="sumaBezDane" select="number(format-number(FER/SAZBA * $pocJedn,'#0.000'))"/>
 <xsl:variable name="sumaDane" select="number(format-number((FER/DPH * 0.01) * $sumaBezDane,'#0.000'))"/>
--> 

  <xsl:variable name="sumaBezDane">
    <xsl:if test="$staryFormat"><xsl:value-of select="number(format-number(FER/SAZBA * $pocJedn,'#0.000'))"/></xsl:if>    
    <xsl:if test="not($staryFormat)"><xsl:value-of select="number(format-number(sum(//RIADOK[concat(FER/SAZEBNIK, FER/SAZBA) = $subkod]/FER/KC), '#0.00'))"/></xsl:if>    
  </xsl:variable>                                          
  
  <!-- treba rozlisovat stary a novy format -->
  <xsl:variable name="sumaDane"> 
    <xsl:if test="$staryFormat"><xsl:value-of select="number(format-number((FER/DPH * 0.01) * $sumaBezDane,'#0.000'))"/></xsl:if>    
    <xsl:if test="not($staryFormat)"><xsl:value-of select="number(format-number(sum(//RIADOK[concat(FER/SAZEBNIK, FER/SAZBA) = $subkod]/FER/DPHDAN), '#0.000'))"/></xsl:if>                                          
  </xsl:variable>

 <xsl:variable name="pos" select="position()"/>
 <xsl:variable name="LineCountSoFar" select="$faktoring*8 + sum(msxsl:node-set($lineCountXml)/RIADOK[position() &lt; $pos]/LINE)"/>
                             <!-- faktoring: pridava 8 riadkov na zaciatku -->
 <xsl:variable name="kodSubstratu" select="FER/SUBSTR"/>                            
 
 <DIV class="botcara18">  
    <DIV class="popis" style="font-size:11;line-height:12px;width:8.74cm">   
     <B><xsl:value-of select="S_NAZEV"/></B>    <!--  / <xsl:value-of select="$LineCountSoFar + 1"/> -->
    </DIV>
                                                        
   <DIV class="vykon" style="font-size:11;line-height:12px">
		<DIV class="number_neu" style="width:1.78cm">
			<!-- <xsl:value-of select="format-number($pocJedn,'### ##0,00','myFormat')"/> -->
			<xsl:if test="$staryFormat"><xsl:value-of select="format-number($pocJedn,'### ##0,00','myFormat')"/></xsl:if>
      <xsl:if test="not($staryFormat)"><xsl:value-of select="format-number($pocJedn,'### ##0,000','myFormat')"/></xsl:if>      
			<xsl:text> </xsl:text>                                                                   
			<xsl:value-of select="FER/JEDNOTKA"/>
		</DIV>

		<DIV class="sazba" style="width:1.3cm">
			<xsl:value-of select="format-number(FER/SAZBA,'### ##0,000','myFormat')"/>
		</DIV>

		<DIV class="sazba" style="width:2.3cm">
			<!-- <xsl:value-of select="format-number($sumaBezDane,'### ##0,000','myFormat')"/> -->
			<xsl:if test="$staryFormat"><xsl:value-of select="format-number($sumaBezDane,'### ##0,000','myFormat')"/></xsl:if>
      <xsl:if test="not($staryFormat)"><xsl:value-of select="format-number($sumaBezDane,'### ##0,00','myFormat')"/></xsl:if>      
		</DIV>		

		<DIV class="sazba" style="width:1.1cm">
			<xsl:value-of select="FER/DPH"/>%
		</DIV>				

		<DIV class="sazba" style="width:1.6cm">
			<xsl:value-of select="format-number($sumaDane,'### ##0,000','myFormat')"/>
		</DIV>

		<DIV class="number" style="width:1.98cm">
			<xsl:value-of select="format-number($sumaBezDane + $sumaDane,'### ##0,000','myFormat')"/>
		</DIV>          
   </DIV>
   
  <xsl:if test="(($LineCountSoFar+1) mod $lpp) = 0">           
    <div style="page-break-after:always;line-height:0px">&#160;</div>
    <xsl:call-template name="header">
     <xsl:with-param name="showDesc" select="0"/>
     <xsl:with-param name="pageNumber" select="1 + (($LineCountSoFar+1) div $lpp)"/>
     <xsl:with-param name="pageCount" select="$pageCount"/>     
    </xsl:call-template>
  </xsl:if>
   
  <xsl:variable name="sortedXmlObjedinfo">                      
   <xsl:for-each select="msxsl:node-set($sortedXml)/RIADOK[concat(FER/SAZEBNIK, FER/SAZBA) = $subkod]">           
    <xsl:sort select="CISLO_OBJ" data-type="text" order="ascending"/>                      
      <xsl:copy-of select="."/>             
   </xsl:for-each>
  </xsl:variable>
  
  <xsl:variable name="sortedXmlSPZ">                      
   <xsl:for-each select="msxsl:node-set($sortedXml)/RIADOK[concat(FER/SAZEBNIK, FER/SAZBA) = $subkod]">           
    <xsl:sort select="SPZ" data-type="text" order="ascending"/>                      
      <xsl:copy-of select="."/>             
   </xsl:for-each>
  </xsl:variable>  
  
  <xsl:variable name="ObjString">                      
   <xsl:for-each select="msxsl:node-set($sortedXmlObjedinfo)/RIADOK[not(CISLO_OBJ = preceding-sibling::RIADOK[1]/CISLO_OBJ)]">                                     
     <xsl:value-of select="CISLO_OBJ"/>
     <xsl:if test="position() != last()">,</xsl:if>             
   </xsl:for-each>
  </xsl:variable>
  
  <xsl:variable name="ObjCharsXml">    
    <xsl:call-template name="chars">
      <xsl:with-param name="text" select="$ObjString" />
      <xsl:with-param name="counter">1</xsl:with-param>
      <xsl:with-param name="fulltext" select="$ObjString"/>
      <xsl:with-param name="lineNum">1</xsl:with-param>            
    </xsl:call-template>
  </xsl:variable>  
<!--   
  <SPAN style="font-size:10;line-height:12px;font-style:italic">
    EČV: <xsl:value-of select="SPZ"/> <BR/>
  </SPAN>
-->
   <SPAN style="font-size:10;line-height:10px;font-style:italic; color:#4D4D4D">    
    Miesto určenia: <xsl:value-of select="VYKLADKA"/> <BR/>
   </SPAN>
    
    <xsl:if test="(($LineCountSoFar+2) mod $lpp) = 0">           
     <div style="page-break-after:always;line-height:0px">&#160;</div>
     <xsl:call-template name="header">
      <xsl:with-param name="showDesc" select="0"/>
      <xsl:with-param name="pageNumber" select="1 + (($LineCountSoFar+2) div $lpp)"/>
      <xsl:with-param name="pageCount" select="$pageCount"/>     
     </xsl:call-template>
    </xsl:if>

<!-- vypis cisel objednavok-->
                
   <SPAN style="font-size:10;line-height:10px;font-style:italic;width:1.7cm; color:#4D4D4D">    
    číslo zmluvy:
   </SPAN>
   
<xsl:choose>
  <!-- ak je nejake cislo objednavky -->
  <xsl:when test="count(msxsl:node-set($ObjCharsXml)/CH) &gt; 0">   
  
   <xsl:for-each select="msxsl:node-set($ObjCharsXml)/CH">
     <SPAN style="font-family:courier new;font-size:10;line-height:10px;font-style:italic; color:#4D4D4D">
       <xsl:value-of select="."/>
     </SPAN>
       
     <xsl:choose>       
       <xsl:when test="./@eol and not((($LineCountSoFar + 2 + ./@lineNum) mod $lpp) = 0)">
         <BR/> 
         <xsl:if test="not(position() = last())">
           <SPAN style="font-size:10;line-height:10px;font-style:italic;width:1.7cm"></SPAN>
         </xsl:if>
       </xsl:when>
       
       <xsl:when test="./@eol and ((($LineCountSoFar + 2 + ./@lineNum) mod $lpp) = 0)">       
         <div style="page-break-after:always;line-height:0px">&#160;</div>
         <xsl:call-template name="header">
           <xsl:with-param name="showDesc" select="0"/>
           <xsl:with-param name="pageNumber" select="1 + (($LineCountSoFar + 2 + ./@lineNum) div $lpp)"/>
           <xsl:with-param name="pageCount" select="$pageCount"/>     
         </xsl:call-template>
         
         <xsl:if test="not(position() = last())">
           <SPAN style="font-size:10;line-height:10px;font-style:italic;width:1.7cm"></SPAN>
         </xsl:if>                                  
       </xsl:when>
     </xsl:choose>                      
   </xsl:for-each>
  </xsl:when>
  
  <!-- ak nie je --> 
  <xsl:otherwise>
    <BR/>
  </xsl:otherwise>
</xsl:choose>

<!--  <xsl:variable name="ObjLineCount" select="count(msxsl:node-set($ObjCharsXml)/CH[@eol='true'])"/>  -->
  
<xsl:variable name="ObjLineCount">
 <xsl:choose>
  <xsl:when test="count(msxsl:node-set($ObjCharsXml)/CH) &gt; 0">
    <xsl:value-of select="count(msxsl:node-set($ObjCharsXml)/CH[@eol='true'])"/>
  </xsl:when>
  <xsl:otherwise>
    <xsl:value-of select="0+1"/>  
  </xsl:otherwise>  
 </xsl:choose>
</xsl:variable>   

<!-- vypis cisel ciastkovych objednavok -->                 <!--width:1.7cm; -->
   <SPAN style="font-size:10;line-height:10px;font-style:italic; color:#4D4D4D">    
    číslo objednávky:                                                             
   </SPAN>
   <SPAN style="font-family:courier new;font-size:10;line-height:10px;font-style:italic; color:#4D4D4D">
     <xsl:value-of select="//FER[SUBSTR = $kodSubstratu and string-length(POPIS)]/POPIS"/><BR/>
   </SPAN>
   
    <xsl:if test="(($LineCountSoFar+2+$ObjLineCount+1) mod $lpp) = 0">           
      <div style="page-break-after:always;line-height:0px">&#160;</div>
      <xsl:call-template name="header">
        <xsl:with-param name="showDesc" select="0"/>
        <xsl:with-param name="pageNumber" select="1 + (($LineCountSoFar+2+$ObjLineCount+1) div $lpp)"/>
        <xsl:with-param name="pageCount" select="$pageCount"/>     
      </xsl:call-template>
    </xsl:if>
       
<!-- vypis ECV -->   
  <xsl:for-each select="msxsl:node-set($sortedXmlSPZ)/RIADOK[not(SPZ = preceding-sibling::RIADOK[1]/SPZ)]">
      <xsl:variable name="sSPZ" select="SPZ"/>
      <xsl:variable name="thisPos" select="position()"/>
      
      <xsl:variable name="sortedXmlDatum">                      
        <xsl:for-each select="msxsl:node-set($sortedXml)/RIADOK[concat(FER/SAZEBNIK, FER/SAZBA) = $subkod and SPZ = $sSPZ]">           
         <xsl:sort select="concat(substring(FER/DATUM,7),substring(FER/DATUM,1,2),substring(FER/DATUM,4,2))" data-type="text" order="ascending"/>                      
         <xsl:copy-of select="."/>             
        </xsl:for-each>
      </xsl:variable>
            
      <xsl:variable name="prevFrakcieLineCount" select="sum(msxsl:node-set($lineCountXml)/RIADOK[position() = $pos]/LINE[@frakcia and position() &lt;= $thisPos])"/>
      
    <SPAN style="font-size:10;line-height:12px;font-style:italic">      
      EČV: <xsl:value-of select="SPZ"/> <!-- - [<xsl:value-of select="$prevFrakcieLineCount"/>] <xsl:value-of select="$thisPos"/> - <xsl:value-of select="count(msxsl:node-set($sortedXmlSPZ)/RIADOK[not(SPZ = preceding-sibling::RIADOK[1]/SPZ)])"/> --> <BR/>       
    </SPAN>        
    
    <xsl:if test="(($LineCountSoFar+2+$ObjLineCount+1+$prevFrakcieLineCount+1) mod $lpp) = 0">           
      <div style="page-break-after:always;line-height:0px">&#160;</div>
      <xsl:call-template name="header">
        <xsl:with-param name="showDesc" select="0"/>
        <xsl:with-param name="pageNumber" select="1 + (($LineCountSoFar+2+$ObjLineCount+1+$prevFrakcieLineCount+1) div $lpp)"/>
        <xsl:with-param name="pageCount" select="$pageCount"/>     
      </xsl:call-template>
    </xsl:if>

                   
<!-- vypis dni-->
      
    <xsl:for-each select="msxsl:node-set($sortedXmlDatum)/RIADOK[not(FER/DATUM = preceding-sibling::RIADOK[1]/FER/DATUM)]">                                 
      <xsl:variable name="datum" select="FER/DATUM"/>
      <xsl:variable name="poz" select="position()"/>
      
       <SPAN style="font-family:Calibri;font-size:10;line-height:12px; color:#4D4D4D">              
        <xsl:value-of select="concat(substring(FER/DATUM,4,2),'.',substring(FER/DATUM,1,2),'.',substring(FER/DATUM,7))"/><xsl:text>: </xsl:text>
               
        <xsl:for-each select="msxsl:node-set($sortedXmlDatum)/RIADOK/FER[DATUM = $datum]">   <!-- vypis hmotnosti v dni-->
          <xsl:if test="not(position() = 1)">+</xsl:if>          
          <xsl:value-of select="format-number(POCETJED,'#0,00','myFormat')"/>
        </xsl:for-each>
        
        <xsl:choose>
          <xsl:when test="count(msxsl:node-set($sortedXmlDatum)/RIADOK/FER[DATUM = $datum]) = 1">
            <xsl:text> </xsl:text><xsl:value-of select="msxsl:node-set($sortedXmlDatum)/RIADOK/FER[DATUM = $datum]/JEDNOTKA"/> <!-- / <xsl:value-of select="$poz"/> - <xsl:value-of select="count(msxsl:node-set($sortedXmlDatum)/RIADOK[not(FER/DATUM = preceding-sibling::RIADOK[1]/FER/DATUM)])"/> * <xsl:value-of select="$LineCountSoFar+2+$ObjLineCount+1+$prevFrakcieLineCount+1+$poz"/> --> 
            <BR/>            
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>=</xsl:text>
            <xsl:value-of select="format-number(sum(msxsl:node-set($sortedXmlDatum)/RIADOK/FER[DATUM = $datum]/POCETJED),'#0,00','myFormat')"/>
            <xsl:text> </xsl:text><xsl:value-of select="msxsl:node-set($sortedXmlDatum)/RIADOK/FER[DATUM = $datum]/JEDNOTKA"/>     <!-- / <xsl:value-of select="$poz"/> - <xsl:value-of select="count(msxsl:node-set($sortedXmlDatum)/RIADOK[not(FER/DATUM = preceding-sibling::RIADOK[1]/FER/DATUM)])"/> * <xsl:value-of select="$LineCountSoFar+2+$ObjLineCount+1+$prevFrakcieLineCount+1+$poz"/> --> 
            <BR/>          
          </xsl:otherwise>
        </xsl:choose>                                                                                                                  <!--koniec vypisu hmotnosti v dni-->
       </SPAN>              

      <xsl:if test="($thisPos &lt; count(msxsl:node-set($sortedXmlSPZ)/RIADOK[not(SPZ = preceding-sibling::RIADOK[1]/SPZ)])) or ($poz &lt; count(msxsl:node-set($sortedXmlDatum)/RIADOK[not(FER/DATUM = preceding-sibling::RIADOK[1]/FER/DATUM)]))">   <!--tu opravit -->
        <xsl:if test="(($LineCountSoFar+2+$ObjLineCount+1+$prevFrakcieLineCount+1+$poz) mod $lpp) = 0">                           
         <div style="page-break-after:always;line-height:0px">&#160;</div>
         <xsl:call-template name="header">
          <xsl:with-param name="showDesc" select="0"/>
          <xsl:with-param name="pageNumber" select="1 + (($LineCountSoFar+2+$ObjLineCount+1+$prevFrakcieLineCount+1+$poz) div $lpp)"/>
          <xsl:with-param name="pageCount" select="$pageCount"/>     
         </xsl:call-template>         
        </xsl:if>
      </xsl:if>        
       
    </xsl:for-each>                                                                                                                    <!--koniec vypisu dni-->
  </xsl:for-each>                         
                                                             
 </DIV>

 <xsl:variable name="LineCountSoFarInc" select="$faktoring*8 + sum(msxsl:node-set($lineCountXml)/RIADOK[position() &lt; $pos+1]/LINE)"/>   <!-- including current RIADOK-->
  
 <xsl:if test="($LineCountSoFarInc mod $lpp) = 0">           
   <div style="page-break-after:always;line-height:0px">&#160;</div>
   <xsl:call-template name="header">
    <xsl:with-param name="showDesc" select="0"/>
    <xsl:with-param name="pageNumber" select="1 + ($LineCountSoFarInc div $lpp)"/>
    <xsl:with-param name="pageCount" select="$pageCount"/>     
   </xsl:call-template>
 </xsl:if>
       
</xsl:for-each>   

<xsl:choose>                                          
  <xsl:when test="$line_count &lt; ($lppws + 1)">
   <SPAN class="foot">
     <xsl:call-template name="footer"/>     
   </SPAN>                                                                           
  </xsl:when>
  
  <xsl:when test="($line_count &gt; $lppws) and ($line_count &lt; ($lpp + $lppws + 1))">
   <xsl:if test="$line_count &lt; $lpp">
    <SPAN class="header2">
     <xsl:call-template name="header">
       <xsl:with-param name="showDesc" select="0"/>
       <xsl:with-param name="pageNumber" select="2"/>
       <xsl:with-param name="pageCount" select="2"/>       
     </xsl:call-template>          
    </SPAN>         
   </xsl:if>   
   <SPAN class="foot2">
     <xsl:call-template name="footer"/>
   </SPAN>
  </xsl:when>
    
  <xsl:when test="($line_count &gt; ($lpp + $lppws)) and ($line_count &lt; (2*$lpp + $lppws + 1))">
   <xsl:if test="$line_count &lt; (2 * $lpp)">
    <SPAN class="header3">
     <xsl:call-template name="header">
       <xsl:with-param name="showDesc" select="0"/>
       <xsl:with-param name="pageNumber" select="3"/>
       <xsl:with-param name="pageCount" select="3"/>
     </xsl:call-template>          
    </SPAN>    
   </xsl:if>
   <SPAN class="foot3">
     <xsl:call-template name="footer"/>
   </SPAN>
  </xsl:when>        
                                         
  <xsl:when test="($line_count &gt; (2*$lpp + $lppws)) and ($line_count &lt; (3*$lpp + $lppws + 1))">
   <xsl:if test="$line_count &lt; (3 * $lpp)">
    <SPAN class="header4">
     <xsl:call-template name="header">
       <xsl:with-param name="showDesc" select="0"/>
       <xsl:with-param name="pageNumber" select="4"/>
       <xsl:with-param name="pageCount" select="4"/>
     </xsl:call-template>          
    </SPAN>   
   </xsl:if>  
   <SPAN class="foot4">
     <xsl:call-template name="footer"/>
   </SPAN>
  </xsl:when>
                                           
  <xsl:when test="$line_count &gt; (3*$lpp + $lppws)">
   <xsl:if test="$line_count &lt; (4 * $lpp)">
    <SPAN class="header5">
     <xsl:call-template name="header">
       <xsl:with-param name="showDesc" select="0"/>
       <xsl:with-param name="pageNumber" select="5"/>
       <xsl:with-param name="pageCount" select="5"/>
     </xsl:call-template>          
    </SPAN>   
   </xsl:if>  
   <SPAN class="foot5">
     <xsl:call-template name="footer"/>
   </SPAN>
  </xsl:when>
   
</xsl:choose>

<!-- REKAPITULACIA HODIN -->
<DIV style="page-break-after:always;line-height:0px">&#160;</DIV>

<xsl:variable name="splitPPH">
  <xsl:call-template name="str:tokenize">
    <xsl:with-param name="string" select="substring-after($poznamka, 'PPT:&#9;')" />
    <xsl:with-param name="delimiters" select="'#'" />
  </xsl:call-template>
</xsl:variable>

<xsl:variable name="celkomXML">
  <xsl:for-each select="msxsl:node-set($splitPPH)/token">
    <xsl:if test="string-length(.)">
      
      <xsl:variable name="druh" select="substring-before(., ':')"/>
         <!-- druh1, druh2 pridane pre pripad spolocneho fondu DVOCH druhov strojov, JE NEVYHNUTNE, ABY MALI ROVNAKU HODNOTU FAKTURACNEJ SADZBY !! -->
      <xsl:variable name="druh1" select="substring-before($druh, '+')"/>
      <xsl:variable name="druh2" select="substring-after($druh, '+')"/>         

      <xsl:variable name="PPH" select="translate(substring-after(., ':'), ',', '.')"/>      
      <xsl:variable name="VPH">
        <xsl:choose>
          <xsl:when test="contains($druh, '+')">            
            <xsl:variable name="druh1suma" select="sum($hodiny//RS[translate(H[3],' ','') = $druh1]/HN[1])"/>
            <xsl:variable name="druh2suma" select="sum($hodiny//RS[translate(H[3],' ','') = $druh2]/HN[1])"/>
            
            <xsl:value-of select="$druh1suma + $druh2suma"/>           
          </xsl:when>
          <xsl:otherwise>                                                           <!-- + druh = VYKH20, BP, VYKH09 - pridane kvoli tomu, ze nejaky stroj moze byt fakturovany ako iny stroj, napr. VYK6X6 ako VYKH09 -->                                                                                
            <xsl:value-of select="sum($hodiny//RS[translate(H[3],' ','') = $druh]/HN[1]) + (($druh = 'VYKH20') * sum($hodiny//RS[translate(H[3],' ','') = 'VYKH2N']/HN[1])) + (($druh = 'BP') * sum($hodiny//RS[translate(H[3],' ','') = 'BPN']/HN[1])) + (($druh = 'VYKH09') * sum($hodiny//RS[translate(H[3],' ','') = 'VYKHN9']/HN[1]))"/>
          </xsl:otherwise>
        </xsl:choose>  
      </xsl:variable>
                
      <xsl:variable name="ZPH" select="$PPH - $VPH"/>
      <xsl:variable name="SADZBA">
        <xsl:choose>
          <xsl:when test="contains($druh, '+')">    <!-- staci len druh1 (alebo len druh2), kedze sadzba je ta ista -->                   
            <xsl:value-of select="sum($sadzby//R[H[4] = $druh1]/HN[1])"/>           
          </xsl:when>
          <xsl:otherwise>                                        <!-- + druh = VYKH20, VYKH09 - pridane kvoli tomu, ze nejaky stroj moze byt fakturovany ako iny stroj, napr. VYK6X6 ako VYKH09; 
                                                                      BP netreba, lebo je v sadzbach ako BP -->
            <xsl:value-of select="sum($sadzby//R[H[4] = $druh]/HN[1]) + (($druh = 'VYKH20') * sum($sadzby//R[H[4] = 'VYKH2*']/HN[1])) + (($druh = 'VYKH09') * sum($sadzby//R[H[4] = 'VYKH*9']/HN[1]))"/>
          </xsl:otherwise>
        </xsl:choose>  
      </xsl:variable>           
      
      <DRUH>
        <KOD><xsl:value-of select="$druh"/></KOD>
        <NAZOV>
<!--          <xsl:if test="$druh = 'VYKH20'">Vyklápač (20t) s hydraulickou rukou</xsl:if>
          <xsl:if test="$druh = 'VYKH09'">Vyklápač (9t) s hydraulickou rukou</xsl:if> -->
          <xsl:if test="contains($druh, '+')"><xsl:value-of select="$sadzby//R[H[4] = $druh1]/H[5]"/> + <xsl:value-of select="$sadzby//R[H[4] = $druh2]/H[5]"/></xsl:if>
          
          <xsl:value-of select="$sadzby//R[H[4] = $druh]/H[5]"/>
          
          <xsl:if test="not(string-length($sadzby//R[H[4] = $druh]/H[5]))">
            <xsl:if test="$druh = 'VYKH20'">Vyklápač (20t) s hydraulickou rukou</xsl:if>
            <xsl:if test="$druh = 'VYKH09'">Vyklápač (9t) s hydraulickou rukou</xsl:if>          
          </xsl:if>          
        </NAZOV>
        <PREDPOKLAD_HODINY><xsl:value-of select="$PPH"/></PREDPOKLAD_HODINY>
        <PREDPOKLAD_EURA><xsl:value-of select="$PPH * $SADZBA"/></PREDPOKLAD_EURA>
        <VYKON_HODINY><xsl:value-of select="$VPH"/></VYKON_HODINY>
        <VYKON_EURA><xsl:value-of select="$VPH * $SADZBA"/></VYKON_EURA>
        <ZOSTATOK_HODINY><xsl:value-of select="$ZPH"/></ZOSTATOK_HODINY>
        <ZOSTATOK_EURA><xsl:value-of select="$ZPH * $SADZBA"/></ZOSTATOK_EURA>        
      </DRUH>
      
    </xsl:if>
 </xsl:for-each>
</xsl:variable>

<xsl:variable name="pociatokMesiac" select="$pociatky//RS/HN[1]"/>
<xsl:variable name="pociatokRok" select="$pociatky//RS/HN[2]"/>

<TABLE style="font-family:Calibri; font-size:13; border-collapse:collapse; text-align:center">
  <TR>                                                                                        
    <TD colspan="8" style="border-bottom:1px solid black; font-size:14;"><B>Celková rekapitulácia dodaného kameniva</B></TD>
  </TR>
  <TR>                                                                                        
    <TD colspan="8" style="text-align:left; font-size:12">Stavba: <xsl:value-of select="$nazovStavby"/></TD>
  </TR>
  <TR>                                                                                        
    <TD colspan="2" style="text-align:left; font-size:12">Číslo zmluvy: <xsl:value-of select="$objednavka"/></TD>
    <TD colspan="6" style="text-align:left; font-size:12">
      Obdobie: <xsl:value-of select="concat(msxsl:node-set($MonthName)/M[number(@cislo) = $pociatokMesiac], ' ', $pociatokRok)"/>
      <xsl:if test="not(($pociatokMesiac = number($mesiac)) and ($pociatokRok = $rok))"> 
        - <xsl:value-of select="concat(msxsl:node-set($MonthName)/M[@cislo = $mesiac], ' ', $rok)"/>
      </xsl:if>  
    </TD>
  </TR>
  <TR>                                                                                        
    <TD colspan="2" style="height:25px; text-align:left; background-color:lightgrey; border-left:1px dotted black; border-bottom:1px solid black; border-top:1px solid black;"><B>Označenie kameniva</B></TD>
    <TD colspan="2" style="background-color:lightgrey; border-bottom:1px solid black; border-top:1px solid black;"><B>Predpoklad</B></TD>
    <TD colspan="2" style="background-color:lightgrey; border-bottom:1px solid black; border-top:1px solid black;"><B>Dodané</B></TD>
    <TD colspan="2" style="background-color:lightgrey; border-right:1px dotted black; border-bottom:1px solid black; border-top:1px solid black;"><B>Zostatok</B></TD>
  </TR>
                                                                                                                           
  <xsl:for-each select="msxsl:node-set($celkomXML)/DRUH">   
  <TR>                                                                                                                            
    <TD rowspan="2" style="width:190px; border-left:1px dotted black; border-top:1px solid black; border-bottom:1px solid black;"><xsl:value-of select="NAZOV"/></TD>
    <TD style="width:65px; border-top:1px solid black; color:grey; border-right:1px dotted black">Ton</TD>
    
    <TD style="width:100px; border-top:1px solid black;"><xsl:value-of select="format-number(PREDPOKLAD_HODINY,'#0,00','myFormat')"/></TD>
    <TD rowspan="2" style="width:55px; border-top:1px solid black; border-bottom:1px solid black; border-right:1px solid black">100,00 %</TD>
    <TD style="width:100px; border-top:1px solid black; background-color:#F2F2F2"><xsl:value-of select="format-number(VYKON_HODINY,'#0,00','myFormat')"/></TD>
    <TD rowspan="2" style="width:55px; border-top:1px solid black; border-bottom:1px solid black; border-right:1px solid black; background-color:#F2F2F2"><xsl:value-of select="format-number(VYKON_HODINY div PREDPOKLAD_HODINY,'#0,00 %','myFormat')"/></TD>
    <TD style="width:100px; border-top:1px solid black;"><xsl:value-of select="format-number(ZOSTATOK_HODINY,'#0,00','myFormat')"/></TD>
    <TD rowspan="2" style="width:55px; border-top:1px solid black; border-bottom:1px solid black; ; border-right:1px dotted black"><xsl:value-of select="format-number(100.00 - format-number(((VYKON_HODINY div PREDPOKLAD_HODINY) * 100), '#0.00'),'#0,00','myFormat')"/> %</TD>    
  </TR>
    <TR>                                                                                        
<!--    <TD colspan="2" style="text-align:left; background-color:lightgrey; border-left:1px dotted black; border-bottom:1px solid black;"><B>Označenie stavbeného stroja</B></TD> -->
    <TD style="border-top:1px dotted black; border-bottom:1px solid black; color:grey; border-right:1px dotted black">Eur</TD>
    
    <TD style="border-bottom:1px solid black; color:grey; border-top:1px dotted black;"><xsl:value-of select="format-number(PREDPOKLAD_EURA,'### ##0,00 €','myFormat')"/></TD>
    <TD style="border-bottom:1px solid black; color:grey; border-top:1px dotted black; background-color:#F2F2F2"><xsl:value-of select="format-number(VYKON_EURA,'### ##0,00 €','myFormat')"/></TD>
    <TD style="border-bottom:1px solid black; color:grey; border-top:1px dotted black;"><xsl:value-of select="format-number(ZOSTATOK_EURA,'### ##0,00 €','myFormat')"/></TD>    
  </TR>  
<!--   </xsl:if> -->
  </xsl:for-each>
  
  <TR>                                                                                        
    <TD rowspan="2" style="width:190px; background-color:lightgrey; border-left:1px dotted black; border-top:1px solid black; border-bottom:1px solid black;"><B>Celkom za stavbu</B></TD>
    <TD style="width:65px; background-color:lightgrey; border-top:1px solid black; color:grey; border-right:1px dotted black">Ton</TD>
                                                                                               
    <TD style="width:100px; background-color:lightgrey; border-top:1px solid black;"><xsl:value-of select="format-number(sum(msxsl:node-set($celkomXML)/DRUH/PREDPOKLAD_HODINY),'#0,00','myFormat')"/></TD>
    <TD rowspan="2" style="width:55px; background-color:lightgrey; border-top:1px solid black; border-bottom:1px solid black; border-right:1px solid black">100,00 %</TD>
    <TD style="width:100px; background-color:lightgrey; border-top:1px solid black;"><xsl:value-of select="format-number(sum(msxsl:node-set($celkomXML)/DRUH/VYKON_HODINY),'#0,00','myFormat')"/></TD>
    <TD rowspan="2" style="width:55px; background-color:lightgrey; border-top:1px solid black; border-bottom:1px solid black; border-right:1px solid black"><xsl:value-of select="format-number(sum(msxsl:node-set($celkomXML)/DRUH/VYKON_HODINY) div sum(msxsl:node-set($celkomXML)/DRUH/PREDPOKLAD_HODINY),'#0,00 %','myFormat')"/></TD>
    <TD style="width:100px; background-color:lightgrey; border-top:1px solid black;"><xsl:value-of select="format-number(sum(msxsl:node-set($celkomXML)/DRUH/ZOSTATOK_HODINY),'#0,00','myFormat')"/></TD>
    <TD rowspan="2" style="width:55px; background-color:lightgrey; border-top:1px solid black; border-bottom:1px solid black; ; border-right:1px dotted black"><xsl:value-of select="format-number(100.00 - format-number(((sum(msxsl:node-set($celkomXML)/DRUH/VYKON_HODINY) div sum(msxsl:node-set($celkomXML)/DRUH/PREDPOKLAD_HODINY)) * 100), '#0.00'),'#0,00','myFormat')"/> %</TD>    
  </TR>
    <TR>                                                                                        
<!--    <TD colspan="2" style="text-align:left; background-color:lightgrey; border-left:1px dotted black; border-bottom:1px solid black;"><B>Označenie stavbeného stroja</B></TD> -->
    <TD style="background-color:lightgrey; border-top:1px dotted black; border-bottom:1px solid black; color:grey; border-right:1px dotted black">Eur</TD>
    
    <TD style="background-color:lightgrey; border-bottom:1px solid black; color:grey; border-top:1px dotted black;"><xsl:value-of select="format-number(sum(msxsl:node-set($celkomXML)/DRUH/PREDPOKLAD_EURA),'### ##0,00 €','myFormat')"/></TD>
    <TD style="background-color:lightgrey; border-bottom:1px solid black; color:grey; border-top:1px dotted black;"><xsl:value-of select="format-number(sum(msxsl:node-set($celkomXML)/DRUH/VYKON_EURA),'### ##0,00 €','myFormat')"/></TD>
    <TD style="background-color:lightgrey; border-bottom:1px solid black; color:grey; border-top:1px dotted black;"><xsl:value-of select="format-number(sum(msxsl:node-set($celkomXML)/DRUH/ZOSTATOK_EURA),'### ##0,00 €','myFormat')"/></TD>    
  </TR>      
</TABLE>
<!-- END:REKAPITULACIA HODIN -->

</BODY>
</html>
</xsl:template>

<xsl:template name="header">                             <!--*****HEADER*****-->
 <xsl:param name="showDesc"/>
 <xsl:param name="pageNumber"/>
 <xsl:param name="pageCount"/>

<DIV class="obal">

<DIV class="mojlavys">
 
 <xsl:if test="number($pageCount) = 1"><BR/></xsl:if>
  
 <xsl:if test="number($pageCount) &gt; 1">   
  <TABLE style="border-collapse:collapse; font-size:12; margin:-0.05cm,-0.05cm,-0.07cm,-0.05cm"> 
   <TD style="border:2px solid black;width:2.2cm;text-align:center">
   <B><xsl:value-of select="concat('Strana ',$pageNumber,' / ',$pageCount)"/></B>   
   </TD>
  </TABLE>
 </xsl:if>
  
<DIV class="adresad">  
    <img src="..\..\..\Definice\Tisky\FAK\logo.jpg" width="150" height="32" align="right" hspace="6"/>
    <SPAN style="vertical-align:sub"> <B>SONAT, s.r.o.</B> </SPAN>   
    <BR/>
    <BR/>
    Sídlisko Platan 1/2308<BR/>
    931 01 Šamorín<BR/>
    <xsl:if test="not(starts-with(msxsl:node-set($origRoot)//DICOTX,'SK'))">
      Slovensko
    </xsl:if>
  </DIV>
    
  <xsl:if test="starts-with(msxsl:node-set($origRoot)//DICOTX,'SK')"><BR/></xsl:if>  
 
  <TABLE class="icodic" style="font-size:12">    
    <TR><TD>IČ:</TD><TD>47 803 606</TD></TR>  
    <TR><TD>DIČ:</TD><TD>2024101046</TD></TR>
    <TR><TD>IČ DPH:</TD><TD>SK2024101046</TD></TR>
    <TR><TD>&#160;</TD><TD>&#160;</TD></TR>            
    <TR><TD>Úhrada:</TD>
      <xsl:choose>
        <xsl:when test="not(msxsl:node-set($origRoot)//FAH/FU = 'Hotovosť')">
          <TD><xsl:value-of select="substring-before(msxsl:node-set($origRoot)//FAH/FU,',')"/></TD>
        </xsl:when>
        <xsl:otherwise>
          <TD><xsl:value-of select="msxsl:node-set($origRoot)//FAH/FU"/></TD>
        </xsl:otherwise>
      </xsl:choose>  
    </TR>    
  </TABLE>
 
 <TABLE class="icodic" style="font-size:12">
 <xsl:choose>
  <xsl:when test="substring-after(msxsl:node-set($origRoot)//FAH/FU,',') = ' Tatra Banka'">  
    <TR><TD>Účet:</TD><TD style="font-size:14"><B>2922915580/1100</B></TD></TR>
    <TR><TD></TD><TD>IBAN: SK9111000000002922915580</TD></TR>
    <TR><TD></TD><TD>SWIFT: TATRSKBX</TD></TR>
    <TR><TD>Banka:</TD><TD>Tatra banka, a.s.</TD></TR>    
    <TR><TD></TD><TD>Hodžovo námestie 3, Bratislava </TD></TR>
  </xsl:when>
<!--  
  <xsl:when test="substring-after(msxsl:node-set($origRoot)//FAH/FU,',') = ' Volksbank'">
    <TR><TD>Účet:</TD><TD style="font-size:14"><B>4040304402/3100</B></TD></TR>
    <TR><TD></TD><TD>IBAN: SK8731000000004040304402</TD></TR>
    <TR><TD></TD><TD>SWIFT: LUBASKBX</TD></TR>
    <TR><TD>Banka:</TD><TD>VOLKSBANK Slovensko, a.s.</TD></TR>    
    <TR><TD></TD><TD>Vysoká 9, P.O.BOX 81, 810 00, Bratislava </TD></TR>  
  </xsl:when>
-->  
  <xsl:otherwise>
     <TR><TD>&#160;</TD><TD style="font-size:14"><B>&#160;</B></TD></TR>
    <TR><TD></TD><TD>&#160;</TD></TR>
    <TR><TD></TD><TD>&#160;</TD></TR>
    <TR><TD>&#160;</TD><TD>&#160;</TD></TR>    
    <TR><TD></TD><TD>&#160;</TD></TR>
  </xsl:otherwise>   
 </xsl:choose>
 </TABLE>
   
 <BR/>
 <TABLE class="icodic" style="font-size:10"> 
   <TR><TD>OR OS: Trnava  Odd.: Sro, vložka č. 34553/T</TD></TR>
 </TABLE>
 
</DIV> <!-- koniec mojlavys -->
                                                                                                                   
<DIV class="pravyhorny">
  <xsl:variable name="cislo" select="msxsl:node-set($origRoot)//CISF"/>
  <SPAN style="margin-left:-0.2cm;border:1px solid black; border-left:none; border-right:none; background-color:lightgrey"> <B>&#160;&#160;Faktúra - daňový doklad č.: <SPAN style="padding-right:0.4cm;width:5.83cm;text-align:right;font-size:18"><xsl:value-of select="concat(number(substring-before($cislo,'/')), '/', substring-after($cislo,'/'))"/></SPAN></B></SPAN> <BR/>

  <SPAN style="line-height:6px">&#160;</SPAN> <BR/>
     
  Konštantný symbol: 0308 <BR/>
  Variabilný symbol (uvádzajte pri platbe): <B><xsl:value-of select="number(concat(substring-before(msxsl:node-set($origRoot)//CISF,'/'),substring-after(msxsl:node-set($origRoot)//CISF,'/')))"/></B><BR/>
  Objednávka: <SPAN style="width:7.92cm;text-align:right;font-weight:bold"></SPAN>
  
</DIV>

<DIV class="odberatelbox">

  Korešpondenčná adresa:  
  
 <DIV style="padding-left:6mm;padding-top:6mm">
  <B><xsl:value-of select="msxsl:node-set($origRoot)//FAH/OBJEDNAZEV"/></B><BR/>  
  <BR/>
  <xsl:choose>  
   <xsl:when test="string-length(msxsl:node-set($origRoot)//FAH/INFO1) or string-length(msxsl:node-set($origRoot)//FAH/INFO2)">                                                                                              
    <xsl:value-of select="msxsl:node-set($origRoot)//INFO1"/><BR/>
    <xsl:value-of select="msxsl:node-set($origRoot)//INFO2"/><BR/>    
   </xsl:when>
   
   <xsl:otherwise>
    <xsl:value-of select="msxsl:node-set($origRoot)//O1"/><BR/>
    <xsl:value-of select="msxsl:node-set($origRoot)//O2"/>
    
    <xsl:if test="string-length(msxsl:node-set($origRoot)//O3)">, <xsl:value-of select="msxsl:node-set($origRoot)//O3"/>
    </xsl:if>
    
    <BR/>   
   </xsl:otherwise>
  </xsl:choose>    
 </DIV>
  
 <DIV class="botcara9"></DIV>
  
 <DIV>
 
<TABLE style="font-size:13; border-collapse:collapse">
<TR><TD style="width:3.9cm">Odberateľ:</TD><TD style="width:6.5cm"><xsl:value-of select="msxsl:node-set($origRoot)//FAH/OBJEDNAZEV"/></TD></TR>
</TABLE> 
 
<!--   <DIV style="line-height:125%"><SPAN style="width:4cm">Odberateľ:</SPAN> <SPAN style="width:6.4cm"><xsl:value-of select="msxsl:node-set($origRoot)//FAH/OBJEDNAZEV"/></SPAN></DIV> -->
     
   <xsl:if test="string-length(msxsl:node-set($origRoot)//FAH/OBJEDNAZEV) &lt; 38">
    <BR/>
   </xsl:if>
       
   <DIV style="padding-left:2mm;font-size:11">
    <DIV><SPAN style="width:3.8cm">IČO: <xsl:value-of select="msxsl:node-set($origRoot)//PRVNIMATERMASO"/></SPAN><SPAN style="font-size:12"><xsl:value-of select="msxsl:node-set($origRoot)//O1"/></SPAN></DIV>
    <DIV>
      <SPAN style="width:3.8cm">DIČ: 
      <xsl:choose>
        <xsl:when test="starts-with(msxsl:node-set($origRoot)//DICOTX,'SK') or starts-with(msxsl:node-set($origRoot)//DICOTX,'CZ') or starts-with(msxsl:node-set($origRoot)//DICOTX,'HU')">
          <xsl:value-of select="substring(msxsl:node-set($origRoot)//DICOTX,3)"/>          
        </xsl:when>
        <xsl:otherwise>        
          <xsl:value-of select="msxsl:node-set($origRoot)//DICOTX"/>  
        </xsl:otherwise>
      </xsl:choose>
      </SPAN>
      <SPAN style="font-size:12"><xsl:value-of select="msxsl:node-set($origRoot)//O2"/></SPAN> 
    </DIV>
      
    <DIV>
      <SPAN style="width:3.8cm"> IČ DPH: <xsl:value-of select="msxsl:node-set($origRoot)//DICOTX"/></SPAN> 
      <SPAN style="font-size:12"><xsl:value-of select="msxsl:node-set($origRoot)//O3"/></SPAN>
    </DIV>
   </DIV>
     
 </DIV>      
</DIV>

<DIV class="datumybox">
  <SPAN style="width:4.75cm">Dátum vyhotovenia:</SPAN> 
  <xsl:variable name = "df" select="msxsl:node-set($origRoot)//DF" />
  <SPAN style="width:1.9cm"><xsl:value-of select="concat(substring($df,4,2),'.',substring($df,1,2),'.',substring($df,7,4))" /></SPAN>
  Splatnosť najneskôr do:
  
  <BR/>
  <SPAN style="width:4.75cm">Dátum dodania tovaru/služby:</SPAN>
  <xsl:variable name = "dzp" select="msxsl:node-set($origRoot)//DZP" />
  <xsl:variable name = "ds" select="concat(substring(msxsl:node-set($origRoot)//DS,4,2),'.',substring(msxsl:node-set($origRoot)//DS,1,2),'.',substring(msxsl:node-set($origRoot)//DS,7,4))"/>
  <SPAN  style="width:2.65cm"><xsl:value-of select="concat(substring($dzp,4,2),'.',substring($dzp,1,2),'.',substring($dzp,7,4))"/></SPAN>
  <B><SPAN style="font-size:18"><xsl:value-of select="$ds"/></SPAN></B>         
</DIV>

</DIV> <!-- koniec obalu -->
 
<xsl:if test="$faktoring and ($pageNumber = 1)">
 <TABLE style="border-collapse:collapse;font-size:12; margin-left:0.05cm; width:18.87cm; border:2px solid black">
  <TR>
  <TD style="padding:0.15cm 0.20cm 0.1cm 0.20cm">
  Týmto Vám neodvolateľne oznamujeme, že táto pohľadávka bola postúpená factoringovej
  spoločnosti Bibby Factoring Slovakia, a.s., IČO: 36700495. Táto spoločnosť je teda jediná oprávnená
  pohľadávku inkasovať. Pohľadávku preto prosím uhraďte výlučne v prospech účtu tejto spoločnosti č.
  <B>1052377007/1111</B>, UniCredit Bank Czech Republic and Slovakia, a.s., pobočka zahraničnej banky,
  IBAN: SK09 1111 0000 0010 5237 7007, SWIFT CODE: UNCRSKBX. S postúpenou pohľadávkou
  prechádza na nového veriteľa tiež všetko jej príslušenstvo. Váš záväzok zaniká len jeho splnením tejto spoločnosti.
  </TD>
  </TR>  
 </TABLE>
 <BR/>
</xsl:if> 
 
<xsl:variable name="popisPl" select="msxsl:node-set($origRoot)//FAH/POPISPL"/>
<xsl:choose>
 <xsl:when test="$showDesc">  
  <xsl:choose>
   <xsl:when test="string-length($popisPl)">
    <DIV class="botcara18" style="font-size:12;line-height:125%">Fakturujeme Vám za <xsl:value-of select="$popisPl"/></DIV> 
   </xsl:when>                                                                                                                          
   <xsl:otherwise>                                                
     <DIV class="botcara18" style="font-size:12;line-height:125%">
       <xsl:if test="$medziskladka != 0">Fakturujeme Vám za dodaný materiál (kamenivo, štrky, piesky) vrátane dopravy pre stavbu</xsl:if>
       <xsl:if test="$medziskladka = 0">Fakturujeme Vám za dodaný materiál (kamenivo, štrky, piesky) vrátane dopravy pre medziskládku (vrátane okruhu 5 km)</xsl:if> 
       <B><xsl:value-of select="$nazovStavby"/></B> za obdobie <B><xsl:value-of select="concat(msxsl:node-set($MonthName)/M[@cislo = $mesiac], ' ', $rok)"/></B>: <!-- <xsl:value-of select="$line_count"/> / <xsl:value-of select="$faktoring * 1"/> faktoring--> 
     </DIV> 
   </xsl:otherwise> 
  </xsl:choose>
 </xsl:when>
 <xsl:otherwise>
 <DIV class="botcara18" style="font-size:12;line-height:125%">&#160;</DIV>
</xsl:otherwise>
</xsl:choose> 

<DIV class="botcara18" style="font-size:11;text-align:right">
<PRE style="background-color:lightgrey"><B>                                                  Cena za jedn. Cena celkom Sadzba   Suma Cena celkom</B></PRE>
<PRE style="background-color:lightgrey"><B>Názov / popis                              Mn./j. v EUR bez DPH   bez DPH    DPH      DPH       s DPH</B></PRE>
</DIV>
</xsl:template>

<xsl:template name="footer">                             <!--*****FOOTER*****-->
Faktúra slúži aj ako dodací list.
<!-- suctova tabulka: zaciatok -->
<!--
<xsl:variable name="pred_zaklad" select="number(format-number(sum(msxsl:node-set($suma)/RIADOK/ZAKLAD),'#0.000'))"/>
<xsl:variable name="zaklad_n" select="number(format-number($pred_zaklad,'#0.00'))"/>
<xsl:variable name="dan_n" select="number(format-number((//FER/DPH * 0.01) * $zaklad_n,'#0.00'))"/>
-->

<!--*.*-->
<xsl:variable name="zaklad_n">
  <xsl:if test="$staryFormat"><xsl:variable name="pred_zaklad" select="number(format-number(sum(msxsl:node-set($suma)/RIADOK/ZAKLAD),'#0.000'))"/>
  <xsl:value-of select="number(format-number($pred_zaklad,'#0.00'))"/></xsl:if>
  
  <xsl:if test="not($staryFormat)"><xsl:value-of select="number(format-number(sum(msxsl:node-set($suma)/RIADOK/ZAKLAD),'#0.00'))"/></xsl:if>
</xsl:variable>

<xsl:variable name="dan_n">
  <xsl:if test="$staryFormat"><xsl:value-of select="number(format-number((//FER/DPH * 0.01) * $zaklad_n,'#0.00'))"/></xsl:if>
  <xsl:if test="not($staryFormat)"><xsl:value-of select="number(format-number(sum(msxsl:node-set($suma)/RIADOK/DAN),'#0.00'))"/></xsl:if>
</xsl:variable>
<!-- *** *** *** ***-->

<xsl:variable name="spolu_n" select="$zaklad_n + $dan_n"/>
<xsl:variable name="zaloha_n" select="sum(//FEH/FER[SAZEBNIK = 'Z']/KC) + sum(//FEH/FER[SAZEBNIK = 'Z']/DPHDAN)"/>

<xsl:variable name="kUhrade" select="format-number($spolu_n + $zaloha_n,'#0,00','myFormat')"/>  <!-- zaloha je vo fakture so znamienkom -, cize tu je + -->

<xsl:variable name="kUhradeSlovom">
    <xsl:variable name="intPart">
      <xsl:call-template name="int2word">
        <xsl:with-param name="in-integer" select="substring-before($kUhrade,',')"/>
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:variable name="intPartCap" select="concat(translate(substring($intPart,1,1),$smallcase,$uppercase), substring($intPart,2))"/>
    
    <xsl:call-template name="make_SK_changes">
      <xsl:with-param name="text" select="$intPartCap"/>
    </xsl:call-template> EUR
      
    <xsl:if test="substring-after($kUhrade,',') != '00'"> 
      <xsl:value-of select="concat(' + ', number(substring-after($kUhrade,',')), '/100')"/>
    </xsl:if>     
</xsl:variable>

<xsl:variable name="zaklad" select="format-number($zaklad_n,'### ##0,00','myFormat')"/>
<xsl:variable name="dan" select="format-number($dan_n,'### ##0,00','myFormat')"/>
<xsl:variable name="spolu" select="format-number($spolu_n,'### ##0,00','myFormat')"/>
<xsl:variable name="zaloha" select="format-number(-1 * $zaloha_n,'### ##0,00','myFormat')"/>

<DIV style="margin:0.49cm,0cm,0.3cm,4cm">
  <TABLE style="border-collapse:collapse">
    <TR><TD></TD><TD style="border:1px solid black"><B><PRE>                        Čiastky v EUR           </PRE></B></TD></TR>       
    <TR><TD></TD><TD style="border:1px solid black"><B><PRE>              Bez DPH            DPH      Celkom</PRE></B></TD></TR>
    
    <TR><TD style="border:1px solid black;font-size:11"><PRE> Celkom s <xsl:value-of select="//FER/DPH"/>% DPH</PRE></TD><TD style="border:1px solid black;text-align:right">
    <PRE><SPAN style="width:4.45cm"><xsl:value-of select="$zaklad"/></SPAN><SPAN style="width:3.2cm"><xsl:value-of select="$dan"/></SPAN><SPAN style="width:2.52cm"><xsl:value-of select="$spolu"/></SPAN></PRE></TD></TR>
           
    <TR><TD style="border:1px solid black;font-size:11"><PRE> Celková suma</PRE></TD><TD style="border:1px solid black;text-align:right">
    <PRE><SPAN style="width:4.45cm"><xsl:value-of select="$zaklad"/></SPAN><SPAN style="width:3.2cm"><xsl:value-of select="$dan"/></SPAN><SPAN style="width:2.52cm"><xsl:value-of select="$spolu"/></SPAN></PRE></TD></TR>
        
    <TR><TD style="border:1px solid black;font-size:11"><PRE> Uhradené zálohami</PRE></TD><TD align="right" style="border:1px solid black"><PRE><xsl:value-of select="$zaloha"/></PRE></TD></TR>
                                                  
    <TR>
    <TD style="border:2px solid black;font-size:14;border-right:none;background-color:lightgrey"><B><PRE> K úhrade</PRE></B></TD>
    <TD align="right" style="border:2px solid black;font-size:18;padding-right:2mm;background-color:lightgrey;border-left:none"><B><xsl:value-of select="format-number(number(translate($kUhrade,',','.')),'### ##0,00','myFormat')"/> EUR</B><BR/>
    <SPAN style="font-size:11;font-style:italic"><xsl:value-of select="$kUhradeSlovom"/></SPAN></TD></TR>
  </TABLE>
</DIV>
<!-- suctova tabulka: koniec -->

<SPAN style="padding-left:1.5cm"> Vystavil(a): <xsl:value-of select="substring-after(//FAH/FAKTURANT,' ')"/> </SPAN> 
<SPAN style="padding-left:5cm"> Prevzal(a), dňa: </SPAN>
<BR/>
<BR/>
<BR/>
<BR/>
<BR/>
<!-- pridanane kvoli vacsej peciatke -->
<BR/>
<BR/>
<BR/>
<!-- end: pridanane kvoli vacsej peciatke -->
<SPAN style="line-height:23%"><BR/></SPAN>
<DIV class="botcara18" style="font-size:10">  
V prípade omeškania úhrady po lehote splatnosti, vzniká  nárok na úrok z omeškania a náhradu škody v zákonom stanovenej výške. 
Prevzatím vystavenej faktúry odberateľ potvrdzuje, že predmetné dodávky boli vykonané v súlade s dohodnutými podmienkami a vyjadruje
súhlas s podmienkou úhrady a považuje ju za záväznú. V prípade rozporu s dohodnutými podmienkami dodávky, Vás žiadame o vrátenie predmetnej 
faktúry s písomným odôvodnením.
</DIV>
<SPAN style="width:7.4cm;padding-left:3mm;font-size:11">Telefón: <xsl:value-of select="//FAH/TELEFON"/></SPAN>
<SPAN style="width:8cm;font-size:11">E-mail: <xsl:value-of select="//FAH/UZIV_EMAIL"/></SPAN>
<!-- <SPAN style="font-size:11">Web: www.sonat.sk</SPAN> -->
</xsl:template>

<xsl:template name="make_SK_changes">
  <xsl:param name="text"/>

  <xsl:choose>
    <xsl:when test="starts-with($text,'Jedensto')">
      <xsl:value-of select="'Jednosto'"/>      
      <xsl:call-template name="make_SK_changes">
        <xsl:with-param name="text" select="substring-after($text,'Jedensto')"/>
      </xsl:call-template>
    </xsl:when>
    
    <xsl:when test="starts-with($text,'Dvasto')">
      <xsl:value-of select="'Dvesto'"/>      
      <xsl:call-template name="make_SK_changes">
        <xsl:with-param name="text" select="substring-after($text,'Dvasto')"/>
      </xsl:call-template>
    </xsl:when>

    <xsl:when test="starts-with($text,'Dvatisíc')">
      <xsl:value-of select="'Dvetisíc'"/>      
      <xsl:call-template name="make_SK_changes">
        <xsl:with-param name="text" select="substring-after($text,'Dvatisíc')"/>
      </xsl:call-template>
    </xsl:when>    
    
    <xsl:when test="contains($text,'jedensto')">
      <xsl:value-of select="substring-before($text,'jedensto')"/>
      <xsl:value-of select="'sto'"/>      
      <xsl:call-template name="make_SK_changes">
        <xsl:with-param name="text" select="substring-after($text,'jedensto')"/>
      </xsl:call-template>
    </xsl:when>
    
    <xsl:when test="contains($text,'dvasto')">
      <xsl:value-of select="substring-before($text,'dvasto')"/>
      <xsl:value-of select="'dvesto'"/>      
      <xsl:call-template name="make_SK_changes">
        <xsl:with-param name="text" select="substring-after($text,'dvasto')"/>
      </xsl:call-template>
    </xsl:when>    
           
    <xsl:otherwise>
      <xsl:value-of select="$text"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="chars">
  <xsl:param name="text"/>
  <xsl:param name="counter"/>
  <xsl:param name="fulltext"/>
  <xsl:param name="lineNum"/>  
  
  <xsl:if test="$text != ''">
  
    <xsl:variable name="letter" select="substring($text, 1, 1)"/>
    <xsl:variable name="remainStr" select="substring-after($text, $letter)"/>
    
    <xsl:choose>  
      <xsl:when test="( ($letter = ',') and ( (string-length(substring($fulltext,1,$counter)) + string-length(substring-before($remainStr,',')) + 1) &gt; 107 ) ) or ($remainStr = '')">                                                                                     
        <CH>
				  <xsl:attribute name="eol">true</xsl:attribute>
				  <xsl:attribute name="lineNum"><xsl:value-of select="$lineNum"/></xsl:attribute>
          <xsl:value-of select="$letter"/>
        </CH>
        
        <xsl:call-template name="chars">
          <xsl:with-param name="text" select="$remainStr"/>
          <xsl:with-param name="counter" select="0 + 1"/>
          <xsl:with-param name="fulltext" select="$remainStr"/>
          <xsl:with-param name="lineNum" select="$lineNum + 1"/>      
        </xsl:call-template>             
      </xsl:when>
    
      <xsl:otherwise>
        <CH><xsl:value-of select="$letter"/></CH>
        
        <xsl:call-template name="chars">
          <xsl:with-param name="text" select="$remainStr"/>
          <xsl:with-param name="counter" select="$counter + 1"/>
          <xsl:with-param name="fulltext" select="$fulltext"/>
          <xsl:with-param name="lineNum" select="$lineNum"/>                
        </xsl:call-template>
      </xsl:otherwise>    
    </xsl:choose>  
    
  </xsl:if>  
</xsl:template>

</xsl:stylesheet>