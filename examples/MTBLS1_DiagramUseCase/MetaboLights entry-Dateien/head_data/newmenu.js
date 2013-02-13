
// based on Son of Suckerfish Dropdowns By Patrick Griffiths and Dan Webb see http://www.htmldog.com/articles/suckerfish/dropdowns/
// who based this on http://www.alistapart.com/articles/dropdowns/ by  Patrick Griffiths and Dan Webb, see http://www.alistapart.com/articles/dropdowns/
// modified by Stephen Robinson for EBI use.


// HERE IS IS !!!! SET THIS TO LARGER IF MENU GETTING TRUNCATED AS IS TOO LONG!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

// old vars to resore if goes tits up...
//var theMenuHeight="655px";
//var theMenuHeightHome="715px";

//these zoom when user resets font size
var theMenuHeight="70.0em";
var theMenuHeightHome="77.0em";

// HERE IS IS !!!! SET THIS TO LARGER IF MENU GETTING TRUNCATED AS IS TOO LONG!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!




var is_safari=false;
if (navigator.userAgent.indexOf('Safari') != -1){
	is_safari=true;
}

if (  (navigator.appName != 'Microsoft Internet Explorer') ) {
	try{
		if(window.parent.isHomePage){
			parent.document.getElementById("head").style.height="125px";
		}
		else{
			parent.document.getElementById("head").style.height="57px";	
		}
	}
	catch(err){
	
	} 
}

if (  (navigator.appName == 'Microsoft Internet Explorer') && !window.parent.isHomePage ) {
	window.attachEvent("onload", fixHeaderWidth);	
}

function fixHeaderWidth(){
	//stops ie  flipping end right image when reduce window size....
	if (document.getElementById("search")) {
    document.getElementById("search").style.width="700px";
  }
}

var is_ie9 = false;
var is_ie8 = false;
var is_ie6 = false;
var is_ie = false;
var is_netscape = false;

if (  (navigator.appName == 'Microsoft Internet Explorer') ) {
	is_ie=true;
	//parent.document.getElementById("head").style.height="670px";
	try{
		//parent.document.getElementById("head").style.height="710px";
		
		if(window.parent.isHomePage){
			
			parent.document.getElementById("head").style.height=theMenuHeightHome;
			
		}
		else{
			parent.document.getElementById("head").style.height=theMenuHeight;
		}
		
	}
	catch(err){
		
	} 
}


if(((navigator.userAgent).split("Netscape").length)>1){
	is_netscape=true;
}


if (navigator.userAgent.indexOf("MSIE") != -1) {
	if (navigator.userAgent.indexOf("MSIE 6.0") != -1) {
		is_ie6=true;
	}
}

if (navigator.userAgent.indexOf("MSIE") != -1) {
	if (navigator.userAgent.indexOf("MSIE 8") != -1) {
		is_ie8=true;
	}
	if (navigator.userAgent.indexOf("MSIE 9") != -1) {
		is_ie9=true;
	}
}

var offtop=53;
var offleft=9; 
var currentclassname = "";
var levelonewidth=120; 
var leveltwowidth=145; 

var menuopen=false;


