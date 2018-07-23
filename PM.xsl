<?xml version="1.0" encoding="Windows-1250"?>
<xsl:stylesheet version="1.0" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
 xmlns:msxsl="urn:schemas-microsoft-com:xslt">

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

<xsl:import href="./Int2Word/int2word.xslt"/>
<xsl:decimal-format name="myFormat" decimal-separator="," grouping-separator=" " NaN="0,00"/>
<xsl:output method="html" encoding="windows-1250"/>
	
<!-- ***** VARIABLES START*****-->	
<xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyzš'" />
<xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZŠ'" />

<xsl:variable name="staryFormat" select="concat(substring(//FAH/DF,7,4), substring(//FAH/DF,1,2)) &lt;= '201705'"/>

<xsl:variable name="lpp">54</xsl:variable>                 <!--LINES PER PAGE--><!-- LINE = INDIVIDUAL ROW-->
<xsl:variable name="lppws">26</xsl:variable>  <!--LINES PER PAGE WITH SUMMARY-->   <!-- povodne 29 -->

<xsl:variable name="origRoot" select="/"/>    <!--*****ORIGINAL XML ROOT*****-->

<!--                                              *****SORTED XML*****                                    
<xsl:variable name="sortedXml">                      
  <xsl:for-each select="//FER">           
    <xsl:sort select="concat(SAZEBNIK, SAZBA)" data-type="text" order="ascending"/>  
       <RIADOK>             
         <xsl:copy-of select="."/>                       
         <CISLO_OBJ>
           <xsl:choose>
             <xsl:when test="not(string-length(../OBJEDINFO1) = 0) and not(../OBJEDINFO1 = ../MATERINFO1)">
               <xsl:value-of select="../OBJEDINFO1"/>
             </xsl:when>
             <xsl:otherwise>
               <xsl:value-of select="SAZBA_POZNAMKA"/>
             </xsl:otherwise> 
           </xsl:choose>
         </CISLO_OBJ>                                                                       
       </RIADOK>
  </xsl:for-each>
</xsl:variable>    -->

<xsl:variable name="sortedXml">                      
  <xsl:for-each select="//FER">           
    <xsl:sort select="concat(SAZEBNIK, SAZBA)" data-type="text" order="ascending"/>            
    
       <RIADOK>             
         <xsl:copy-of select="."/>
         
         <!-- #: spojenie sadzby za material (X..) so sadzbou za dopravu -->
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
         <!-- #: end --> 
         
         <CISLO_OBJ>
           <xsl:choose>
             <xsl:when test="not(string-length(../OBJEDINFO1) = 0) and not(../OBJEDINFO1 = ../MATERINFO1)">
               <xsl:value-of select="../OBJEDINFO1"/>
             </xsl:when>
             <xsl:otherwise>
               <xsl:value-of select="SAZBA_POZNAMKA"/>
             </xsl:otherwise> 
           </xsl:choose>
         </CISLO_OBJ>                                                                       
       </RIADOK>
       
  </xsl:for-each>
</xsl:variable>

  
<xsl:variable name="suma">                             <!--*****SUMA XML*****-->
 <xsl:for-each select="msxsl:node-set($sortedXml)/RIADOK[not(concat(FER/SAZEBNIK, MSADZBA) = concat(preceding-sibling::RIADOK[1]/FER/SAZEBNIK, preceding-sibling::RIADOK[1]/MSADZBA)) and starts-with(FER/SAZEBNIK, 'X')]">          
  <xsl:variable name="subkod" select="concat(FER/SAZEBNIK, MSADZBA)"/>  
<!--
  <xsl:variable name="pocJedn" select="sum(//RIADOK[concat(FER/SAZEBNIK, MSADZBA) = $subkod]/FER/POCETJED)"/>
  <xsl:variable name="sumaBezDane" select="number(format-number(MSADZBA * $pocJedn,'#0.000'))"/>
