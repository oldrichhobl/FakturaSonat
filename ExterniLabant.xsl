<?xml version="1.0" encoding="Windows-1250"?>
<xsl:stylesheet version="1.0" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
 xmlns:msxsl="urn:schemas-microsoft-com:xslt">

<!-- 
	<INFO>
		<SUBJECT> Faktúra na A4 </SUBJECT>
		<AUTHOR> Peter Kramář </AUTHOR>
		<EMAIL>hobl@hoblapech.cz</EMAIL>
		<VERSION></VERSION>
	</INFO>
	<ORIGIN>
		<PODNIK> Labant </PODNIK>
		<DATE></DATE>
		<SESTAVAN></SESTAVAN>
		<POPIS></POPIS>
		<HIST>      
		</HIST>
	</ORIGIN>
-->


<xsl:decimal-format name="myFormat" decimal-separator="," grouping-separator="." NaN="0,00"/>
<xsl:output method="html" encoding="windows-1250"/>
	
<!-- ***** VARIABLES START*****-->	
<xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyzš'" />
<xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZŠ'" />

<xsl:variable name="reverseText" >
 <xsl:choose>
   <xsl:when test="//FAH/OBJEDMASKA = 'ESK'">
Miestom dodania služby je SK 
   </xsl:when>
   <xsl:when test="//FAH/OBJEDMASKA = 'EAT'">
Miestom dodania služby je Rakusko podľa § 15 Zák. č. 222/2004 Z.z.  Služba
je oslobodená od DPH , daň je povinný zaplatiť odberateľ. Prenesená daňová
povinnosť - Reverse charge ." 
   </xsl:when>
   <xsl:when test="//FAH/OBJEDMASKA = 'EBE'">
Miestom dodania služby je Belgicko podľa § 15 Zák. č. 222/2004 Z.z.  Služba
je oslobodená od DPH , daň je povinný zaplatiť odberateľ. Prenesená daňová
povinnosť - Reverse charge ." 
   </xsl:when>
   <xsl:when test="//FAH/OBJEDMASKA = 'ECZ'">
Miestom dodania služby je Cesko podľa § 15 Zák. č. 222/2004 Z.z.  Služba
je oslobodená od DPH , daň je povinný zaplatiť odberateľ. Prenesená daňová
povinnosť - Reverse charge ." 
   </xsl:when>
   <xsl:when test="//FAH/OBJEDMASKA = 'EDE'">
Miestom dodania služby je Nemecko podľa § 15 Zák. č. 222/2004 Z.z.  Služba
je oslobodená od DPH , daň je povinný zaplatiť odberateľ. Prenesená daňová
povinnosť - Reverse charge ." 
   </xsl:when>
   <xsl:when test="//FAH/OBJEDMASKA = 'EDK'">
Miestom dodania služby je Dansko podľa § 15 Zák. č. 222/2004 Z.z.  Služba
je oslobodená od DPH , daň je povinný zaplatiť odberateľ. Prenesená daňová
povinnosť - Reverse charge ." 
   </xsl:when>
   <xsl:when test="//FAH/OBJEDMASKA = 'EEE'">
Miestom dodania služby je EEE podľa § 15 Zák. č. 222/2004 Z.z.  Služba
je oslobodená od DPH , daň je povinný zaplatiť odberateľ. Prenesená daňová
povinnosť - Reverse charge ." 
   </xsl:when>
   <xsl:when test="//FAH/OBJEDMASKA = 'EFR'">
Miestom dodania služby je Francuzsko podľa § 15 Zák. č. 222/2004 Z.z.  Služba
je oslobodená od DPH , daň je povinný zaplatiť odberateľ. Prenesená daňová
povinnosť - Reverse charge ." 
   </xsl:when>
   <xsl:when test="//FAH/OBJEDMASKA = 'EHU'">
Miestom dodania služby je Madarsko podľa § 15 Zák. č. 222/2004 Z.z.  Služba
je oslobodená od DPH , daň je povinný zaplatiť odberateľ. Prenesená daňová
povinnosť - Reverse charge ." 
   </xsl:when>
   <xsl:when test="//FAH/OBJEDMASKA = 'EIT'">
Miestom dodania služby je Taliansko podľa § 15 Zák. č. 222/2004 Z.z.  Služba
je oslobodená od DPH , daň je povinný zaplatiť odberateľ. Prenesená daňová
povinnosť - Reverse charge ." 
   </xsl:when>
   <xsl:when test="//FAH/OBJEDMASKA = 'EPL'">
Miestom dodania služby je Polsko podľa § 15 Zák. č. 222/2004 Z.z.  Služba
je oslobodená od DPH , daň je povinný zaplatiť odberateľ. Prenesená daňová
povinnosť - Reverse charge ." 
   </xsl:when>
 <xsl:otherwise>
 </xsl:otherwise> 
 </xsl:choose>
