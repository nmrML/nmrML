


		
var is_safari;
if (navigator.userAgent.indexOf('Safari') != -1){
	is_safari=true;
}

/*
if (is_safari) {
	tabid = ['tab_01', 'tab_02'];
	for (x in tabid) {
      document.getElementById(tabid[x]).getElementsByTagName('A')[0].href='#'+tabid[x];
	}
}
*/


if (navigator.userAgent.indexOf("Camino") != -1) {
	document.write('<link rel="stylesheet"  href="http://www.ebi.ac.uk/inc/css/Camino.css"   type="text/css" />');
}
if (   (((navigator.userAgent).split("Linux").length)>1)   &&  (navigator.userAgent.indexOf("Opera") == -1)    ){
	document.write('<link rel="stylesheet"  href="http://www.ebi.ac.uk/inc/css/linux.css"   type="text/css" />');
}
if( (navigator.userAgent.split("Linux").length)>1  ){
	document.write('<link rel="stylesheet"  href="http://www.ebi.ac.uk/inc/css/linux.css"   type="text/css" />');
}
if (navigator.userAgent.indexOf("Opera") != -1) {
	document.write('<link rel="stylesheet"  href="http://www.ebi.ac.uk/inc/css/Opera.css"   type="text/css" />');
}
else if(navigator.userAgent.indexOf("Safari") != -1) {
	document.write('<link rel="stylesheet"  href="http://www.ebi.ac.uk/inc/css/Safari.css"   type="text/css" />');	
}
else if(navigator.userAgent.indexOf("Netscape") != -1) {
	document.write('<link rel="stylesheet"  href="http://www.ebi.ac.uk/inc/css/Netscape.css"   type="text/css" />');	
}
else if (  (navigator.userAgent.indexOf("Firefox") != -1) && (navigator.userAgent.indexOf("Macintosh") != -1)   ){
	document.write('<link rel="stylesheet"  href="http://www.ebi.ac.uk/inc/css/MacFirefox.css"   type="text/css" />');
}
else if(navigator.userAgent.indexOf("Firefox") != -1) {
	// enough said its already perfect :)
}
else if(navigator.userAgent.indexOf("like Gecko") != -1) {
}
else if(navigator.userAgent.indexOf("Gecko") != -1) {
	document.write('<link rel="stylesheet"  href="http://www.ebi.ac.uk/inc/css/OldGecko.css"   type="text/css" />');
}
else{}

if (navigator.userAgent.indexOf("(Macintosh") != -1) {
	document.write('<link rel="stylesheet"  href="http://www.ebi.ac.uk/inc/css/mac_template.css"   type="text/css" />');
}

try{
	//if(window.parent){
		if(window.parent.isHomePage){
			document.write('<link rel="stylesheet"  href="http://www.ebi.ac.uk/inc/css/home.css"   type="text/css" />');
			if(navigator.userAgent.indexOf("MSIE") != -1) {
				document.write('<link rel="stylesheet"  href="http://www.ebi.ac.uk/inc/css/home_IE6.css"   type="text/css" />');
			}
			if(navigator.userAgent.indexOf("MSIE 7") != -1) {
				document.write('<link rel="stylesheet"  href="http://www.ebi.ac.uk/inc/css/home_IE7.css"   type="text/css" />');
			}
			if( (navigator.userAgent.split("Linux").length)>1  ){
				document.write('<link rel="stylesheet"  href="http://www.ebi.ac.uk/inc/css/home_linux.css"   type="text/css" />');
			}
			if( (navigator.userAgent.split("Macintosh").length)>1  ){
				document.write('<link rel="stylesheet"  href="http://www.ebi.ac.uk/inc/css/home_mac.css"   type="text/css" />');
			}
			if (navigator.userAgent.indexOf("Camino") != -1) {
				document.write('<link rel="stylesheet"  href="http://www.ebi.ac.uk/inc/css/home_mac.css"   type="text/css" />');	
			}
		}
	//}
}
catch(err){

} 






var contentsIsMaximised=false;