-->

  <xsl:variable name="sumaBezDane">
    <xsl:if test="$staryFormat"><xsl:variable name="pocJedn" select="sum(//RIADOK[concat(FER/SAZEBNIK, MSADZBA) = $subkod]/FER/POCETJED)"/>
    <xsl:value-of select="number(format-number(MSADZBA * $pocJedn,'#0.000'))"/></xsl:if>    
    <xsl:if test="not($staryFormat)"><xsl:value-of select="number(format-number(sum(//RIADOK[concat(FER/SAZEBNIK, MSADZBA) = $subkod]/FER/KC), '#0.00'))"/></xsl:if>    
  </xsl:variable>
  
  <!-- netreba rozlisovat stary a novy format, lebo pri starom sa nod DAN nepouziva a preto nevadi, ze sa tam da to, co plati pre novy format -->
  <xsl:variable name="sumaDane" select="number(format-number(sum(//RIADOK[concat(FER/SAZEBNIK, MSADZBA) = $subkod]/FER/DPHDAN), '#0.000'))"/>
          
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
 <xsl:for-each select="msxsl:node-set($sortedXml)/RIADOK[not(concat(FER/SAZEBNIK, MSADZBA) = concat(preceding-sibling::RIADOK[1]/FER/SAZEBNIK, preceding-sibling::RIADOK[1]/MSADZBA)) and starts-with(FER/SAZEBNIK, 'X')]">  
  <xsl:variable name="subkod" select="concat(FER/SAZEBNIK, MSADZBA)"/>
 
  <xsl:variable name="sortedXmlObjedinfo">                      
   <xsl:for-each select="msxsl:node-set($sortedXml)/RIADOK[concat(FER/SAZEBNIK, MSADZBA) = $subkod]">           
    <xsl:sort select="CISLO_OBJ" data-type="text" order="ascending"/>                      
      <xsl:copy-of select="."/>             
   </xsl:for-each>
  </xsl:variable>
  
  <xsl:variable name="sortedXmlDatum">                      
   <xsl:for-each select="msxsl:node-set($sortedXml)/RIADOK[concat(FER/SAZEBNIK, MSADZBA) = $subkod]">           
    <xsl:sort select="concat(substring(FER/DATUM,7),substring(FER/DATUM,1,2),substring(FER/DATUM,4,2))" data-type="text" order="ascending"/>                      
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
     
  <RIADOK>                    
   <LINE>                 
    <xsl:value-of select="1 + $ObjLineCount + count(msxsl:node-set($sortedXmlDatum)/RIADOK[not(FER/DATUM = preceding-sibling::RIADOK[1]/FER/DATUM)])"/>                                         
   </LINE>                                                                                                                                                               
  </RIADOK>                                                                    
 </xsl:for-each>
</xsl:variable>   
                                             <!--*****INVOICE LINE COUNT*****--> 
<xsl:variable name="line_count" select="sum(msxsl:node-set($lineCountXml)/RIADOK/LINE)"/>

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
<!-- test MSADZBA
<xsl:for-each select="msxsl:node-set($sortedXml)/RIADOK">
<xsl:value-of select="concat(FER/SAZEBNIK, '.',position())"/> : <xsl:value-of select="MSADZBA"/><BR/>
</xsl:for-each>
-->

<xsl:call-template name="header">
 <xsl:with-param name="showDesc" select="1"/>
 <xsl:with-param name="pageNumber" select="1"/>
 <xsl:with-param name="pageCount" select="$pageCount"/>
</xsl:call-template>

<!-- jednotlivé výkony uvedené ve faktuře -->
  
<xsl:for-each select="msxsl:node-set($sortedXml)/RIADOK[not(concat(FER/SAZEBNIK, MSADZBA) = concat(preceding-sibling::RIADOK[1]/FER/SAZEBNIK, preceding-sibling::RIADOK[1]/MSADZBA)) and starts-with(FER/SAZEBNIK, 'X')]">  
 <xsl:variable name="subkod" select="concat(FER/SAZEBNIK, MSADZBA)"/> 
 <xsl:variable name="pocJedn" select="sum(//RIADOK[concat(FER/SAZEBNIK, MSADZBA) = $subkod]/FER/POCETJED)"/>