</xsl:variable>


<!-- Strankovani -->
<!-- ************  PODPORA STRANKOVANI *************** -->
	<xsl:variable name="debug" select="false()"/>

	<!-- *********   nastavení systému stránkování **************    -->
	
        <!-- pocet radek kdy se jeste vejde na prvni stranu souctopodpis -->
	<xsl:variable name="maxradek1" select="14"/>
        <!-- pocet radek na prvni stranu bez souctopodpisu -->
	<xsl:variable name="max2radek1" select="24"/>
	<!-- max. pocet radek na 2. a dalsich stranach -->
	<xsl:variable name="radekn" select="24"/>
	<!-- max. pocet radek na 2. a dalsich stranach vcetne footru -->
	<xsl:variable name="maxradekn" select="14"/>
	
	<!-- *** R O Z M E R Y   bloků na stránkách v cm  *** -->
	<!-- vyska stranky -->
	<xsl:variable name="hpage" select="26.5"/>
	<!-- cele zahlavi prvni stranky -->
	<xsl:variable name="head1" select="11.2"/>
	<!-- zahlavi druhe a dalsi stranky -->
	<xsl:variable name="head2" select="1.5"/>
	<!-- vyska souctu a kecu pod souctem -->
	<xsl:variable name="hsum" select="6.0"/>
	<!-- vyska paticky podpisu atd -->
	<xsl:variable name="hfoot" select="0.5"/>

	<!-- vyska radky zakladni nemenna -->
	<xsl:variable name="hrx" select="0.41"/>

	<!-- CElkovy pocet vykonovych radek -->
	<xsl:variable name="pocetr" select="count(//RADKY/FEH) + count(//RADKY/FEH/FER)"/>

	<!-- Predbezny pocet radek na prvni strane -->
	<xsl:variable name="radekX" >
	 <xsl:if test="$pocetr &lt;= $max2radek1">
	  <xsl:value-of select="$pocetr"/>
	 </xsl:if>
	 <xsl:if test="$pocetr &gt; $max2radek1">
	  <xsl:value-of select="$max2radek1"/>
	 </xsl:if>  
	</xsl:variable>
	<!-- test pocet radek na prvni strane -->
	<xsl:variable name="radekY" >
	  <!-- kouknem na posledni radku zda to neni FEH to bychom museli odstrankovat drive-->
	  <xsl:for-each select="//RADKY/FEH">
              <xsl:variable name="pcr" select="count(preceding-sibling::*)+count(preceding-sibling::*/FER)"/>
              <xsl:if test="$pcr = $radekX">
                  <xsl:value-of select="-1.0"/>
              </xsl:if>
           </xsl:for-each>   
	</xsl:variable>
	<!-- skutecne pouzity pocet radek na prvni strane -->
	<xsl:variable name="radek1" >
	  <!-- je neco v radekY -->
              <xsl:if test="$radekY != -1">
                  <xsl:value-of select="$radekX"/>
              </xsl:if>
              <xsl:if test="$radekY=-1">
                  <xsl:value-of select="$radekX"/>
              </xsl:if>
	</xsl:variable>
	
	<!-- doporučená výška řádky na první straně -->
	<xsl:variable name="hr1" >
	 <xsl:if test="$radek1 &lt;= $maxradek1">
	  <xsl:value-of select="$hrx"/>
	 </xsl:if>
	 <xsl:if test="$radek1 &gt; $maxradek1">
	  <xsl:value-of select="format-number(($hpage - $head1) div $radek1,'0.000')"/>
	 </xsl:if>
	</xsl:variable> 

	<!-- vypocteny pocet radek na posledni strane -->
	<xsl:variable name="pcrps" >
	 <xsl:choose>
	 <xsl:when test="$pocetr &lt;= $maxradek1">
	  <xsl:value-of select="$pocetr"/>
	 </xsl:when>
	 <xsl:when test="$pocetr = $radek1">
	  <xsl:value-of select="0"/>
	 </xsl:when>
	 <xsl:when test="$pocetr &gt; $radek1">
	  <xsl:value-of select="floor(($pocetr - $radek1) mod $radekn)"/>
	 </xsl:when>
	 <xsl:otherwise>
	  <xsl:value-of select="floor(($pocetr - $radek1) mod $radekn)"/>
	 </xsl:otherwise>
	 </xsl:choose>
        </xsl:variable>
	<!-- Skutecny pocet radek na posledni strane = stranka se muze pridat-->
	<xsl:variable name="pcrpssk" >
	 <xsl:choose>
	 <xsl:when test="$pcrps &lt;= $maxradekn">
	  <xsl:value-of select="$pcrps"/>
	 </xsl:when>
	 <xsl:otherwise>
	  <xsl:value-of select="0"/>
	 </xsl:otherwise>
	 </xsl:choose>
        </xsl:variable>
	
	<!-- pocet stranek celkem -->
	<xsl:variable name="stran">
	 <xsl:choose>
	 <xsl:when test="$pocetr &lt;= $maxradek1">
	  <xsl:value-of select="1"/>
	 </xsl:when>
	 <xsl:when test="$pocetr = $radek1">
	  <xsl:value-of select="2"/>
	 </xsl:when>
	 <xsl:when test="($pocetr &gt; $radek1) and ($pcrpssk = 0)">
	  <xsl:value-of select="floor(($pocetr - $radek1) div $radekn) + 3"/>
	 </xsl:when>
	 <xsl:when test="$pocetr &gt; $radek1">
	  <xsl:value-of select="floor(($pocetr - $radek1) div $radekn) + 2"/>
	 </xsl:when>
	 <xsl:otherwise>
	  <xsl:value-of select="99"/>
	 </xsl:otherwise>
	 </xsl:choose>
	</xsl:variable> 
	

        
	<!-- celkova vyska vykonovych radek -->
        <xsl:variable name="vyskaradek" select="$pcrps * $hrx"/>
	
	<!-- vypocet odsazení podpisu  na posledni strane -->
 	<xsl:variable name="odsaz" >
	 <xsl:if test="$pocetr &lt;= $maxradek1">
	  <xsl:value-of select="format-number($hpage - $head1 - $hsum - $hfoot - $vyskaradek,'0.00')"/>
	 </xsl:if>
	 <xsl:if test="$pocetr &gt; $maxradek1">
	  <xsl:value-of select="format-number($hpage - $head2 - $hsum - $hfoot - $vyskaradek,'0.00')"/>
	 </xsl:if>
        </xsl:variable>
        <!--  -->

 <!--  Test odřádkování -->
   <xsl:template name="testpage">	
    <xsl:param name="pcr" select="1"/>
    <!-- odstrankovani na prvni strance -->
    <xsl:if test="$pcr &gt; $maxradek1">
      <xsl:if test="$pcr = $radek1">
            <xsl:call-template name="newpage"> 
              <xsl:with-param name="numpage" select="2"/>
            </xsl:call-template>
      </xsl:if>
    </xsl:if>  

    <!-- na dalsich strankach -->
    <xsl:if test="$pcr &gt; $radek1">
    <xsl:if test="(($pcr - $radek1) mod $radekn) = 0">
            <xsl:call-template name="newpage"> 
              <xsl:with-param name="numpage" select="floor((($pcr - $radek1) div $radekn))+2"/>
            </xsl:call-template>
    </xsl:if>
    </xsl:if>
   </xsl:template>

 
  
