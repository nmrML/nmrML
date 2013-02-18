  var annee = 2013;

  function frameBuster() {
  if (parent.location != window.location) {parent.location = window.location;}
  };

  function cprightYear() {
    var div = document.getElementById("look");
    var texte = document.createTextNode("");
    texte.data = annee;
    div.appendChild(texte);
  }

  function lastUpDate() {
    var da = document.getElementById("ppm");
    var la = document.lastModified;
    da.appendChild(document.createTextNode(la));
  }

  function openweb(webpage) {
  window.open(webpage, "", 
  "scrollbars=yes,toolbar=no,menubar=no,location=no,status=no,height=350,width=600,resizable=yes,top=0,left=150");
  };

  subHover = function() {
  var subEls = document.getElementById("navigationbardown").getElementsByTagName("LI");
  for (var i=0; i<subEls.length; i++) {
       subEls[i].onmouseover = function() {
         this.className += "subhover";
       };
       subEls[i].onmouseout = function() {
         this.className = this.className.replace(new RegExp("subhover\\b"), "");
       };
    };
  };

  subHover2 = function() {
  var subEls = document.getElementById("navigationbartop").getElementsByTagName("LI");
  for (var i=0; i<subEls.length; i++) {
       subEls[i].onmouseover = function() {
         this.className += "subhover";
       };
       subEls[i].onmouseout = function() {
         this.className = this.className.replace(new RegExp("subhover\\b"), "");
       };
    };
  };

  if (window.attachEvent) window.attachEvent("onload", subHover);
  if (window.attachEvent) window.attachEvent("onload", subHover2);