function activateMenu(nav) {
  if (is_ie && !is_ie9) { 
        var navroot = document.getElementById(nav);
        var lis=navroot.getElementsByTagName("LI");  
        
        for (i=0; i<lis.length; i++) {
        	if(lis[i].lastChild.tagName=="UL"){
				try{
					lis[i].onclick=function() {	
						if(top!=self){
							try{
								//if(parent.document.getElementById('head').allowTransparency==true){
									this.lastChild.style.display="block"; 
									if(is_ie){
										getElementbyClass("willopen");
                    for(var i=0; i<ccollect.length; i++){
											if(ccollect[i].lastChild.tagName){
												ccollect[i].lastChild.className="stayopen";
												if (is_ie6) { 
													var kiddies = this.childNodes; 
													try{
														if(window.parent.isHomePage){
															document.getElementById("level_1").style.top= this.offsetTop + offtop +65; 
														}
														else{
															document.getElementById("level_1").style.top= this.offsetTop + offtop ;
														}
													}
													catch(err){
													
													} 
													document.getElementById("level_1").style.left= this.offsetLeft+2;
													document.getElementById("level_1").style.width= kiddies[2].offsetWidth;
													document.getElementById("level_1").style.height= kiddies[2].offsetHeight; 
												} // end if (is_ie6) {
											}
										}
									} // end if(is_ie){ 
								//}
							}
							catch(err){
							
							} 
						}
						if(top==self){
							this.lastChild.style.display="block"; 
							if(is_ie){
								getElementbyClass("willopen");
								for(var i=0; i<ccollect.length; i++){
									if(ccollect[i].lastChild.tagName){
										ccollect[i].lastChild.className="stayopen";
										if (is_ie6) { 
											var kiddies = this.childNodes; 
											try{
												if(window.parent.isHomePage){
													document.getElementById("level_1").style.top= this.offsetTop + offtop +65; 
												}
												else{
													document.getElementById("level_1").style.top= this.offsetTop + offtop ;
												}
											}
											catch(err){
											
											} 
											document.getElementById("level_1").style.left= this.offsetLeft+2;
											document.getElementById("level_1").style.width= kiddies[2].offsetWidth;
											document.getElementById("level_1").style.height= kiddies[2].offsetHeight; 
										}
									}
								}
							} // end if(is_ie){ 	
						}
					}
				}
				catch(err){


				} 
				
				
				lis[i].onmouseover=function() {	
					if(is_safari){
						
					}
					if(this.lastChild.className=="stayopen"){	
						if(is_ie){
							this.lastChild.style.display="block";
							if(is_ie6){
								if (this.id){ 
									var kiddies = this.childNodes; 
									try{
										if(window.parent.isHomePage){
											document.getElementById("level_1").style.top= this.offsetTop + offtop +65;	
										}
										else{
											document.getElementById("level_1").style.top= this.offsetTop + offtop ;	
										}
									}
									catch(err){
									
									} 
									try{// was error IE8 here on 1 laptop???
										document.getElementById("level_1").style.left= this.offsetLeft+2; 
										document.getElementById("level_1").style.width= kiddies[2].offsetWidth;
										document.getElementById("level_1").style.height= kiddies[2].offsetHeight; 
									}
									catch(err){
									
									}
								}
								else{
									var kiddies = this.childNodes; 
									var grannies = this.offsetParent; 
									var greatgrannies = grannies.parentNode; 
									var grannieschild = grannies.childNodes; 
									var listitems = kiddies[2].childNodes;
									var listitems2 = kiddies[2].childNodes;
									var foo1 = greatgrannies.childNodes;
									var foo2 = foo1[2].childNodes;
									var lastitem = ((listitems[listitems.length-1]).childNodes)[0];
	
									var divheight=20; 
									var charsPerLine=23;
									try{
										if(window.parent.isHomePage){
											document.getElementById("level_2").style.top = this.offsetTop + offtop+2+65;
										}
										else{
											document.getElementById("level_2").style.top = this.offsetTop + offtop+2;
										}
									}
									catch(err){
									
									} 
									document.getElementById("level_2").style.left= greatgrannies.offsetLeft + levelonewidth + offleft-6 + 25;
									document.getElementById("level_2").style.width = leveltwowidth;
									var numLines=Math.ceil((((((listitems[listitems.length-1]).childNodes)[0].innerHTML).length)/charsPerLine));
									if(numLines==1){
										document.getElementById("level_2").style.height =  (  findPosY(listitems[listitems.length-1])  - findPosY(listitems[0])   ) + divheight +1;
									}
									else{
										document.getElementById("level_2").style.height =  (  findPosY(listitems[listitems.length-1])  - findPosY(listitems[0])   ) + divheight + ((numLines-1)*14)+2;
									}
								}
							} //if(is_ie6){
						}
				   	}	
				}
				lis[i].onmouseout=function() { 
					if (is_ie) { 
						this.lastChild.style.display="none";
						if (this.id){ 
							if(!is_ie8){
								document.getElementById("level_1").style.top=0;
								document.getElementById("level_1").style.left=-200;
								document.getElementById("level_1").style.width=1;
								document.getElementById("level_1").style.height=1;
							}
						}
						else{
							if(!is_ie8){
								document.getElementById("level_2").style.top=0;
								document.getElementById("level_2").style.left="-200";
								document.getElementById("level_2").style.width=1;
								document.getElementById("level_2").style.height=1;	
							}
						}
				   } // end if (is_ie)
				}
            }
        }
    } // end if (is_ie)  
	else{
   var navroot = document.getElementById(nav);
		var lis=navroot.getElementsByTagName("LI");
		for (i=0; i<lis.length; i++) {
			if(lis[i].className=="willopen"){
				lis[i].onclick=function() {	
				   try{
						if(window.parent.isHomePage){
							parent.document.getElementById("head").style.height=theMenuHeightHome;
						}
						else{
							parent.document.getElementById("head").style.height=theMenuHeight;
							
						}		
				   }
				   catch(err){
				   }
				   getElementbyClass("willopen");
				   for(var i=0; i<ccollect.length; i++){
					   ccollect[i].className="clickhover";   
				   }
				}
			}
		}
	}
}





function resetmenu(){
	if(is_ie){
		getElementbyClass("stayopen");
		for(var i=0; i<ccollect.length; i++){
			ccollect[i].className="willopen";
		}
	}
	else if (navigator.userAgent.indexOf("Safari") != -1) {
		// done elsewhere....
	}
	else{
		getElementbyClass("clickhover");
		try{
			if(window.parent.isHomePage){
				parent.document.getElementById("head").style.height="125px";
			}
			else{
				parent.document.getElementById("head").style.height="57px";	
			}
			for(var i=0; i<ccollect.length; i++){
				ccollect[i].className="willopen";
			}
		}
		catch(err){
		
		} 
	}
}

window.onload= function(){
    activateMenu('nav'); 
	//document.getElementById("menucontainer").style.float="left";
}



function getElementbyClass(classname){
	ccollect=new Array()
	var inc=0;
	var alltags=document.all? document.all : document.getElementsByTagName("*");
	for (i=0; i<alltags.length; i++){
		if (alltags[i].className==classname) {
			ccollect[inc++]=alltags[i];
		}
	}
}

function findPosX(obj){
var curleft = 0;
if(obj.offsetParent)
	while(1) {
	  curleft += obj.offsetLeft;
	  if(!obj.offsetParent)
		break;
	  obj = obj.offsetParent;
	}
else if(obj.x)
	curleft += obj.x;
return curleft;
}

function findPosY(obj){
var curtop = 0;
if(obj.offsetParent)
	while(1){
	  curtop += obj.offsetTop;
	  if(!obj.offsetParent)
		break;
	  obj = obj.offsetParent;
	}
else if(obj.y)
	curtop += obj.y;
return curtop;
}

function resetmenu_safari(){
	getElementbyClass("clickhover");
	
	try{
		if(window.parent.isHomePage){
			parent.document.getElementById("head").style.height="125px";
		}
		else{
			parent.document.getElementById("head").style.height="57px";	
		}
	}
	catch(err){
	
	} 
	for(var i=0; i<ccollect.length; i++){
		ccollect[i].className="willopen";
	}
}

  