function hidetemplate(){
	if(  (document.getElementById("header").style.visibility=="visible")||(document.getElementById("header").style.visibility=="")  ){
		
		try{
			if(parent.document.getElementById("contentsarea")){ // if correct template used...
				if(parent.document.getElementById("contentsarea").style.width!="100%"){
					contentsIsMaximised=false;
					parent.document.getElementById("contentsarea").style.width="100%" ;
				}
				minimimise();
			}// end if correct template used...
		}
		catch(err){
		
		}
		
		
		if(navigator.userAgent.indexOf("MSIE") != -1) {
			try{
				parent.window.focus();
				parent.window.print();
			}
			catch(err){
		
			}
		}
		else{
			try{
				parent.window.print();
			}
			catch(err){
		
			}
		}
		
		try{
			if(parent.document.getElementById("contentsarea")){ // if correct template used...
				document.getElementById("printiconhref").title="Show Header/Footer";
				document.getElementById("printicon").alt="Show Header/Footer";
			}// end if correct template used...
		}
		catch(err){
		
		}
	}
	else{
		try{
			if(parent.document.getElementById("contentsarea")){ // if correct template used...
				if(contentsIsMaximised==false){
					parent.document.getElementById('contentsarea').style.width='762px';
				}
				minimimise();
				document.getElementById("printiconhref").title="Go to printer-friendly view and print page";
				document.getElementById("printicon").alt="Go to printer-friendly view and print page";
			} // end if correct template used...
		}
		catch(err){
		
		}
	}
}

function showtemplate(){
	document.getElementById("header").style.visibility="visible";
	document.getElementById("menucontainer").style.visibility="visible";
	parent.document.getElementById("footerdiv").style.visibility="hidden";
	parent.document.getElementById("headerdiv").style.background="#207a7a";
	if(parent.document.getElementById("leftmenu")){
		parent.document.getElementById("leftmenu").style.visibility="visible";
	}
	if(parent.document.getElementById("rightmenu")){
		parent.document.getElementById("rightmenu").style.visibility="visible";
	}
}

var leftmenuIsMaximised=false;
var rightmenuIsMaximised=false;

function minimimise(){
	
	if(  (document.getElementById("header").style.visibility=="visible")||(document.getElementById("header").style.visibility=="")  ){
		document.getElementById("header").style.visibility="hidden";
		document.getElementById("menucontainer").style.visibility="hidden";
		parent.document.getElementById("footerdiv").style.visibility="hidden";	
		parent.document.getElementById("headerdiv").style.background="#ffffff";
		
		//clause to fix "intepro template"....
		if(parent.document.getElementById("leftmenu")){
			if(parent.document.getElementById("leftmenu").style.display=="block"){
				leftmenuIsMaximised=true;
			}
			else{
				leftmenuIsMaximised=false;
			}
			if(parent.document.getElementById("rightmenu").style.display=="block"){
				rightmenuIsMaximised=true;
			}
			else{
				rightmenuIsMaximised=false;
			}
		}
		//end clause to fix "intepro template"....
		
		
		if(parent.document.getElementById("leftmenu")){
			parent.document.getElementById('leftmenu').style.visibility='hidden'; 
			parent.document.getElementById('leftmenu').style.display='none';
			parent.document.getElementById('leftmenu').style.width='1px';
		}
		if(parent.document.getElementById("rightmenu")){
			parent.document.getElementById('rightmenu').style.visibility='hidden'; 
			parent.document.getElementById('rightmenu').style.display='none';
			parent.document.getElementById('rightmenu').style.width='1px';
		}
		parent.document.getElementById("contents").style.top="17px" ;
		document.getElementById("therighticons").style.top=0 ;
		document.getElementById("therighticons").style.visibility="visible";
		document.getElementById("sitemapicon").style.visibility="hidden";
		document.getElementById("rssicon").style.visibility="hidden";
		parent.document.getElementById("footerpane").style.visibility='hidden'; 
	}
	else{
		
		document.getElementById("header").style.visibility="visible";
		document.getElementById("menucontainer").style.visibility="visible";
		parent.document.getElementById("footerdiv").style.visibility="visible";
		parent.document.getElementById("headerdiv").style.background="#207a7a";
		parent.document.getElementById("footerpane").style.visibility='visible'; 
		document.getElementById("sitemapicon").style.visibility="visible";
		document.getElementById("rssicon").style.visibility="visible";
		if(parent.document.getElementById("leftmenu")){
			parent.document.getElementById('leftmenu').style.visibility='visible';
			if(leftmenuIsMaximised==true){
				parent.document.getElementById('leftmenu').style.display='block';
				parent.document.getElementById('leftmenu').style.width='145px';
			}
		}
		if(parent.document.getElementById("rightmenu")){
			parent.document.getElementById('rightmenu').style.visibility='visible';
			if(rightmenuIsMaximised==true){
				parent.document.getElementById('rightmenu').style.display='block';
				parent.document.getElementById('rightmenu').style.width='145px'; 
			}
		}
		try{
			//if(window.parent){
				if(window.parent.isHomePage){
					parent.document.getElementById("contents").style.top="120px"; 
					document.getElementById("therighticons").style.top="102px" ;	
				}
				else{
					parent.document.getElementById("contents").style.top="57px"; 
					document.getElementById("therighticons").style.top="35px" ;
				}
			//}
		}
		catch(err){
		
		} 
		if(navigator.userAgent.indexOf('MSIE') != -1) {
			//have to set this to larger than the page width as internet explorer is too stupid to remember how large 100% is...... */
			document.getElementById("nav").style.width="124em";
			//document.getElementById("nav").style.marginLeft  ="62px";
			document.getElementById("menucontainer").style.display="block";
		}
	}
}

