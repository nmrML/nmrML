/**
 * Creator : David Decraene
 * Version: 2009-02-18
 * Creates a tooltip pointing to the selected HTML element, shown when the element is hovered over.
 * Usage: 
 *   $('myelement').tooltip({html : "someHTML", title : "someTitle"});
 *   $('myelement').tooltip({html : function(){ return $('otherElement').html(); } });
 * Dependency: jQuery 1.2.6 or later
 */
$.fn.extend({
tooltip: function(options) {
	var defaults = {
		/** Defines content: string OR function that returns html content ('this' keyword = wrapper element), return false if you wish to handle it yourself */
		html : "options.html undefined", 
		/** width of the tooltip */
		width : 250,
		/** title of the tooltip */
		title : "Description",
		/** whether or not to parse the title from the anchor element instead (title atrribute or text content for '<a href=""></a>'. */
		parseTitle : false,
		/** CSS style settings */
		css : { 
			anchor : {cursor:'pointer'},
			wrapper : {"font-size" : "12px", "position": "absolute", "z-index": "5", "border" : "2px solid #CCCCCC", "background-color" : "#fff" },
			arrow : {"position": "absolute", "z-index":"101", "height":"23px", "background-repeat": "no-repeat", "background-position": "left top", "left": "-12px"},
			arrow_left : {"background-image": "url(img/tooltip/arrow_left.gif)",  "width":"10px", "top":"-3px" },
			arrow_right : {"background-image": "url(img/tooltip/arrow_right.gif)", "width":"11px", "top":"-2px" },
			title : {"background-color": "#CCCCCC", "text-align": "left", "padding-left": "8px", "padding-bottom": "5px", "padding-top": "2px", "font-weight":"bold"},
			content : {"padding":"10px", "color":"#333333"},
			loader : {"background-image": "url(img/tooltip/loader.gif)", "background-repeat": "no-repeat", "background-position": "center center", "width":"100%", "height":"12px" }
		}
	}
	var settings = $.extend({}, defaults, options);
	var wrapper = null;
	var node = $(this).css(settings.css.anchor).hover(function(){ show(this); }, function(){if(wrapper.remove) { wrapper.remove(); } });

	/** Displays the tooltip */
	function show(el){

		var pos = node.offset();
		var X = 0;

		if(settings.parseTitle){
			if(el.title){ settings.title = el.title; }
			else if(el.nodeName == 'A'){settings.title = el.innerHTML;}
		}
		
		wrapper = $("<div/>").css(settings.css.wrapper).width(settings.width).appendTo("body");
		var content = $("<div/>").css(settings.css.content)
			.append($("<div/>").css(settings.css.loader));
		var Arrow = $("<div/>").css(settings.css.arrow); 
		if($(document).width() - pos.left > settings.width+75){
			Arrow.css(settings.css.arrow_left); 
			X = pos.left + node.width() + 11;
		}else{
			Arrow.css(settings.css.arrow_right); 
			X = pos.left - (settings.width + 15);
		}
		wrapper.append(Arrow)
			.append($("<div/>").text(settings.title).css(settings.css.title))
			.append(content).css({left: X+"px",  top: (pos.top - 3)+"px"}).show();
		if(typeof settings.html == 'string') { content.html(settings.html); }
		else if(typeof settings.html == 'function'){ 
			var h = settings.html.call(wrapper);
			if(h){ content.empty().append(h); }
		}
	}
}
});