<!-- 
 <xsl:variable name="sumaBezDane" select="number(format-number(MSADZBA * $pocJedn,'#0.000'))"/>
 <xsl:variable name="sumaDane" select="number(format-number((FER/DPH * 0.01) * $sumaBezDane,'#0.000'))"/>
-->

  <xsl:variable name="sumaBezDane">
    <xsl:if test="$staryFormat"><xsl:value-of select="number(format-number(MSADZBA * $pocJedn,'#0.000'))"/></xsl:if>    
    <xsl:if test="not($staryFormat)"><xsl:value-of select="number(format-number(sum(//RIADOK[concat(FER/SAZEBNIK, MSADZBA) = $subkod]/FER/KC), '#0.00'))"/></xsl:if>    
  </xsl:variable>                                          
  
  <!-- treba rozlisovat stary a novy format -->
  <xsl:variable name="sumaDane"> 
    <xsl:if test="$staryFormat"><xsl:value-of select="number(format-number((FER/DPH * 0.01) * $sumaBezDane,'#0.000'))"/></xsl:if>    
    <xsl:if test="not($staryFormat)"><xsl:value-of select="number(format-number(sum(//RIADOK[concat(FER/SAZEBNIK, MSADZBA) = $subkod]/FER/DPHDAN), '#0.000'))"/></xsl:if>                                          
  </xsl:variable>
 
 <xsl:variable name="pos" select="position()"/>
 <xsl:variable name="LineCountSoFar" select="sum(msxsl:node-set($lineCountXml)/RIADOK[position() &lt; $pos]/LINE)"/>
       
 <DIV class="botcara18">  
    <DIV class="popis" style="font-size:11;line-height:12px;width:8.74cm">
    <B>
      <xsl:choose>
        <xsl:when test="starts-with(FER/SAZEBNIKNAZ, 'Ostat.')">
          <xsl:value-of select="substring-before(substring(FER/SAZEBNIKNAZ, 17), '(')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="substring-before(FER/SAZEBNIKNAZ, '(')"/>
        </xsl:otherwise>
      </xsl:choose>
    </B>   
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
			<xsl:value-of select="format-number(MSADZBA,'### ##0,000','myFormat')"/>
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
   
  <xsl:variable name="sortedXmlObjedinfo">            <!-- concat(NAKLADKA, VYKLADKA, FER/SAZEBNIK, MSADZBA, SPZ) = $subkod -->        
   <xsl:for-each select="msxsl:node-set($sortedXml)/RIADOK[concat(FER/SAZEBNIK, MSADZBA) = $subkod]">           
    <xsl:sort select="CISLO_OBJ" data-type="text" order="ascending"/>                      
      <xsl:copy-of select="."/>             
   </xsl:for-each>
  </xsl:variable>
  
  <xsl:variable name="sortedXmlDatum">                <!-- concat(NAKLADKA, VYKLADKA, FER/SAZEBNIK, MSADZBA, SPZ) = $subkod -->      
   <xsl:for-each select="msxsl:node-set($sortedXml)/RIADOK[concat(FER/SAZEBNIK, MSADZBA) = $subkod]">           
    <xsl:sort select="concat(substring(FER/DATUM,7),substring(FER/DATUM,1,2),substring(FER/DATUM,4,2))" data-type="text" order="ascending"/>                      
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
    
    <xsl:if test="(($LineCountSoFar+2) mod $lpp) = 0">           
     <div style="page-break-after:always;line-height:0px">&#160;</div>
     <xsl:call-template name="header">
      <xsl:with-param name="showDesc" select="0"/>
      <xsl:with-param name="pageNumber" select="1 + (($LineCountSoFar+2) div $lpp)"/>
      <xsl:with-param name="pageCount" select="$pageCount"/>     
     </xsl:call-template>
    </xsl:if>
-->
<!-- vypis cisel objednavok-->
                
   <SPAN style="font-size:10;line-height:10px;font-style:italic;width:1.7cm; color:#4D4D4D">    
    č.objednávky:
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

