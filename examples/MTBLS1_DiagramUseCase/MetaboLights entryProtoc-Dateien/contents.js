var loc = ""  + document.location; // turn to string...

function loadjquery() {
	if (loc.indexOf(".xml")!= -1){
		
	}
	else if((document.mimetype=='XML Document')&&(document.mimetype)){ // only works for ie, but that is where the problem is
		
	}
	else if(loc.indexOf("/pride/")!= -1) { // jquery breaks prototype, can't check as prototype loaded after this script
	
	}
	else if(loc.indexOf("/ontology-lookup/")!= -1) { // jquery breaks prototype, can't check as prototype loaded after this script
	
	}
	else if(loc.indexOf("/Tools/picr")!= -1) { // jquery breaks prototype, can't check as prototype loaded after this script
	
	}
	else if( typeof DOKU_BASE !== 'undefined'  ) { // jquery breaks dokuwiki
	
	}
	else if( typeof Prototype === 'undefined'  ) { // jquery breaks prototype
		document.write("<script src='http://www.ebi.ac.uk/inc/js/jquery.js' type='text/javascript'></" + "script>");
	}
}



if((document.mimetype=='XML Document')&&(document.mimetype)){
	
}
else if (loc.indexOf(".xml")!= -1) {
	
}
else{
	document.write('<link rel="alternate" title="EBI News RSS" href="http://www.ebi.ac.uk/Information/News/rss/ebinews.xml" type="application/rss+xml" />');
}


function installSearchEngine() {
	if (window.external && ("AddSearchProvider" in window.external)) {
		// Firefox 2 and IE 7, OpenSearch
		window.external.AddSearchProvider("http://www.ebi.ac.uk/OpenSearch.xml");
	} 
	else if (window.sidebar && ("addSearchEngine" in window.sidebar)) {
		// Firefox <= 1.5, Sherlock
		window.sidebar.addSearchEngine("http://www.ebi.ac.uk/OpenSearch.src", "http://www.ebi.ac.uk/favicon.gif", "EB-Eye Search Plugin", "");
	} 
	else {
		// No search engine support (IE 6, Opera, etc).
	}
}






if (loc.indexOf(".xml")== -1) {
	document.write('<style type="text/css">@media print { body, .contents, .header, .contentsarea, .head{ position: relative;}  } </style>');
}


if(document.layers){
	document.write('<script type="text/javascript" src="http://www.ebi.ac.uk/inc/js/netscape47.js"></script>');
}

if (navigator.userAgent.indexOf("Opera") != -1) {
	//window.attachEvent("onload", fixtrasparency);
	document.write('<link rel="stylesheet"  href="http://www.ebi.ac.uk/inc/css/Opera.css"   type="text/css" />');
}

if (navigator.userAgent.indexOf("MSIE") != -1) {
	document.write('<link rel="stylesheet"  href="http://www.ebi.ac.uk/inc/css/contents_IE.css"   type="text/css" />');
}

if(navigator.userAgent.indexOf("Safari") != -1) {
	document.write('<link rel="stylesheet"  href="http://www.ebi.ac.uk/inc/css/contents_Safari.css"   type="text/css" />');	
}


function showRightMenu(){						
	document.getElementById('rightmenu').style.visibility='visible'; 
	document.getElementById('rightmenu').style.display='block';
	document.getElementById('rightmenu').style.width='145px'; 
}

function hideRightMenu(){
	document.getElementById('rightmenu').style.visibility='hidden'; 
	document.getElementById('rightmenu').style.display='none';
	document.getElementById('rightmenu').style.width='1px'; 
}

function showLeftMenu(){
	document.getElementById('leftmenu').style.visibility='visible'; 
	document.getElementById('leftmenu').style.display='block';
	document.getElementById('leftmenu').style.width='145px'; 
}
				
function hideLeftMenu(){
	document.getElementById('leftmenu').style.visibility='hidden'; 
	document.getElementById('leftmenu').style.display='none';
	document.getElementById('leftmenu').style.width='1px'; 
}

function maximisePage(){
	document.getElementById('contentspane').style.width='100%';
}

function minimisePage(){
	document.getElementById('contentspane').style.width='790px';
}

//Select All Text in Input Box

function selectAll(theField) {
  var tempval = eval("document." + theField);
  tempval.focus();
  tempval.select();
} 

// Open Window Methods

var newWin;