<!-- ************  konec podpory strankovani *************** -->
	   

<!-- ***** VARIABLES END*****-->                                               
                                               
<xsl:template match="/">                       <!-- ***** HTML BEGINNING*****-->
<html>
<head>
	<META content="text/html" charset="Windows-1250" http-equiv="Content-Type"/>
	<META content="sk" http-equiv="Content-language"/>
	<title>Faktúra - A4</title>
<STYLE>
BODY{
	font-size: 10pt;
	margin-left : 0 cm;
	background-color:white;
	font-family : "Arial", "MS Serif", "New York", serif;
/*  font-family : "Times New Roman",Georgia,Serif;     */
}

PRE{
	margin-bottom: 0px;
	margin: 0px;
}

.pravyhorny {                                          /* sirka pravej casti */
  /*position: relative;*/
  width: 108mm; top: 0mm; left: 70mm; height: 20mm;
  border : thin solid;
  border-bottom : none;
  padding : 0mm 0mm 0mm 2mm
  margin : 0cm,0cm,0cm,0cm;
}

/*
.mojlavys {
  position: relative; width: 70mm; top: 0mm; left: 0mm; height: 90mm;
  border : thin solid;
  border-right : none;
}
*/
.mojlavys {                                            /* sirka lavej casti */
  float: left;
  width: 80mm;
  height: 90mm;
  margin : 0cm,0cm,0cm,0cm;
  padding:0;
  border : thin solid;
}


.logo {
  position: relative;
  width: 70mm; top: 2mm; left: 3mm; height: 15mm;
/*  background-image:url('logokat.gif');*/
  background-repeat: no-repeat;
}

/* obal iba obali hlavu faktury, aby sa riadok "Na zaklade prilozenych..."*/
/* tlacil od kraja a nie od zaciatku praveho stlpca hlavy faktury */
.obal { 
  border : thin solid;
  border-color: white;
  width: 190mm;
}

.adresad {
	margin: 0px 0px 5px 8px;
}

.icodic {
	margin: 0px 0px 5px 8px;
}

.banka {
	margin: 0;
	width:100%;
}

.obchregister {
  font-size: 8pt;
  margin: 0px 0px 5px 8px;
}

