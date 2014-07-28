/*
 * jOWL_Exhibit, Simile Exhibit plugin for jOWL, semantic javascript library
 * Creator - David Decraene
 * Version 1.0
 * Website: http://Ontologyonline.org
 * Licensed under the MIT license
 * Verified with JSLint http://www.jslint.com/
 */
(function(){
/**
Loads an exhibit database with individuals matching the target owlclass
make sure the script with src=http://static.simile.mit.edu/exhibit/api-2.0/exhibit-api.js?autoCreate=false is loaded on the page
options:
	status: jquery HTML element that displays status, child element with class msg is used for setting text.
	facet: jquery HTML element to append exhibit facets (filters) to, if not defined then no facets are loaded
	childDepth: number of children to drill down for individual reasoning (affects performance), default 4
	labelforclass: representation name for owlclass in facet, default 'type'
lenspanel css elements: jowl-criterium, jowl-property, jowl-target
*/
jOWL.Exhibit = function(owlclass, options){
	$.extend(jOWL.Exhibit.defaults, options);
	if(!owlclass) { throw "no owl:Class specified for Exhibit.jOWL()"; }
	var jowl = owlclass.type ? owlclass : jOWL(owlclass, {type : "class"});

	function configureDom(){

			var facetpanel = false;
			var lenspanel = false, lensclone = false, lenswrapper = false;

			function configureCriteria(lens_el, property, label){
				if(!label) { label = property; }
				var x = lens_el.attr("ex:if-exists", "."+property);
				$('.'+jOWL.Exhibit.defaults.css.property, x).text(label);
				$('.'+jOWL.Exhibit.defaults.css.target, x).attr("ex:content", "."+property);
				return x;
			}
			
			if(jOWL.Exhibit.defaults.facet || jOWL.Exhibit.defaults.lens)
			{
				if(jOWL.Exhibit.defaults.facet) { facetpanel = 
					jOWL.Exhibit.defaults.facet.empty().append($("<div ex:role='facet' ex:expression='.owlClass' ex:facetLabel='"+jOWL.Exhibit.defaults.labelforclass+"'/>")); 
				}
				if(jOWL.Exhibit.defaults.lens) { 
					lenspanel = jOWL.Exhibit.defaults.lens.attr("ex:role", "lens");
					var lbl = $('.'+jOWL.Exhibit.defaults.css.label).attr('ex:content', '.label');
					if(!lbl.length) { throw 'Lens Template: no element found with attribute class="'+jOWL.Exhibit.defaults.css.label+'"'; }
					var jowlcrit = $("."+jOWL.Exhibit.defaults.css.criterium, lenspanel);	
					lensclone = jowlcrit.clone(true); 
					lenswrapper = jowlcrit.parent();//.empty();	
					jowlcrit.remove();					
					var type = $('.'+jOWL.Exhibit.defaults.css.type, lenspanel);
					if(type){ type.attr("ex:content", ".owlClass"); }
				}
				jowl.sourceof().each(function(item, i){
					if(facetpanel){ facetpanel.append($("<div ex:role='facet' ex:expression='."+item.property.name+"' ex:facetLabel='"+item.property.name+"'/>")); }
					if(lenspanel){ configureCriteria(lensclone.clone(true), item.property.name).appendTo(lenswrapper); }
				});
				if(lenspanel){ lenspanel.show(); }
			}
			jOWL.Exhibit.exhibit.configureFromDOM();
		}

	function loadJSON(jowl){
		var itemLabel = jowl.label();
		var query = new jOWL.SPARQL_DL("Type(?x, concept)", {"concept": jowl}).execute({
			childDepth : jOWL.Exhibit.defaults.childDepth,
			chewsize : 15,
			onComplete : function(indarr){
					var results = [];
					indarr.jOWLArray ('?x').each(function(){
						var entry = {};
						this.valueRestrictions(true).each(function(){
							if(!entry[this.property.URI]){ entry[this.property.URI] = []; }
							entry[this.property.URI].push(this.target);
						});
						entry.label = this.label();
						entry.type = itemLabel;
						entry.owlClass = this.Class;
						results.push(entry);
					});
					if(results.length){ jOWL.Exhibit.exhibit.getDatabase().loadData({items : results});	}
					if(jOWL.Exhibit.defaults.status){ jOWL.Exhibit.defaults.status.hide(); }
					jOWL.Exhibit.defaults.finalize(); 
					}
			}); 
	}

	function complete(){
		configureDom();
		if(jOWL.Exhibit.defaults.status){ $('.msg', jOWL.Exhibit.defaults.status).text("Reasoning over Individuals"); }
		setTimeout(function(){loadJSON(jowl);}, 5); 
	}

	if(!jOWL.Exhibit.init) {
			jOWL.index("Thing");
			setTimeout(function(){
				jOWL.Exhibit.database = Exhibit.Database.create();					
				jOWL.Exhibit.exhibit = Exhibit.create();
				jOWL.Exhibit.init = true;
				setTimeout(complete, 5);
				}, 5);
	}
	else  { 
		jOWL.Exhibit.exhibit.getDatabase().removeAllStatements(); //endif
		setTimeout(complete, 5);
		}
	

	};
jOWL.Exhibit.defaults = {childDepth:  4, labelforclass : "type",
	css : { label : 'exhibit-lens-title', criterium : 'jowl-criterium', property : 'jowl-property', target : 'jowl-target', type : 'jowl-type' },
	finalize : function(){}
};
})();