function openWindow(address){ 
	newWin = window.open(address,'_help','personalbar=0, toolbar=0,location=0,directories=0,menuBar=0,status=0,resizable=yes,scrollBars=0, resizable=1, width=800, height = 500,top=0,left=0'); 
    newWin.focus();
}

function openWindow2(address){ 
	newWin = window.open(address,'_pic','personalbar=0, toolbar=0,location=0,directories=0,menuBar=0,status=0,scrollBars=1, resizable=1, width=587, height = 445,top=0,left=0'); 
	newWin.focus();
}

function openWindow3(address)
{ 
	newWin = window.open(address,'_pic','personalbar=0, toolbar=0,location=0,directories=0,menuBar=0,status=0,scrollBars=0, resizable=1, width=420, height = 620,top=0,left=0'); 
	newWin.focus();
}

function openWindowScroll(address){ 
	newWin = window.open(address,'_help','personalbar=0, toolbar=0,location=0,directories=0,menuBar=0,status=0,resizable=yes,scrollBars=1, resizable=1, width=800, height = 500,top=0,left=0'); 
    newWin.resizeTo(800, 500);
    newWin.focus();
}

// jump menu method

function MM_jumpMenu(targ,selObj,restore){ //v3.0
  eval(targ+".location='"+selObj.options[selObj.selectedIndex].value+"'");
  if (restore) selObj.selectedIndex=0;
}

function makemail(emailaddress){
		if(emailaddress == "support"){
			document.write("<a  target='_top'  title='Contact EBI Support' href='http://www.ebi.ac.uk/support/'>EBI Support</a>");
			loadSelects(); //////////////////////////////////////
		}
		else if(emailaddress == "---"){
			document.write("&nbsp;");
		}
		else{
			document.write("<a href='mailto:" + emailaddress + "\@ebi.ac.uk'>" + emailaddress + "\@ebi.ac.uk</a>");
		}
}







function makeothermail(emailaddress, domain, style){
			document.write("<a class='" + style + "' href='mailto:" + emailaddress + "\@" + domain + "'>" + emailaddress + "\@" + domain + "</a>");
}

function makestylemail(emailaddress, style){
		if(emailaddress == "support"){
			document.write("<a  target='_top' title='Contact EBI Support' class='" + style + "'  href='http://www.ebi.ac.uk/support/'>EBI Support</a>");
			loadSelects(); //////////////////////////////////////
		}
		else{
			document.write("<a class='" + style + "' href='mailto:" + emailaddress + "\@ebi.ac.uk'>" + emailaddress + "\@ebi.ac.uk</a>");
		}
}

function openWindow2can(address){ 
	newWin = window.open(address,'_help','personalbar=0, toolbar=0,location=0,directories=0,menuBar=0,status=0,resizable=yes,scrollBars=1, resizable=1, width=450, height = 125,top=0,left=0'); 
    newWin.resizeTo(800, 300);
    newWin.focus();
}

function do_reset(){
	document.personSearch.s_keyword.value="";
}

// The Table Ruler by Christian Heilmann
// http://alistapart.com/articles/tableruler
// modified by Stephen Robinson, so that it restores old row class name on mouse out.
function tableruler(){
	var selectBug=false; // firefox 1.5.0.1. bug
	if(navigator.userAgent.indexOf("Firefox")!=-1){
		var userAgentBits=navigator.userAgent.split("Firefox/");
		var userAgentBits2=userAgentBits[1].split(" ");
		var ffNumber=userAgentBits2[0];
		var ffNumberArray=ffNumber.split(".");
		var realNumber= ffNumberArray[0]+"."+ffNumberArray[1]+ffNumberArray[2];
		if(ffNumberArray[3]<10){
			realNumber = realNumber+"0"+ffNumberArray[3];
		}
		else{
			realNumber = realNumber+ffNumberArray[3];
		}
		if(realNumber<1.5005){
			selectBug=true;
		}
	}
	if(selectBug==false){
		var tables=document.getElementsByTagName('table');
		for (var i=0; i<tables.length; i++) {
			if( (tables[i].className=='contenttable') || (tables[i].className=='contenttable_lmenu')  || (tables[i].className=='summarytable')   || (tables[i].className=='contenttable_max')   || (tables[i].className=='monthtable')){
				var trs=tables[i].getElementsByTagName('tr');
				for(var j=0;j<trs.length;j++){
					trs[j].onmouseover=function(){
						if(this.className){
							this.oldClassName=this.className;
						}
						else{
							this.oldClassName='';
						}
						this.className='ruled';
						return false;
					}
					trs[j].onmouseout=function(){
						if(this.oldClassName){
							this.className=this.oldClassName;
						}
						else{
							this.className='';
						}
						return false;
					}
				}
			}
		}
	
	}
}
//tableruler();