.odberatelbox {                                         /* sirka pravej casti */
  /*position: relative;*/
  width: 108mm; top: 0mm; left: 70mm; height: 56mm;
  border : thin solid black 2px;
  /* border-bottom : none; */
  padding : 3mm 0mm 3mm 2mm
  margin : 0cm,0cm,0cm,0cm;
}

.datumybox {                                            /* sirka pravej casti */
  /*position: relative;*/
  width: 108mm; top: 0mm; left: 70mm; height: 14mm;
  border : thin solid;
  padding : 1mm 0mm 0mm 0mm
  margin : 0;
}

.tdbor {                                            /* td s rameckem  */
  /*position: relative;*/
  border : solid black 1px;
  border-left :none;
  padding : 0.5mm 0mm 0mm 2mm;
}
.tdborb {                                            /* td s rameckem bottom  */
  /*position: relative;*/
  border-bottom : solid black 1px;
  padding : 0.5mm 0mm 0mm 2mm;
}
.tdborbr {                                            /* td s rameckem bottom + right */
  /*position: relative;*/
  border-bottom : solid black 1px;
  border-right : solid black 1px;
  padding : 0.5mm 0mm 0mm 2mm;
}


.adresaodb {
  position: relative;
  top: 2mm;
  left: 40mm;
/*  font-weight: bold;*/
  line-height: 150%;
}

.odb {
  position: relative;
  top: 10mm; 
}

.odbico {
  position: relative;
  top: 2mm;
  left: 2mm;
}

.odbdic {
  position: relative;
  top: 2mm;
  left: 2mm;
}

.odbicdph {
  position: relative;
  top: 2mm;
  left: 2mm;
}

.odbadr {
  position: relative;
  top: -3.5mm;
  left: 40mm;
}

.datum {
	display : inline;
}

.medzera {
  display: inline;
  width: 0.26cm;
}

.medzera1cm {
  display: inline;
  width: 0.5cm;
}

.medzera3cm {
  display: inline;
  width: 1.5cm;
}

.medzeradic {
  display: inline;
  width: 4.30cm;
}

.mojahlava {
	font-size: 14pt;
}

.mena {
	display : inline;
	width : 1.2cm;
	text-align : right;
}

.hlava {
	font-size: 14pt;
	border : thin solid;
	width : 17.0cm;
	border-top : none;
	border-right-style : none;
	border-left-style : none;
}
.dodavatel {
	/*border : 1px solid;*/
	padding-left : 3mm;
	padding-top : 4mm;
	/*width : 18.5cm;*/
}
.odberatel {
	border : 1px solid;
	padding-left : 5mm;
	padding-top : 1mm;
	width : 18.5cm;
}
.vs {
	width : 6cm;
	height : 3cm;
	margin-bottom : 0px;
	border-left : 1px solid;
	padding-left : 5mm;
	left : 12cm;
	position : absolute;
	top : 1.3cm;
	display : inline;
}
.levys {
	width : 6cm;
	height : 3cm;
	margin-bottom : 0px;
	border-left : 1px solid;
	padding-left : 5mm;
	left : 0cm;
	position : absolute;
	display : inline;
}
.adresao {
	border-left : 1px solid;
	width : 11cm;
	height : 2.8cm;
	left:7cm;
	position : relative;
	padding : 0mm,3mm,0mm,3mm;
	margin : 0mm,2mm,1mm,0mm;
}
.datumy {
	display: block;
}
    
.popiska {  
   POSITION: relative; 
   margin-top: 0.3cm;
   Left:1cm; 
   font-size: 10pt;
   cursor: hand;
    }    
.radka {
   margin-top: 0.3cm;
   padding-left : 1cm;
}
.spz {
   display : inline;
   width : 2.5cm;
}
.b4 {
   display : inline;
   width : 6cm;
}
.datumstazky {
   display : inline;
}
.vykon{	
/*	width : 110mm; */
	padding-left : 0cm;	
	display : inline;
}
.kecy {
	display : inline;
}
.popis {
	display : inline;
/*	width : 87mm; */ 
}
.numberfak {
	display : inline;
	margin-left : 6 cm;
	width : 3.5cm;
	text-align : right;
}
.number {
	display : inline;
/*	width : 1.98cm; */
	text-align : right;
}
.number_neu {
	display : inline;
/*	width : 14mm; */
	text-align : left; 
}
.dic1 {
	display : inline;
	width : 3.8cm;
	text-align : right;
}
.dic {
	display : inline;
	width : 2.5cm;
	text-align : right;
}
.numberb {
	display : inline;
	width : 3.5cm;
	text-align : right;
	font-weight : bold;
}
.sazba {
	display : inline;
	text-align : right;
}
.space5cm {
	display : inline;
	width : 5cm;
}

