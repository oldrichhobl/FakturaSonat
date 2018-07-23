var xml = new ActiveXObject("Msxml2.DOMDocument.6.0");
var xsl = new ActiveXObject("Msxml2.DOMDocument.6.0");

xml.async = false;
          	  xml.setProperty("SelectionLanguage", "XPath");
          	  xml.setProperty("AllowDocumentFunction", true);
          	  xml.setProperty("AllowXsltScript", true);
          	  xml.setProperty("ProhibitDTD", false);
		      xml.setProperty("ResolveExternals", true);
xsl.async = false;
          	  xsl.setProperty("SelectionLanguage", "XPath");
          	  xsl.setProperty("AllowDocumentFunction", true);
          	  xsl.setProperty("AllowXsltScript", true);
          	  xsl.setProperty("ProhibitDTD", false);
		      xsl.setProperty("ResolveExternals", true);

xml.load("10.xml");
//xsl.load("FAKTÚRA_Predaj materiálu s dopravou_Infra Services.xsl");
//xsl.load("PM.xsl");
xsl.load("PMServices.xsl");



var fso = new ActiveXObject("Scripting.FileSystemObject");
var MyFile = fso.CreateTextFile("output.html", true);

MyFile.Write(xml.transformNode(xsl));
MyFile.Close();

WScript.Echo('KONEC')