headertoback=0;
function bringtotop(){
	if(navigator.userAgent.indexOf("MSIE") != -1) {
		if(top!=self){
			try{
				if(parent.document.getElementById('head').allowTransparency==true){
					if(top!=self){
						if(headertoback!=null){
							window.clearTimeout(headertoback);
						}
						try{
							parent.document.getElementById('headerdiv').style.zIndex =600;
						}
						catch(err){
	
						} 
					}	
				}
			}
			catch(err){
		
			} 	
		}
	}
	else{
		if(top!=self){
			if(!is_safari){
				if(headertoback){
					window.clearTimeout(headertoback); 
				}
			}
			else{
				clearTimeout(headertoback); 
			}
			try{
				parent.document.getElementById('headerdiv').style.zIndex =600;
			}
			catch(err){

			} 
			
		}	
	}
}

function bringtobottom(){
	if(top!=self){
		if(!is_safari){
			headertoback=window.setTimeout("do_bringtobottom()", 0.1);
		}
		else{
			headertoback=setTimeout("do_bringtobottom()", 10);
		}
	}
	
}

function do_bringtobottom(){
	if(!is_safari){
		try{
			parent.document.getElementById('headerdiv').style.zIndex =1;
		}
		catch(err){

		} 
	}
	else{
		try{
			parent.document.getElementById('headerdiv').style.zIndex =1;
		}
		catch(err){

		} 
	}
	if(!is_safari){
		try{
			document.getElementById('nav').style.zIndex =-2;
		}
		catch(err){

		} 
	}
	else{
		try{
			document.getElementById('nav').style.zIndex =-2;
		}
		catch(err){

		} 
	}
	if(is_safari){
		resetmenu_safari();
	}
	else{
		resetmenu();
	}
}




try{
		var parentHref = parent.document.location.href;
		if ((parentHref.indexOf("ebisearch")!=-1) || (parentHref.indexOf("s4")!=-1)) {
			// If a window.onload already exists, keep track of it 
			if (window.onload) {
				_previousOnload = window.onload;
			}
			// Define the new window.onload  
			window.onload = function(evt) {
				// execute a previous window.onload if it exists  
				if (_previousOnload) {
					_previousOnload.call(this, evt);
				}
				// Change the text box value if available from the parent  
					if (window != parent) {
							if (parent.getQueryString) {
									var query = parent.getQueryString();
									if (query) {
											var queryBox = document.getElementById('sf');
											if (queryBox) {
													queryBox.value = query;
											}
									}
							}
					}
				// Safety feature to avoid garbage collection madness 
				this.onload = null;
			};
		}


}
catch(err){

} 