.soucet {
	padding : 5mm,0mm,5mm,0mm;
	margin : 1cm,1cm,1cm,1cm;
	font-size : larger;	
	width : 15cm;
	border : 1px solid;
	left:1cm
}

.soucetnew {
	margin : 1cm,1cm,1cm,2cm;
/*	font-size : larger;*/	
/*	width : 14.5cm; */
/*	border : 1px solid;*/
/*	left:2cm*/
} 

.botcara{
	border : 1px solid;
	border-top : none;
	border-right-style : none;
	border-left-style : none;
}

.botcara9{
/*  position: relative;
  top: 7mm; */
	border : 1px solid;
	border-top : none;
	border-right-style : none;
	border-left-style : none;
  width : 9.5cm;	
}

.botcara18{
	border : 1px solid;
	border-top : none;
	border-right-style : none;
	border-left-style : none;
	width : 18.8cm;
}
.blok18{
	width : 18.8cm;
}

.dan {
	display : block;
	padding-left : 3cm;
}

.fakturant_ext {
	padding-left : 1cm;
	/*margin-top : 3cm;*/
}

.fakturant {
	padding-left : 1cm;
	margin-top : 3cm;
}

.foot{
  position:relative;
  top :  0cm;
  left : 0cm;
}


.header{
	position:relative;
  top :  0cm;
  left : 0cm;
}


.newpage {
	page-break-before:always;
	display : block;
}
.nopage {
	page-break-inside:avoid;
}

</STYLE>
</head>

<BODY>

<xsl:call-template name="header">
 <xsl:with-param name="showDesc" select="1"/>
 <xsl:with-param name="pageNumber" select="1"/>
 <xsl:with-param name="pageCount" select="$stran"/>
</xsl:call-template>


<!-- jednotlivé výkony uvedené ve faktuře -->
  
<xsl:for-each select="//RADKY/FEH">
  <!-- poradove cislo radky -->
  <xsl:variable name="pcr" select="count(preceding-sibling::*)+count(preceding-sibling::*/FER)+1"/>
            <xsl:call-template name="testpage"> 
               <xsl:with-param name="pcr" select="$pcr"/>
            </xsl:call-template>
   <DIV class="blok18">
   <SPAN style="font-size:10;font-style:italic">EČV: <xsl:value-of select="SPZ"/> - 
        <xsl:value-of select="concat(substring(DATUMPOCATKU,4,2),'.',substring(DATUMPOCATKU,1,2),'.',substring(DATUMPOCATKU,7,4))"/>

   </SPAN> 
    <!-- <span>  RADKA : <xsl:value-of select="$pcr" /> :: <xsl:value-of select="$pocetr" /> :: <xsl:value-of select="$pcrps" />:: <xsl:value-of select="$radek1" />
            Stran:<xsl:value-of select="$stran" />
    </span>
    -->        
    
   </DIV>
   
 <DIV class="botcara18">  
 <xsl:for-each select="FER">
   <!--  <xsl:variable name="pcr" select="count(preceding-sibling::*)+count(preceding-sibling::*/FER)"/>   -->
   <xsl:call-template name="testpage"> 
       <xsl:with-param name="pcr" select="$pcr + position()"/>
   </xsl:call-template>

   <xsl:variable name="pocJedn" select="POCETJED"/>
   <xsl:variable name="sumaBezDane" select="number(format-number(KC,'#0.000'))"/>
   <xsl:variable name="celkom" select="number(format-number(KC+DPHDAN,'#0.000'))"/>
       
    <DIV class="popis" style="font-size:11;width:8.74cm">
        <xsl:value-of select="POPIS"/>      
    </DIV>
    
   <DIV class="vykon" style="font-size:11">                
		<DIV class="number_neu" style="width:1.78cm">
			<xsl:value-of select="format-number($pocJedn,'#0,00','myFormat')"/>
			<xsl:text> </xsl:text>
			<xsl:value-of select="JEDNOTKA"/>
		</DIV>

		<DIV class="sazba" style="width:1.3cm">
			<xsl:value-of select="format-number(SAZBA,'#0,000','myFormat')"/>
		</DIV>

		<DIV class="sazba" style="width:2.3cm">
			<xsl:value-of select="format-number($sumaBezDane,'#0,000','myFormat')"/>
		</DIV>		

		<DIV class="sazba" style="width:1.1cm">
			<xsl:value-of select="DPH"/>%
		</DIV>				

		<DIV class="sazba" style="width:1.5cm">
			<xsl:value-of select="format-number(DPHDAN,'#0,000','myFormat')"/>
		</DIV>

		<DIV class="number" style="width:1.98cm">
			<xsl:value-of select="format-number($celkom ,'#0,000','myFormat')"/>
		</DIV>          
   </DIV>
  </xsl:for-each>
  </DIV>
  