function tablestriper(){
	var tables=document.getElementsByTagName('table');
	for (var i=0; i<tables.length; i++) {
		if( (tables[i].className=='contenttable') || (tables[i].className=='contenttable_lmenu')  || (tables[i].className=='summarytable')   || (tables[i].className=='contenttable_max')    || (tables[i].className=='monthtable')  ){
			var tmpTableClass=tables[i].className;
			var trs=tables[i].getElementsByTagName('tr');
			var stripeCounter=1;
			for(var j=0;j<trs.length;j++){
				if(trs[j].parentNode.parentNode.className==tmpTableClass){
					var tablekiddies = trs[j].childNodes;
					
					if(tablekiddies[1]){ // for IE
					//alert(trs[j].innerHTML + "---" + j);
					
						if(  (tablekiddies[1].tagName=="TD") && ( tablekiddies[1].className != "subheading") && ( tablekiddies[1].className != "subheadingleft")  && ( tablekiddies[1].style.background =="") && (trs[j].innerHTML.indexOf('bgcolor')==-1) ){
							if( (stripeCounter) == 1){
								stripeCounter=0;
							}
							else {
								stripeCounter=1;
								trs[j].className="alternaterowcolour";
							}
						}
						else {
							stripeCounter=1;
						}
					}
					else{
						stripeCounter=1; // for IE
					}
				}
			}
		}
	}
}



function tablecellruler(){
	var tables=document.getElementsByTagName('table');
	for (var i=0; i<tables.length; i++) {
		if( (tables[i].className=='contenttable') || (tables[i].className=='contenttable_lmenu')  || (tables[i].className=='summarytable')   || (tables[i].className=='contenttable_max')){
			var trs=tables[i].getElementsByTagName('tr');
			for(var j=0;j<trs.length;j++){
				var tabletdkiddies = trs[j].childNodes;
				for(var w=0; w<tabletdkiddies.length; w++){
					if((tabletdkiddies[w].tagName=="TD") && (tabletdkiddies[w].className!="nohover") ){
						tabletdkiddies[w].onmouseover=function(){
							if(this.className){
								this.oldClassName=this.className;
							}
							else{
								this.oldClassName='';
							}
							this.className='ruledover'; //tdcolourhover
							return false;
						}
						tabletdkiddies[w].onmouseout=function(){
							if(this.oldClassName){
								this.className=this.oldClassName;
							}
							else{
								this.className='';
							}
							return false;
						}
					}
				}
			}
		}
	}
}







function MM_swapImgRestore() { //v3.0
  var i,x,a=document.MM_sr; for(i=0;a&&i<a.length&&(x=a[i])&&x.oSrc;i++) x.src=x.oSrc;
}

function MM_preloadImages() { //v3.0
  var d=document; if(d.images){ if(!d.MM_p) d.MM_p=new Array();
    var i,j=d.MM_p.length,a=MM_preloadImages.arguments; for(i=0; i<a.length; i++)
    if (a[i].indexOf("#")!=0){ d.MM_p[j]=new Image; d.MM_p[j++].src=a[i];}}
}

function MM_findObj(n, d) { //v4.0
  var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {
    d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}
  if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
  for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document);
  if(!x && document.getElementById) x=document.getElementById(n); return x;
}

function MM_swapImage() { //v3.0
  var i,j=0,x,a=MM_swapImage.arguments; document.MM_sr=new Array; for(i=0;i<(a.length-2);i+=3)
   if ((x=MM_findObj(a[i]))!=null){document.MM_sr[j++]=x; if(!x.oSrc) x.oSrc=x.src; x.src=a[i+2];}
}

function MM_jumpMenu(targ,selObj,restore){ 
//alert(selObj.options[selObj.selectedIndex].value);
  if(selObj.options[selObj.selectedIndex].value != "")
  {
  	eval(targ+".location='"+selObj.options[selObj.selectedIndex].value+"'");
  	if (restore) selObj.selectedIndex=0;
  }
}





function showHide(theid){
	if(document.getElementById(theid).style.display=="block"){
		document.getElementById(theid).style.display="none";
	}
	else{
		document.getElementById(theid).style.display="block";
	}
}





  