<!-- vypis dni-->
      
    <xsl:for-each select="msxsl:node-set($sortedXmlDatum)/RIADOK[not(FER/DATUM = preceding-sibling::RIADOK[1]/FER/DATUM)]">                                 
      <xsl:variable name="datum" select="FER/DATUM"/>
      <xsl:variable name="poz" select="position()"/>
      
       <SPAN style="font-size:10;line-height:12px;font-style:italic; color:#4D4D4D">              
        <xsl:value-of select="concat(substring(FER/DATUM,4,2),'.',substring(FER/DATUM,1,2),'.',substring(FER/DATUM,7))"/><xsl:text>: </xsl:text>
               
        <xsl:for-each select="msxsl:node-set($sortedXmlDatum)/RIADOK/FER[DATUM = $datum]">   <!-- vypis hmotnosti v dni-->
          <xsl:if test="not(position() = 1)">+</xsl:if>          
          <xsl:value-of select="format-number(POCETJED,'#0,00','myFormat')"/>
          <xsl:if test="(position() = 21) and not(position() = last())">+<BR/></xsl:if>
          <xsl:if test="(position() = 21) and (position() = last())">=<BR/></xsl:if>
        </xsl:for-each>
        
        <xsl:choose>
          <xsl:when test="count(msxsl:node-set($sortedXmlDatum)/RIADOK/FER[DATUM = $datum]) = 1">
            <xsl:text> </xsl:text><xsl:value-of select="msxsl:node-set($sortedXmlDatum)/RIADOK/FER[DATUM = $datum]/JEDNOTKA"/>  
            <BR/>            
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>=</xsl:text>
            <xsl:value-of select="format-number(sum(msxsl:node-set($sortedXmlDatum)/RIADOK/FER[DATUM = $datum]/POCETJED),'#0,00','myFormat')"/>
            <xsl:text> </xsl:text><xsl:value-of select="msxsl:node-set($sortedXmlDatum)/RIADOK/FER[DATUM = $datum]/JEDNOTKA"/>  
            <BR/>          
          </xsl:otherwise>
        </xsl:choose>                                                                                                                  <!--koniec vypisu hmotnosti v dni-->
       </SPAN>              

<!--       <xsl:variable name="ObjLineCount" select="count(msxsl:node-set($ObjCharsXml)/CH[@eol='true'])"/> -->

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
                                                                     
       <xsl:if test="$poz &lt; last()">
        <xsl:if test="(($LineCountSoFar+1+$ObjLineCount+$poz) mod $lpp) = 0">        <!-- nie je riadok ECV, takze +2+ sa meni na +1+ -->           
         <div style="page-break-after:always;line-height:0px">&#160;</div>
         <xsl:call-template name="header">
          <xsl:with-param name="showDesc" select="0"/>
          <xsl:with-param name="pageNumber" select="1 + (($LineCountSoFar+1+$ObjLineCount+$poz) div $lpp)"/>     <!-- nie je riadok ECV, takze +2+ sa meni na +1+ -->
          <xsl:with-param name="pageCount" select="$pageCount"/>     
         </xsl:call-template>         
        </xsl:if>
       </xsl:if>       
    </xsl:for-each>                                                                                                                    <!--koniec vypisu dni-->                     
                                                             
 </DIV>

 <xsl:variable name="LineCountSoFarInc" select="sum(msxsl:node-set($lineCountXml)/RIADOK[position() &lt; $pos+1]/LINE)"/>   <!-- including current RIADOK-->
  
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

<xsl:variable name="popisPl" select="msxsl:node-set($origRoot)//FAH/POPISPL"/>
<xsl:choose>
 <xsl:when test="$showDesc">
  <xsl:choose>
   <xsl:when test="string-length($popisPl)">
    <DIV class="botcara18" style="font-size:12;line-height:125%">Fakturujeme Vám za <xsl:value-of select="$popisPl"/></DIV>
   </xsl:when>
   <xsl:otherwise>
    <DIV class="botcara18" style="font-size:12;line-height:125%">Fakturujeme Vám za dodaný materiál (v mieste nakládky, bez dopravy):</DIV>
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