</xsl:for-each> <!-- konec vypisu radek  --> 




  <!-- Pripadne strankovani -->
  <!-- mozna mam jeste odstrankovat za posledni radkou -->
  <xsl:if test="$pcrps &gt; $maxradek1">
      <xsl:call-template name="newpage"> 
        <xsl:with-param name="numpage" select="$stran"/>
      </xsl:call-template>
  </xsl:if>
   
   <SPAN class="foot">
     <xsl:call-template name="footer"/>     
   </SPAN>                                                                           
 

</BODY>
</html>
</xsl:template>

<xsl:template name="header">           <!--*****HEADER*****-->
 <xsl:param name="showDesc"/>
 <xsl:param name="pageNumber"/>
 <xsl:param name="pageCount"/>

<DIV class="obal">

<DIV class="mojlavys">
  
 <xsl:if test="number($pageCount) &gt; 1">   
   <TABLE style="border-collapse:collapse;font-size:12;margin:-0.05cm,-0.05cm,0cm,5.8cm">
   <TD style="border:2px solid black;width:3cm;text-align:center">
   <B><xsl:value-of select="concat('Strana ',$pageNumber,' / ',$pageCount)"/></B>
   </TD>
   </TABLE>
 </xsl:if>
  
<DIV class="adresad">  
 <span style="text-decoration: underline;" ><b>Dodávateľ:</b></span><BR/>
    <B> Labant s.r.o.</B> <BR/>
    <BR/>
    Pod Lachovcom  1203<BR/>
    020 01 Púchov<BR/>
    SLOVENSKÁ REPUBLIKA

  </DIV>
     
  <TABLE class="icodic" style="font-size:12">    
    <TR><TD>IČ:</TD><TD>36 331 503</TD></TR>  
    <TR><TD>DIČ:</TD><TD>2020110917</TD></TR>
    <TR><TD>IČ DPH:</TD><TD>SK2020110917</TD></TR>
  </TABLE>

  <TABLE class="icodic" style="font-size:12"> 
   <TR><TD>Obchodný register OS Trenčín, odd. Sro vl.č. 14188/R</TD></TR>
  </TABLE>
 
 <TABLE class="icodic" style="font-size:12">       
    <TR><TD>Banka:</TD><TD>Československá obchodná banka, a.s. Púchov</TD></TR>    
    <TR><TD></TD><TD>SWIFT: CEKOSKBX</TD></TR>
    <TR><TD></TD><TD>IBAN: SK8731000000004040304402</TD></TR>
    <TR><TD> </TD><TD> </TD></TR>
    <TR><TD>Tel.:042/4710640</TD><TD>Fax:042/4710642</TD></TR>
    <TR><TD>Fakturu vyhotovil:</TD>
    <TD>  <xsl:value-of select="substring-after(//FAH/FAKTURANT,' ')"/></TD>
    </TR>    

 </TABLE>
   

   <BR/>

   <!-- Odberatel --> 
<DIV>
<TABLE style="font-size:16; border-collapse:collapse">
<TR><TD style="width:3.9cm;"><b style="text-decoration: underline;">&#160;Odberateľ:</b></TD>
    <TD style="width:6.5cm"> </TD>
</TR>
<TR><TD style="width:3.9cm; text-decoration: underline;"> </TD>
    <TD style="width:6.5cm"><xsl:value-of select="//FAH/OBJEDNAZEV"/></TD>
</TR>
<TR><TD style="width:3.9cm; text-decoration: underline;"> </TD>
    <TD style="width:6.5cm"><xsl:value-of select="//O1"/></TD>
</TR>
<TR><TD style="width:3.9cm; text-decoration: underline;"> </TD>
    <TD style="width:6.5cm"><xsl:value-of select="//O2"/></TD>
</TR>
</TABLE> 
 
<!--   <DIV style="line-height:125%"><SPAN style="width:4cm">Odberateľ:</SPAN> <SPAN style="width:6.4cm"><xsl:value-of select="msxsl:node-set($origRoot)//FAH/OBJEDNAZEV"/></SPAN></DIV> -->
     
       
   <DIV style="padding-left:2mm;font-size:11">
    <DIV><SPAN style="width:3.8cm">IČO: <xsl:value-of select="//PRVNIMATERMASO"/></SPAN>
    <SPAN style="font-size:12"> 
    </SPAN></DIV>
    <DIV>
      <SPAN style="width:3.8cm">DIČ: 
          <xsl:value-of select="//DICOTX"/>  
      </SPAN>
      <SPAN style="font-size:12"><xsl:value-of select="//O2"/></SPAN> 
    </DIV>
      
    <DIV>
      <SPAN style="width:3.8cm"> IČ DPH: <xsl:value-of select="//DICOTX"/></SPAN> 
      <SPAN style="font-size:12"><xsl:value-of select="//O3"/></SPAN>
    </DIV>
    <BR/><BR/><BR/>
    <DIV>
      <SPAN style="font-size:12"> Konečný príjemca :</SPAN>
    </DIV>
    <BR/><BR/>
    <DIV>
      <SPAN style="font-size:12"> Miesto určenia : </SPAN>
    </DIV>
    <BR/>
    
    </DIV>
     
 </DIV>    
  
</DIV> <!-- koniec mojlavys -->
 


<DIV class="pravyhorny">
  <xsl:variable name="cislo" select="//CISF"/>
  <B>Faktúra - daňový doklad č.: <SPAN style="width:5.4cm;text-align:right;font-size:18"><xsl:value-of select="$cislo"/></SPAN></B> <BR/>  

  Variabilný symbol (uvádzajte pri platbe): <B><xsl:value-of select="$cislo"/></B><BR/>
  Objednávka: <SPAN style="width:7.92cm;text-align:right;font-weight:bold"></SPAN>
</DIV>

<DIV class="odberatelbox">

  Poštová adresa:  
  
 <DIV style="padding-left:6mm;padding-top:6mm">
  <B><xsl:value-of select="//FAH/OBJEDNAZEV"/></B><BR/>  
  <BR/>
  <xsl:choose>  
   <xsl:when test="string-length(//FAH/INFO1) or string-length(//FAH/INFO2)">                                                                                              
    <xsl:value-of select="//INFO1"/><BR/>
    <xsl:value-of select="//INFO2"/><BR/>    
   </xsl:when>
   
   <xsl:otherwise>
    <xsl:value-of select="//O1"/><BR/>
    <xsl:value-of select="//O2"/>
    
    <xsl:if test="string-length(//O3)">, <xsl:value-of select="//O3"/>
    </xsl:if>
    
    <BR/>   
   </xsl:otherwise>
  </xsl:choose>    
 </DIV>
  
 <DIV class="botcara9"></DIV>   
</DIV>

<DIV class="datumybox">
  <xsl:variable name = "df" select="//DF" />
  <xsl:variable name = "dzp" select="//DZP" />
  <xsl:variable name = "ds" select="concat(substring(//DS,4,2),'.',substring(//DS,1,2),'.',substring(//DS,7,4))"/>
 
  <TABLE style="border-collapse:collapse; font-size: 8pt; width:100%;">
    <TR >
      <TD class="tdbor" >Dátum vyhotovenia</TD>
      <TD class="tdbor" >Dodanie tovaru/služby</TD>
      <TD class="tdbor"  style="border-right:none">Dátum splatnosti</TD>
    </TR>
    <TR >  
      <TD class="tdbor" ><xsl:value-of select="concat(substring($df,4,2),'.',substring($df,1,2),'.',substring($df,7,4))" /></TD>
      <TD class="tdbor" ><xsl:value-of select="concat(substring($dzp,4,2),'.',substring($dzp,1,2),'.',substring($dzp,7,4))"/></TD>
      <TD class="tdbor" style="border-right:none"> <B><SPAN style="font-size:18"><xsl:value-of select="$ds"/></SPAN></B> </TD> </TR>
   </TABLE>   
  


  <TABLE  class="icodic" style="font-size:12;width=98%;">    
    <TR><TD>Forma úhrady:</TD>
      <xsl:choose>
        <xsl:when test="not(//FAH/FU = 'Hotovosť')">
          <TD><xsl:value-of select="substring-before(//FAH/FU,',')"/></TD>
        </xsl:when>
        <xsl:otherwise>
          <TD><xsl:value-of select="//FAH/FU"/></TD>
        </xsl:otherwise>
      </xsl:choose> 
    
    </TR>  
    <TR><TD>Sposob dopravy:</TD><TD>oosobný odber</TD></TR>
    </TABLE>


  <TABLE style="border-collapse:collapse;font-size:12;border:solid 2px black; width:100%;">      
    <TR><TD class="tdborb" >Číslo účtu:</TD><TD class="tdborb"  colspan="2" style="font-size:14"><B>4000832999/7500</B></TD> </TR>
    <TR><TD class="tdborb" >IBAN:</TD><TD class="tdborb" colspan="2">SK24 7500 0000 0040 0083 2999</TD></TR>    

  
    
    <TR><TD class="tdborb">Suma k úhradě:</TD><TD  class="tdborb"  colspan="2"><B>
          <xsl:value-of select="//FAH/KUHRADE"/> EUR</B></TD></TR>    
    <TR>
    <TD class="tdborbr">Variabilný symbol</TD>
    <TD class="tdborbr">Koštantný symbol</TD>
    <TD class="tdborb">Špecifický symbol</TD>
    </TR>    
    <TR><TD class="tdborbr" style="font-size:14"><B><xsl:value-of select="//CISF"/>
        </B></TD>
        <TD class="tdborbr">0308</TD>
        <TD class="tdborbr">&#160;</TD>
    </TR>     
  </TABLE>
 

   
 </DIV>


</DIV> <!-- koniec obalu -->
 
 
<xsl:variable name="popisPl" select="//FAH/POPISPL"/>
<xsl:choose>
 <xsl:when test="$showDesc">
  <xsl:choose>
   <xsl:when test="string-length($popisPl)">
    <DIV class="botcara18" style="font-size:18;line-height:140%">Fakturujeme Vám za <xsl:value-of select="$popisPl"/></DIV> 
   </xsl:when>
   <xsl:otherwise>
    <DIV class="botcara18" style="font-size:18;line-height:140%">Fakturujeme Vám prepravu tovaru :
    <!-- <xsl:value-of select="$line_count"/> / <xsl:value-of select="$faktoring * 1"/> faktoring--></DIV> 
   </xsl:otherwise> 
  </xsl:choose>
 </xsl:when>
 <xsl:otherwise>
 <DIV class="botcara18" style="font-size:12;line-height:125%">&#160;</DIV>
</xsl:otherwise>
</xsl:choose> 

<DIV class="botcara18" style="font-size:11;text-align:right">
<PRE><B>                                                     Cena za jedn. Cena celkom Sadzba Suma   Celkom</B></PRE>
<PRE><B>Názov / popis                                 Mn./j  v EUR bez DPH   bez DPH   DPH    DPH     s DPH</B></PRE>
</DIV>
</xsl:template>

<xsl:template name="footer">                             <!--*****FOOTER*****-->
 <DIV class="blok18" >
   <xsl:value-of select="$reverseText" />
 </DIV>
<!-- suctova tabulka: zaciatok -->

<DIV style="margin:0.49cm,0cm,0.3cm,4cm">
  <TABLE style="border-collapse:collapse">
    <TR><TD></TD><TD style="border:1px solid black"><B><PRE>                        Čiastky v EUR           </PRE></B></TD></TR>       
    <TR><TD></TD><TD style="border:1px solid black"><B><PRE>              Bez DPH            DPH      Celkom</PRE></B></TD></TR>
    
    <xsl:for-each select="//SOUCTYDPH/FAD[ZAKLAD != 0.0]" >
    <xsl:variable name="zaklad" select="format-number(ZAKLAD,'#0,00','myFormat')"/>
    <xsl:variable name="dan" select="format-number(DAN,'#0,00','myFormat')"/>
    <xsl:variable name="spolu" select="format-number(ZAKLAD + DAN,'#0,00','myFormat')"/>
    
    <TR><TD style="border:1px solid black;font-size:11"><PRE> Celkom s <xsl:value-of select="PROCENTO"/>% DPH</PRE></TD>
    <TD style="border:1px solid black;text-align:right">
    <PRE><SPAN style="width:4.45cm"><xsl:value-of select="$zaklad"/></SPAN>
    <SPAN style="width:3.2cm"><xsl:value-of select="$dan"/></SPAN>
    <SPAN style="width:2.52cm"><xsl:value-of select="$spolu"/></SPAN></PRE></TD></TR>
    </xsl:for-each>       

    <xsl:variable name="kuhrade" select="format-number(//FAH/KUHRADE,'#0,00','myFormat')"/>    
    <TR><TD style="border:1px solid black;font-size:14"><B><PRE> K úhrade</PRE></B></TD>
    <TD align="right" style="border:2px solid black;font-size:18;padding-right:2mm"><B><xsl:value-of select="$kuhrade"/> EUR</B><BR/>
    </TD></TR>
  </TABLE>
</DIV>
<!-- suctova tabulka: koniec -->

<SPAN style="padding-left:1.5cm">  </SPAN> 
<SPAN style="padding-left:5cm"> Podpis a pečiatka: </SPAN>
<BR/>
<BR/>
<BR/>
<BR/>
<BR/>
<SPAN style="line-height:23%"><BR/></SPAN>
<DIV class="botcara18" style="font-size:10">  

</DIV>
<SPAN style="width:7.4cm;padding-left:3mm;font-size:11">Telefón: <xsl:value-of select="//FAH/TELEFON"/></SPAN>
<SPAN style="width:8cm;font-size:11">E-mail: <xsl:value-of select="//FAH/UZIV_EMAIL"/></SPAN>
<SPAN style="font-size:11">Web: www.labant.sk</SPAN>
</xsl:template>


  
<!--  -->	
   <xsl:template name="newpage">	
     <xsl:param name="numpage" select="1"/>
      <DIV class="newpage"><xsl:text>&#160;</xsl:text>
      <xsl:call-template name="header">
       <xsl:with-param name="showDesc" select="1"/>
       <xsl:with-param name="pageNumber" select="$numpage"/>
       <xsl:with-param name="pageCount" select="$stran"/>
      </xsl:call-template>
      
      </DIV>
     </xsl:template>

</xsl:stylesheet>