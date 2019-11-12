/**
* jOWL - a jQuery plugin for traversing and visualizing OWL-DL documents.
* Creator - David Decraene
* Version 1.0
* Website: 
*	http://Ontologyonline.org
* Licensed under the MIT license 
*	http://www.opensource.org/licenses/mit-license.php
* Verified with JSLint 
*	http://www.jslint.com/
*/

jOWL = window.jOWL = function( resource, options ){ return jOWL.getResource( resource, options );  };
jOWL.version = "1.0";

/** for debugging compatibility */
	try { console.log('...'); } catch(e) { console = window.console = { log: function() {} } }
	if ($.browser.opera && opera.postError) { console = window.console = { log : function(){opera.postError(arguments); } }; }



(function($){

/** 
* if no param: @return string of main namespaces
* if 1 param: assume a documentElement, parse namespaces
* if prefix & URI: Bind prefix to namespace URI 
*/
jOWL.NS = function(prefix, URI){
	if(!arguments.length)
	{ return "xmlns:"+jOWL.NS.owl.prefix+"='"+jOWL.NS.owl()+"' xmlns:"+jOWL.NS.rdf.prefix+"='"+jOWL.NS.rdf()+"' xmlns:"+jOWL.NS.rdfs.prefix+"='"+jOWL.NS.rdfs()+"' xmlns:"+jOWL.NS.xsd.prefix+" ='"+jOWL.NS.xsd()+"'";}

	if(arguments.length == 1){
		var attr = prefix.get(0).attributes;
		for(var i=0;i<attr.length;i++){
			var nn = attr[i].nodeName.split(':');
			if(nn.length == 2){
				if(attr[i].nodeValue == jOWL.NS.owl.URI){ jOWL.NS.owl.prefix = nn[1];}
				else if(attr[i].nodeValue == jOWL.NS.rdf.URI){ jOWL.NS.rdf.prefix = nn[1];}
				else if(attr[i].nodeValue == jOWL.NS.rdfs.URI){ jOWL.NS.rdfs.prefix = nn[1];}
				else if(attr[i].nodeValue == jOWL.NS.xsd.URI){ jOWL.NS.xsd.prefix = nn[1];}
				else { jOWL.NS(nn[1], attr[i].nodeValue);}
			}
		}
		jOWL.namespace =  prefix.xmlAttr('xml:base') || prefix.xmlAttr('xmlns');
		return;
	}
	jOWL.NS[prefix] = function(element){
		if(element){
			return (arguments.callee.prefix == 'base') ? element : arguments.callee.prefix + ":" + element;
			}
		return arguments.callee.URI;
		};
	jOWL.NS[prefix].prefix = prefix;
	jOWL.NS[prefix].URI = URI;	
};

var __ = jOWL.NS;

/** set Main namespaces */
__("owl", "http://www.w3.org/2002/07/owl#");
__("rdf", "http://www.w3.org/1999/02/22-rdf-syntax-ns#");
__("rdfs", "http://www.w3.org/2000/01/rdf-schema#");
__("xsd", "http://www.w3.org/2001/XMLSchema#");

/** jQuery function additions for easy parsing of identities */
$.fn.extend({
	/** Used for Opera compatibility when parsing xml attributes, nodeName must be checked, in contrast to native jquery call attr() */
	xmlAttr : function(nodeName){
		var t = this[0].attributes; if(!t){ return;}
		for(var i =0;i<t.length;i++){
			if(t[i].nodeName == nodeName){ return t[i].nodeValue;}
		}
	},
	RDF_ID : function(match){
		var res = this.xmlAttr(__.rdf('ID'));
		if(!res){ return false;}
		res = jOWL.resolveURI(res);
		if(match){
			return res.toLowerCase() == (jOWL.resolveURI(match.toString())).toLowerCase();}
		return res;
		},
	RDF_Resource : function(match){
		function getClassName(dom){
			var cl = jOWL.Xpath(__.owl("Class"), dom);
			if(cl.length == 1){ return new jOWL.Ontology.Class(cl).URI;}
			return false;
		}
		if(!this.length){ return false;}
		var rsrc = this.xmlAttr(__.rdf('resource'));
		if(!rsrc){
			var dom = this.get(0);
			switch(dom.nodeName){
				case __.rdfs("subClassOf"): rsrc = getClassName(dom); break;
				case __.owl("disjointWith"): rsrc = getClassName(dom); break;
				case __.owl("allValuesFrom"): rsrc = getClassName(dom); break;
				case __.owl("someValuesFrom"): rsrc = getClassName(dom); break;
				case __.owl("onProperty"):
					var t = jOWL.Xpath(__.owl("ObjectProperty"), dom);
					if(t.length === 0){ t = jOWL.Xpath(__.owl("DatatypeProperty"), dom);}
					if(t.length === 0){ t = jOWL.Xpath(__.owl("FunctionalProperty"), dom);}
					rsrc = t.xmlAttr(__.rdf('about')); break;
				default: return false;
			}
		}
		if(!rsrc){ return false;}
		rsrc = jOWL.resolveURI(rsrc);
		if(match){ return rsrc.toLowerCase() == (jOWL.resolveURI(match.toString())).toLowerCase();}
		return rsrc;
		},
	RDF_About : function(match){
		var res = this.xmlAttr(__.rdf('about'));
		if(!res){ return false;}
		res = jOWL.resolveURI(res);
		if(match){
			return res.toLowerCase() == (jOWL.resolveURI(match.toString())).toLowerCase();}
		return res;
		}
});

/** Check XPath implementation */
if( document.implementation.hasFeature("XPath", "3.0") ){
	XMLDocument.prototype.selectNodes = function(cXPathString, xNode){
		if( !xNode ){ xNode = this;}
		var oNSResolver = this.createNSResolver(this.documentElement);
		var aItems = this.evaluate(cXPathString, xNode, oNSResolver, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null); var aResult = []; for( var i = 0; i < aItems.snapshotLength; i++){ aResult[i] = aItems.snapshotItem(i);}  
		return aResult; 
		};
	Element.prototype.selectNodes = function(cXPathString){  
		if(this.ownerDocument.selectNodes)  {  return this.ownerDocument.selectNodes(cXPathString, this);}
		else{throw "For XML Elements Only";} 
		}; 
	XMLDocument.prototype.selectSingleNode = function(cXPathString, xNode){ if( !xNode ){ xNode = this;}
		var xItems = this.selectNodes(cXPathString, xNode); if( xItems.length > 0 ){  return xItems[0];} else {  return null;}
		};
	Element.prototype.selectSingleNode = function(cXPathString){
		if(this.ownerDocument.selectSingleNode)  {  return this.ownerDocument.selectSingleNode(cXPathString, this);}
		else{throw "For XML Elements Only";} 
		};  
}

/** @return A jQuery array of xml elements */
jOWL.Xpath = function(selector, elem){
	var node = null;
	if(elem){ if(elem.each){ node = elem.get(0);} else { node = elem;} }
	var arr = node ? node.selectNodes(selector) : jOWL.document.selectNodes(selector);
	if($.browser.msie){ return $($.makeArray(arr));} return $(arr); //this is needed for IE, it returns a length of 1 on empty node array
};

/** @return a String array of class references */
jOWL.Xpath.classes = function(jnode){
	var cl = [];
	jOWL.Xpath(__.rdfs("subClassOf"), jnode)
		.each(function(){
			var res = $(this).RDF_Resource();
			if(res){ cl.push(res);}
		});

	jOWL.Xpath(__.owl("intersectionOf")+"/"+__.owl("Class"), jnode)
		.each(function(){
			var p = $(this).RDF_About(); if(p){ cl.push(p);}
		});
	return cl;
};

/** Functions stored in jOWL.priv are intended for local access only, to avoid a closure function */
jOWL.priv = {
	/** Arrray functions */
	Array : {
		isArray : function(array){
			return Object.prototype.toString.call(array) === '[object Array]';
		},
		pushUnique : function(array, item){
			if(jOWL.priv.Array.getIndex(array, item) === -1){	array.push(item); return true;}
			return false;
		},
		getIndex : function(array, item){
			for (var i=0; i<array.length; i++){ if(item == array[i]){ return i;} }
			return -1;
		},
		/** Sorted array as input, returns the same array without duplicates. */
		unique : function(array){
			var result = []; var lastValue="";
			for (var i=0; i<array.length; i++)
			{
				var curValue=array[i];
				if(curValue != lastValue){ result[result.length] = curValue;}
				lastValue=curValue;
			}
			return result;
		}
	}
};

/** Make values work with jOWL.Ontology.Array */
jOWL.Literal = function(value){
	this.name = value;
};

/** Access to the owl:Ontology element, also the main coding namespace for ontology objects */
jOWL.Ontology = function(){
	if(!(this instanceof arguments.callee)){ return new jOWL.Ontology();}
	this.parse(jOWL.Xpath("/"+__.rdf("RDF")+"/"+__.owl("Ontology")));
	return this;
};

/** 'superclass' for referencable ontology objects */
jOWL.Ontology.Thing = function(jnode){
	this.parse(jnode);
};

jOWL.Ontology.Thing.prototype = {
	jOWL : jOWL.version,
	equals : function(id){
		var URI = (typeof id == "string") ? jOWL.resolveURI(id) : id.URI;
		return URI === this.URI;
	},
	/** Initialization */
	parse : function(jnode){
		if(!jnode.length){ return;}
		var identifier;
		if(typeof jnode == 'string'){
			identifier = jnode;
			jnode = $();
			}
		else {
			identifier = jnode.RDF_ID() || jnode.RDF_About();
			if(!identifier){identifier = "anonymousOntologyObject";
			this.isAnonymous = true;
			}
		}
		identifier = jOWL.resolveURI(identifier);
		this.isExternal = jOWL.isExternal(identifier);
		if(this.isExternal){this.baseURI = this.isExternal[0]; this.name = this.isExternal[1]; this.URI = this.baseURI+this.name;}
		else { this.baseURI = jOWL.namespace; this.name = identifier; this.URI = this.name;}
		this.jnode = jnode;
		this.type = jnode.get(0).nodeName;
	},
	/** @return A jQuery array of elements matching the annotation (qualified name or annotation Property) */
	annotations : function(annotation){
		return jOWL.Xpath(annotation, this.jnode);
	},
	/** @return rdfs:comment annotations */
	description : function(){
		return $.map(this.annotations(__.rdfs('comment')), function(n){ return $(n).text();});
	},
	/**
	@return Array of Arrays, where secondary array is of form: [0] = term (rdfs:label) , [1] = identifier, [2] = language; [3] = type of object
	example:
	[
		["bleu", "blue", "fr", "owl:Class"]
	]
	*/
	terms : function(){
		var terms = [], self = this;
		if(jOWL.options.dictionary.addID && this.name != "anonymousOntologyObject"){ terms.push([this.name.beautify(), this.URI, jOWL.options.defaultlocale, this.type]);}
		this.annotations(__.rdfs('label')).each(function(){
			var lbl = $(this);
			var locale = lbl.xmlAttr("xml:lang") || jOWL.options.defaultlocale;
			var txt = lbl.text();
			var match = false;
			for(var i =0;i<terms.length;i++){
			if(terms[i][0].toUpperCase() == txt.toUpperCase() && terms[i][2] == locale){ match = true;}
			}
			if(!match){ terms.push([lbl.text(), self.URI, locale, self.type]);}
		});
		return terms;
	},
	/** @return A representation name */
	label : function(){
		var label = false;
		this.annotations(__.rdfs('label')).each(function(){
			var $label = $(this);
			if(jOWL.options.locale){
				var lang = $label.xmlAttr('xml:lang') || jOWL.options.defaultlocale;
				if(lang == jOWL.options.locale){ label = $label.text(); return false;}
			} else { label = $label.text(); return false;}
		});
		if(label){ return label;}
		if(this.name == "anonymousOntologyObject"){ return jOWL.Manchester(this) || "anonymous Object";}
		if(jOWL.options.niceClassLabels && (this.isClass || this.isThing)){
			return this.name.beautify();
		}
		return this.name;
	},
	/** Binds the Ontology element to the jQuery element for visual representation 
	* @return jQuery Element
	*/
	bind : function(jqelem){
		return jqelem.text(this.label()).attr('typeof', this.type).attr('title', this.URI);
	}
};

jOWL.Ontology.prototype = jOWL.Ontology.Thing.prototype;

/** used for jOWL.Ontology.Individual.sourceof */
jOWL.priv.testObjectTarget = function(target, matchtarget){
	if(target.isArray){
		for(var i=0;i<target.length;i++){
			if(jOWL.priv.testObjectTarget(target.get(i), matchtarget)){ return true;}
		}
		return false;
	}
	//if the target is a class, fetch individuals instead.
	else if(target.isClass){
		 var a = target.individuals();
		 for(var i=0;i<a.length;i++){
			if(a.get(i).URI == matchtarget){ return true;}
		}
	}
	else if(target.URI == matchtarget){ return true;}
	return false;
};

/** access to Individuals of the ontology*/
jOWL.Ontology.Individual = function(jnode, owlclass){	
	this.parse(jnode);
	if(this.type == __.owl("Thing")){
	var t = jOWL.Xpath(__.rdf('type'), this.jnode);
		if(!t.length){ throw "unable to find a Class for the Individual "+this.name;}
		this.Class = $(t[0]).RDF_Resource();
	}
	else {
		this.Class = jOWL.resolveURI(jnode.get(0));
	}
	this.type = __.owl("Thing");
	if(owlclass){ this.owlClass(owlclass);}
};

jOWL.Ontology.Individual.prototype = $.extend({}, jOWL.Ontology.Thing.prototype, {
	isThing : true,
	/** @return The owl:Class */
	owlClass : function(owlclass){
		if(owlclass){ jOWL.data(this.name, "class", owlclass);}
		else {
			var cl = jOWL.data(this.name, "class");
			if(!cl){ cl = jOWL(this.Class); if(cl){ this.owlClass(cl);} }
			return cl;
		}
	},
	/** Access to restrictions */
	sourceof : function(property, target, options){
		options = $.extend({
			inherited : true, // add restrictions specified on parents as well
			transitive : true,
			ignoreGenerics : false, //if a parent has an identical property, with another target 'Thing', skip that restriction
			ignoreClasses : true,
			valuesOnly : true
		}, options);

		var results = new jOWL.Ontology.Array();

		this.jnode.children().filter(function(){return (this.prefix != __.rdfs.prefix && this.prefix != __.rdf.prefix && this.prefix != __.owl.prefix);})
			.each(function(){
			var restriction = new jOWL.Ontology.Restriction($(this));
			var propertyMatch = property ? false : true;
			var targetMatch = target ? false : true;

			if(!propertyMatch){
				if( property.isArray){ propertyMatch = property.contains(restriction.property);}
				else { propertyMatch = (property.URI == restriction.property.URI);}
				if(!propertyMatch){ return;}
			}

			if(!target){
				if(options.transitive && restriction.property.isTransitive && !options.ignoreGenerics){
					var rTarget = restriction.getTarget();
					var transitives = rTarget.sourceof(restriction.property, null, options);
					results.concat(transitives);
				}
			}
			else {
				if(restriction.property.isObjectProperty){
					targetMatch = jOWL.priv.testObjectTarget(target, restriction.target);
					if(!targetMatch && options.transitive && restriction.property.isTransitive){
						var rTransitives = restriction.getTarget().sourceof(restriction.property, target, options);
						if(rTransitives.length > 0){ targetMatch = true;}
					}
				}
				else if(restriction.property.isDatatypeProperty){
					targetMatch = restriction.property.assert(restriction.target, target);
				}
				else { targetMatch = (target == restriction.target);}
			}
			if(propertyMatch && targetMatch){ results.pushUnique(restriction);}

		});
		if(options.inherited){ 
			var clRestrictions = this.owlClass().sourceof(property, target, options)
				.each(function(){
				//target can be a class, null, a duplicate individual...
				var clRestr = this;
				if(options.valuesOnly && clRestr.target === null){return;}
				var clTarget = this.getTarget();
				if(clTarget.isClass && options.ignoreClasses){ return;}

				var containsProperty = false;
				for(var i = 0;i<results.length;i++){
					var restr = results.get(i);
					if(restr.property.URI == clRestr.property.URI){
						containsProperty = true;
						if(!options.ignoreGenerics){
							if(clRestr.target != restr.target){ results.pushUnique(clRestr);}
						}
					}
				}
				if(!containsProperty){ results.pushUnique(clRestr);}
			});
		}
		return results;

	},
	localRestrictions : function(property, target){
		return this.sourceof(property, target, {inherited : false, transitive : false });
	},
	/** Include generic will add transitivity reasoning */
	valueRestrictions : function(includeGeneric){
		return this.sourceof(null, null, {ignoreGenerics : !includeGeneric, valuesOnly : true });
	}
});

/** jNode is of type owl:Restriction */
jOWL.Ontology.Restriction = function(jnode){

	var jprop, prop, op, restrtype;

	this.cachedTarget = null;

	if(jnode.get(0).nodeName != __.owl("Restriction")){
		this.property = jOWL(jOWL.resolveURI(jnode.get(0)), {type: "property"});
		this.target = jnode.RDF_Resource() || jnode.text();
		restrtype = "Individual";
	}
	else
	{
		jprop = jOWL.Xpath(__.owl("onProperty"), jnode);
		prop = jprop.RDF_Resource(); if(!prop){ throw "no property found for the given owl:restriction";}
		op = jprop.siblings(); 
		restrtype = op.get(0).nodeName;
		this.property = jOWL(prop, {type: "property"});
		this.target = null; //string only
	}

	this.restriction = { minCard: false, maxCard : false, some: [], all : [], value : false };
	this.type = jnode.get(0).nodeName;
	this.isAnonymous = true;
	this.isValueRestriction = (restrtype == __.owl('someValuesFrom') || restrtype == __.owl('allValuesFrom') || restrtype == __.owl('hasValue'));
	this.isCardinalityRestriction = (restrtype == __.owl('cardinality') || restrtype == __.owl('maxCardinality') || restrtype == __.owl('minCardinality'));

	if(!this.property || !restrtype){ throw "badly formed owl:restriction";}
	switch(restrtype){
		case __.owl('cardinality'): this.restriction.minCard = this.restriction.maxCard = parseInt(op.text(), 10); break;
		case __.owl('maxCardinality'): this.restriction.maxCard = parseInt(op.text(), 10); break;
		case __.owl('minCardinality'): this.restriction.minCard = parseInt(op.text(), 10); break;
		case __.owl('hasValue'): var res = op.RDF_Resource(); if(res){ this.target = res;} break;
	}
	if(this.property.isObjectProperty){
		if(this.isCardinalityRestriction && this.property.range){ this.target = this.property.range;}
		else if(this.isValueRestriction){
			var t = op.RDF_Resource(); 
			if(t == "anonymousOntologyObject"){//nested groupings, anonymous classes
				this.cachedTarget = new jOWL.Ontology.Class(jOWL.Xpath(__.owl("Class"), op));
			}
			this.target = t;
		}
	}

	var suffix = this.target || this.restrtype;
	this.name = this.property.name+'#'+suffix;
	return this;
};

jOWL.Ontology.Restriction.prototype = {
	jOWL : jOWL.version,
	isRestriction : true,
	bind : function(){return null;},
	merge : function(crit){
		if(this.isCardinalityRestriction && crit.isValueRestriction ){ this.target = crit.target; return true;}
		else if(this.isValueRestriction && crit.isCardinalityRestriction){
			switch(crit.restrtype){
			case __.owl('cardinality'): this.restriction.minCard = this.restriction.maxCard = crit.restriction.minCard; return true;
			case __.owl('minCardinality'): this.restriction.minCard = crit.restriction.minCard; return true;
			case __.owl('maxCardinality'): this.restriction.maxCard = crit.restriction.maxCard; return true;
			}
		}
		return false;
	},
	getTarget : function(){
		if(!this.target){ return jOWL('Thing');}
		if(this.cachedTarget){ return this.cachedTarget;}
		this.cachedTarget = (this.property.isObjectProperty) ? jOWL(this.target) : new jOWL.Literal(this.target);
		return this.cachedTarget;	
	},
	equals : function(restr){
		if(!restr.isRestriction){ return false;}
		if(this.property.URI == restr.property.URI){
			if(this.target == 'anonymousOntologyObject'){return false;}//oneof lists etc unsupported right now
			if(this.target && this.target === restr.target){ return true;}
		}
		return false;
	}
};

/** Datatype Logic, local functions */
jOWL.priv.Dt = function(options){
	this.settings = $.extend({base: null, pattern : null, assert: function(b){return true;}, match: function(a, b){return true;}}, options);
	this.base = jOWL.Ontology.Datatype[this.settings.base];
};

jOWL.priv.Dt.prototype = {
	sanitize : function(b){
		if(this.settings.sanitize){ return this.settings.sanitize(b);}
		if(this.base && this.base.sanitize){ return this.base.sanitize(b);}
	},
	assert : function(b){
		var v = this.sanitize(b); if(v !== undefined){ b = v;}
		if(this.base && !this.base.assert(b)){ return false;}
		if(this.settings.pattern && !this.settings.pattern.test(b)){ return false;}
		return this.settings.assert(b);
	},
	match : function(a, b){
		var v = this.sanitize(b); if(v !== undefined){ b = v;}
		if(!this.assert(b)){ return false;}
		if(this.base && !this.base.match(a, b)){ return false;}
		return this.settings.match(a, b);
	}
};

jOWL.Ontology.Datatype = function(URI, options){
	jOWL.Ontology.Datatype[URI] = new jOWL.priv.Dt(options);
};

/** Datatype Definitions */
jOWL.Ontology.Datatype(__.xsd()+"integer", {sanitize : function(x){return  parseInt(x, 10);}, assert : function(x){ return Math.round(x) == x;}, match : function(a, b){
	var check = parseInt(a, 10);
	if(!isNaN(check)){ return check == b;}
	var arr = a.split('&&');
	for(var i=0;i<arr.length;i++){ arr[i] = b+arr[i];}
	try {
		return eval(arr.join(' && '));
	} catch(e){ return false;}
} });
jOWL.Ontology.Datatype(__.xsd()+"positiveInteger", {base: __.xsd()+"integer", assert : function(x){ return x > 0;} });
jOWL.Ontology.Datatype(__.xsd()+"decimal", {base: __.xsd()+"integer" });
jOWL.Ontology.Datatype(__.xsd()+"float", {base: __.xsd()+"integer" });
jOWL.Ontology.Datatype(__.xsd()+"double", {base: __.xsd()+"integer" });
jOWL.Ontology.Datatype(__.xsd()+"negativeInteger", {base: __.xsd()+"integer", assert : function(x){ return x < 0;} });
jOWL.Ontology.Datatype(__.xsd()+"nonNegativeInteger", {base: __.xsd()+"integer", assert : function(x){ return x >= 0;} });
jOWL.Ontology.Datatype(__.xsd()+"nonPositiveInteger", {base: __.xsd()+"integer", assert : function(x){ return x <= 0;} });
jOWL.Ontology.Datatype(__.xsd()+"string");

var URIPattern = /^([a-z0-9+.\-]+):(?:\/\/(?:((?:[a-z0-9-._~!$&'()*+,;=:]|%[0-9A-F]{2})*)@)?((?:[a-z0-9-._~!$&'()*+,;=]|%[0-9A-F]{2})*)(?::(\d*))?(\/(?:[a-z0-9-._~!$&'()*+,;=:@\/]|%[0-9A-F]{2})*)?|(\/?(?:[a-z0-9-._~!$&'()*+,;=:@]|%[0-9A-F]{2})+(?:[a-z0-9-._~!$&'()*+,;=:@\/]|%[0-9A-F]{2})*)?)(?:\?((?:[a-z0-9-._~!$&'()*+,;=:\/?@]|%[0-9A-F]{2})*))?(?:#((?:[a-z0-9-._~!$&'()*+,;=:\/?@]|%[0-9A-F]{2})*))?$/i;    

jOWL.Ontology.Datatype(__.xsd()+"anyURI", {base: __.xsd()+"string", pattern : URIPattern });
jOWL.Ontology.Datatype(__.xsd()+"boolean", {sanitize : function(x){
		if(typeof x == 'boolean'){ return x;}
		if(x == 'true'){ return true;}
		if(x == 'false'){ return false;}
	}, assert : function(x){
		return typeof x == 'boolean';
	}, match: function(a, b){
		if(a === "false"){ a = false;}
		if(a === "true"){ a = true;}
		return (a === b);
}});

/** 'superclass' for Properties */
jOWL.Ontology.Property = function(jnode){
	var r = this.parseProperty(jnode);
	if(r){ return r;}
};

jOWL.Ontology.Property.prototype = $.extend({}, jOWL.Ontology.Thing.prototype,{
	isProperty : true,
	parseProperty : function(jnode){
		if(!jnode || typeof jnode == 'string'){
			this.domain = this.range = null;
			this.parse(jnode);
			return;
		}
		if(jOWL.options.cacheProperties && jOWL.indices.IDs){
			var res = jnode.RDF_ID() || jnode.RDF_About();
			var c = jOWL.index('property').get(res);
			if(c){ return c;}
		}
		this.parse(jnode);
		this.domain= $(this.jnode.get(0).selectSingleNode(__.rdfs('domain'))).RDF_Resource();
		this.range = $(this.jnode.get(0).selectSingleNode(__.rdfs('range'))).RDF_Resource();	
	}
});

/** access to Datatype properties */
jOWL.Ontology.DatatypeProperty = function(jnode){
	var r = this.parseProperty(jnode);
	if(r){ return r;}
	if(this.type == __.owl("AnnotationProperty")){ this.range = __.xsd()+"string";}
};

jOWL.Ontology.DatatypeProperty.prototype = $.extend({}, jOWL.Ontology.Thing.prototype, jOWL.Ontology.Property.prototype, {
	isDatatypeProperty : true,
	/** check datatype values against this */
	assert : function(targetValue, value){
		var self = this;
		var dt = jOWL.Ontology.Datatype[this.range];
		if(!dt){
			console.log(this.range+" datatype reasoning not implemented");
			return true;
		}
		if(value === undefined){ return dt.assert(targetValue);}
		else {return dt.match(value, targetValue);}
	}
});

/** access to Object properties */
jOWL.Ontology.ObjectProperty = function(jnode){
	var r = this.parseProperty(jnode);	
	if(r){ return r;}
	var self = this;
	jOWL.Xpath(__.rdf('type'), this.jnode).each(function(){
		if($(this).RDF_Resource() == __.owl()+"TransitiveProperty"){ self.isTransitive = true;}
	});
	if(this.jnode.get(0).nodeName == __.owl("TransitiveProperty")){ self.isTransitive = true;}
};

jOWL.Ontology.ObjectProperty.prototype = $.extend({}, jOWL.Ontology.Thing.prototype, jOWL.Ontology.Property.prototype, {
	isObjectProperty : true
});

/** access to an owl:Class */
jOWL.Ontology.Class = function(jnode){
	this.parse(jnode);
};

/** @return jOWL Array of Restrictions */
jOWL.Xpath.restrictions = function(jnode){
	var result = new jOWL.Ontology.Array();
	jOWL.Xpath(__.rdfs("subClassOf")+"/"+__.owl("Restriction"), jnode)
		.add(jOWL.Xpath(__.owl("intersectionOf")+"/"+__.owl("Restriction"), jnode))
		.each(function(){
			result.push(new jOWL.Ontology.Restriction($(this)));
		});
	return result;
};

/** Internal Use */
jOWL.Ontology.Intersection = function(jnode){
	var self = this;
	this.jnode = jnode;
	this._arr = [];
	this.URI = this.jnode.parent().RDF_ID();
	this.matches = {};
	jOWL.Xpath(__.owl("Restriction"), jnode).each(function(){
		var restr = new jOWL.Ontology.Restriction($(this));
		if(restr.isValueRestriction){self._arr.push(restr);}
	});
	jOWL.Xpath(__.owl('Class'), jnode).each(function(){
		var uri = $(this).RDF_About();
		if(uri){ self._arr.push(jOWL(uri));}
	});
};

jOWL.Ontology.Intersection.prototype = {
	isIntersection : true,
	jOWL : jOWL.version,
	match : function(id, cls, clRestr){
		if(id == this.URI){ return false;}
		if(this.matches[id] !== undefined){ return this.matches[id]; }//local cache

		for(var i =0;i<this._arr.length;i++){
			var entry = this._arr[i];
			var m = false;
			if(entry.isRestriction){
				clRestr.each(function(){
					if(this.equals(entry)){ m = true; return false;}
				});
				if(!m) {
					this.matches[id] = false;
					return false;
				}
			} else if(entry.isClass){
				for(var j = 0;j<cls.length;j++){
					if(entry.equals(cls[j])){m = true; break;}
					var it = jOWL.index('ID')[cls[j]];
					if(it){
						var narr = jOWL.Xpath.classes(jOWL.index('ID')[cls[j]].jnode);
						for (var z=0;z<narr.length ; z++){
							if(entry.equals(narr[z])){m = true; break;}
						}
					}
				}
				if(!m){
					this.matches[id] = false;
					return false;
				}
			}
		}
		this.matches[id] = true;
		return this.matches[id];
	},
	equals : function(isect){
		if(!isect.isIntersection){ return false;}
			for(var i =0;i<this._arr.length;i++){
				var match = false;
				for(var j = 0;j<isect._arr.length;j++){
					if(isect._arr[j].equals(this._arr[i])){ match = true;}
				}
				if(!match){ return false;}
			}
		return true;
	}
};

jOWL.Ontology.Class.prototype = $.extend({}, jOWL.Ontology.Thing.prototype, {
	isClass : true,
	/** @return A jOWL.Ontology.Array of individuals for this class & its subclasses */
	individuals : function(){
		var arr = new jOWL.Ontology.Array();
		var q = new jOWL.SPARQL_DL("Type(?x, "+this.name+")").execute({async: false, onComplete: function(r){ arr = r.jOWLArray("?x");}  });
		return arr;
	},
	/** @return A jOWL.Ontology.Array of individuals (if oneOf list) */
	oneOf : function(){
		var arr = new jOWL.Ontology.Array();
		var oneOf = this.jnode.children().filter(function(){return this.tagName == __.owl("oneOf");});
		oneOf.children().each(function(){
			arr.push(jOWL($(this).RDF_About()));
		});
		return arr;
	},
	/** @return A jOWL.Ontology.Array of direct children */
	children : function(){
		var that = this;
		var oChildren = jOWL.data(this.name, "children");
		if(oChildren){ return oChildren;}
		oChildren = new jOWL.Ontology.Array();
		if(this.oneOf().length){return oChildren;}
		var URI = this.URI;

		for(x in jOWL.index('ID')){
			if(x === this.URI){ continue;}
			var node = jOWL.index('ID')[x]; 
			if(!node.isClass){continue;}
			var cls = jOWL.Xpath.classes(node.jnode); //direct subClasses
			for(var i=0;i<cls.length;i++){
				if(this.equals(cls[i])){
					oChildren.push(node);
				}
			}
			var clRestr = jOWL.Xpath.restrictions(node.jnode);
			var intersections = jOWL.index("intersection")[URI];
			if(intersections){
				intersections.each(function(){//fully defined Subclasses
					if(this.match(x, cls, clRestr)){oChildren.push(node);}
				});
			}
		}
		//an ObjectProperty mentions this as domain
		jOWL.index("property").each(function(){
		if(this.domain == that.name){
			var nodes = jOWL.Xpath('//'+__.owl('onProperty')+'[@'+__.rdf('resource')+'="#'+this.name+'"]/parent::'+__.owl('Restriction')+'/..');
			nodes.filter(function(){ return (this.nodeName == __.owl('intersectionOf') || this.nodeName == __.rdfs('subClassOf'));
			}).each(function(){
				var cl = jOWL($(this.selectSingleNode('parent::'+__.owl('Class'))));
				if(!oChildren.contains(cl) && cl.name != that.name && cl.name !== undefined){ oChildren.push(cl);}
				});
			}
			});
		//filter out redundancies
		oChildren.filter(function(){
			this.hierarchy(false);
			return (this.parents().contains(URI));
		});
		jOWL.data(this.name, "children", oChildren);
		return oChildren;
	},
	setParents : function(parents){
		jOWL.data(this.name, "parents", parents); return parents;
	},
	/** @return A jOWL.Ontology.Array of parents, includes redundancies, to exclude do a hierarchy search first.*/
	parents : function(){
		var self = this;
		var oParents = jOWL.data(this.name, "parents");
		if(oParents){ return oParents;}

		var temp = [];

		var cls = jOWL.Xpath.classes(this.jnode);
			for(var i=0;i<cls.length;i++){ jOWL.priv.Array.pushUnique(temp, cls[i]);}

		var restr = jOWL.Xpath.restrictions(this.jnode);
			restr.each(function(){
				if(this.property.domain && this.property.domain != self.name){ jOWL.priv.Array.pushUnique(temp, this.property.domain);
			}
		});

		var iSectLoop = function(){
			if(this.match(self.URI, cls, restr)){
				jOWL.priv.Array.pushUnique(temp, this.URI);
			}
		
		};

		if(jOWL.options.reason){
			for(resource in jOWL.index('intersection')){
				jOWL.index('intersection')[resource].each(iSectLoop);
			}
		}

		oParents = new jOWL.Ontology.Array( jOWL.getXML(temp), true);
		if(!oParents.length){ oParents.push(jOWL('Thing'));}
		else if(oParents.length > 1){ oParents.filter(function(){return this.name != ('Thing');});} //Remove Thing reference if other parents exist
		jOWL.data(this.name, "parents", oParents);
		return oParents;
	},
/** @return ancestors to the class in a jOWL.Ontology.Array */
	ancestors : function(){
		return this.hierarchy(false).flatindex;
	},
/**
Constructs the entire (parent) hierarchy for a class
@return a jOWL.Ontology.Array containing top nodes (classes directly subsumed by 'owl:Thing')
@param addInverse add a variable invParents (jOWL.Ontology.Array of child references) to each node with exception of the leaves (original concept)
*/
	hierarchy : function(addInverse){
		var endNodes = new jOWL.Ontology.Array();
		var self = this;
		endNodes.flatindex  = new jOWL.Ontology.Array();

		function URIARR(p_arr, obj){
			var add = true;
			if(!obj){ obj = {}; add = false;}
			if(p_arr.each){
				p_arr.each(function(){
					if(obj[this.URI]){return;}
					if(this.URI == __.owl()+'Thing'){ return;}
					if(add){ obj[this.URI] = true;}
					if(this.parents){ URIARR(this.parents(), obj);}
				});
			}
			return obj;
		}

		function traverse(concept){
			var parents = concept.parents();
			if(parents.length == 1 && parents.contains(__.owl()+'Thing')){ endNodes.pushUnique(concept); return;}
			else
			{
				var asso = jOWL.options.reason ? URIARR(parents) : {};
				parents.filter(function(){ return (!asso[this.URI]);}); //throw out redundancies
				parents.each(function(){
						var item = endNodes.flatindex.pushUnique(this);
						if(addInverse){
							if(!item.invParents){ item.invParents = new jOWL.Ontology.Array();}
							item.invParents.pushUnique(concept);
							}
						traverse(item);
					});
				concept.setParents(parents);
			}
		}

		traverse(this);
		return endNodes;

	},
	/**
	@param level depth to fetch children, Default 5 
	@return jOWL array of classes that are descendant
	*/
	descendants : function(level){
		level = (typeof level == 'number') ? level : 5;
		var oDescendants = jOWL.data(this.name, "descendants");
		if(oDescendants && oDescendants.level >= level){ return oDescendants;}
		oDescendants = new jOWL.Ontology.Array();
		oDescendants.level = level;

		function descend(concept, i){
			if(i <= level){
				i++;
				var ch = concept.children();
				oDescendants.concat(ch);
				ch.each(function(item){ descend(item, i);});
			}
		}

		descend(this, 1);
		jOWL.data(this.name, "descendants", oDescendants);
		return oDescendants;
	},
	/** @return jOWL.Array of Restrictions, target is an individual, not a class or undefined (unless includeAll is specified) - deprecated */
	valueRestrictions : function(includeAll, array){
		return this.sourceof(null, null, {ignoreClasses : !includeAll});
	},
	/**
	get all restrictions that satisfy the arguments
	@param property property or array of properties, or null
	@param target class, individuals of array of them, or null
	@return jOWL.Array of Restrictions
	*/
	sourceof : function(property, target, options){
		options = $.extend({
			inherited : true, // add restrictions specified on parents as well
			transitive : true, //expand on transitive relations too
			ignoreGenerics : true, //if a parent has an identical property, with another target 'Thing', skip that restriction
			ignoreClasses : false, //only individuals should return
			valuesOnly : true //do not return valueless criteria
		}, options);
		var self = this;
		var crit = jOWL.data(this.name, "sourceof");
		var jnode = this.jnode;

		if(!crit){
			crit = new jOWL.Ontology.Array();
			var arr = jOWL.Xpath(__.rdfs("subClassOf")+"/"+__.owl("Restriction"), jnode)
				.add(jOWL.Xpath(__.owl("intersectionOf")+"/"+__.owl("Restriction"), jnode));
			arr.each(function(index, entry){
			var cr = new jOWL.Ontology.Restriction($(entry));
				var dupe = false;
				crit.each(function(item, i){
						if(this.property.name == cr.property.name){ dupe = item;}
				});
				if(dupe){ if(!dupe.merge(cr)){ crit.push(cr);} }
				else { crit.push(cr);}
			});
			jOWL.data(self.name, "sourceof", crit);
		}
		var results = new jOWL.Ontology.Array();

		crit.each(function(){

			var propertyMatch = property ? false : true;
			var targetMatch = target ? false : true;

			if(!propertyMatch){
				if(property.isArray){	propertyMatch = property.contains(this.property);}
				else { propertyMatch = (property.URI == this.property.URI);}
			}

			if(!target){
				if(options.transitive && this.property.isTransitive){ 
					var rTarget = this.getTarget();
					var transitives = rTarget.sourceof(this.property, null, options);
					results.concat(transitives);
				}
			}

			if(!targetMatch && !this.target){
				targetMatch = !options.valuesOnly;
			} 

			if(!targetMatch){
				var targ = this.getTarget();
				if(targ.isClass && options.ignoreClasses){ return;}
				targetMatch = jOWL.priv.testObjectTarget(target, this.target);
				if(!targetMatch && options.transitive && propertyMatch && this.property.isTransitive){
					if(targ.isThing){
						if(targ.sourceof(property, target).length){ targetMatch = true;}
					}
				}
			}

			if(propertyMatch && targetMatch){ results.pushUnique(this);}
		});

		if(!options.inherited){ return results;}

		this.parents().each(function(){ 
			if(this.sourceof){
				this.sourceof(property, target, options).each(function(parentsource){
					var ptarget = this.getTarget();
					var containsProperty = false; 
					var tempArray = new jOWL.Ontology.Array();
					results.filter(function(){
						var restr = this, keep = true;
						if(restr.property.URI == parentsource.property.URI){
							containsProperty = true;
							if(!options.ignoreGenerics){
								if(parentsource.target != restr.target){ tempArray.push(parentsource);}
							} else {
								if(ptarget.isThing){
									keep = restr.getTarget().isThing && parentsource.target != restr.target;
									tempArray.push(parentsource);
								}
							}
						}
						return keep;
					});
					if(!containsProperty){ results.push(parentsource);}
					results.concat(tempArray);
				});
			}
		});
		return results;
	}
});

/** Utility object */
jOWL.Ontology.Array = function(arr, isXML){
	var self = this;
	this.items = [];
	if(arr){
		if(isXML){ $.each(arr, function(){
			var entry = this.jOWL ? this : jOWL($(this));
			self.items.push(entry);}); 
			}
		else { this.items = arr;}
	}
	this.length = this.items.length;
};

jOWL.Ontology.Array.prototype = {
	jOWL : jOWL.version,
	isArray : true,
	bind : function(listitem, fn){
		return this.map(function(){
			var syntax = listitem ? listitem.clone(true) : $('<span/>');
			var html  = this.bind(syntax).append(document.createTextNode(' '));
			if(fn){ fn.call(html, html, this);}
			return html.get(0);
		});
	},
	concat : function(arr, ignoreUnique){
		var self = this;
		if(arr.each){ arr.each(function(){
			if(ignoreUnique){ self.push(this); }
			else { self.pushUnique(this); }
			});
			}
		else { self.items = self.items.concat(arr.items); this.length = self.items.length;}
		return this;
	},
	contains : function(o){
		return this.get(o) ? true: false;
	},
	each : function(fn, reverse){
		var i, self = this;
		var stop = false;
		if(reverse){
			for(i=this.items.length - 1; i>=0;i--){ 
				if(stop){ break;}
				(function(){
					var item = self.eq(i); 
					if(fn.call(item, item, i) === false){ stop = true;}
				})();
			}
		}
		else {
			for(i=0;i<this.items.length;i++){
				if(stop){ break;}
				(function(){
					var item = self.eq(i); 
					if(fn.call(item, item, i) === false){ stop = true;}
				})();} 
		}
		return this;
	},
	eq : function(index){
		if(index < 0 || index > this.items.length -1){ return null;}
		return this.items[index];
	},
	filter : function(fn){
		var self = this;
		this.each(function(item, i){
			var q = fn.call(item, item, i);
			if(!q){ self.items.splice(i, 1);}
			}, true);
		this.length = this.items.length;
		return this;
	},
	getIndex : function(o){
		var found  = -1;
		if(o.equals){
			this.each(function(a, i){
				if(this.equals && this.equals(o)){ found = i; return false;}
			});
		}
		else {
			if(typeof o == 'number'){ return o;}
			var name = typeof o == "string" ? o : o.name;
			var URI = o.URI || name;

			this.each(function(a, i){
				if(this.URI){ if(this.URI == URI){ found = i;}}
				else if(this.name == name){ found = i;}
			});
		}
		return found;
	},
	get : function(o){
		return this.eq(this.getIndex(o));
	},
	map : function(fn){
		var arr = [];
		this.each(function(){ arr.push(fn.call(this, this));});
		return arr;
	},
	push : function(o){
		this.items.push(o);
		this.length = this.items.length;
		return this;
	},
	pushUnique : function(o){
		return this.get(o) || this.push(o).get(o);
	},
	toString : function(){
		return this.map(function(){return this.URI;}).join(', ');
	},
	/** Convert this array into an associative array with key = URI */
	associative : function(){
		var arr = {};
		this.each(function(){
			if(this.URI){ arr[this.URI] = this;}
		});
		return arr;
	}
};


jOWL.options = {reason: true, locale:false, defaultlocale: 'en',
	dictionary : { create: true, addID : true },
	onParseError : function(msg){alert("jOWL parseError: "+msg);}, cacheProperties : true, niceClassLabels : true};
jOWL.document = null;
jOWL.namespace = null;
jOWL.indices = { //internal indices
	P : null, //jOWL array
	data : {},
	IDs : null,
	I : null, //Intersection
	T : null, //Thing
	D : null, //dictionary
	reset : function(){var i = jOWL.indices; i.data = {}; i.P = null; i.T = null; i.IDs = null; i.I = null;i.D = null;}
};

jOWL.index = function(type, wipe){
		var i = jOWL.indices;
		switch (type)
		{
		/**jOWL indexes all elements with rdf:ID, and first order ontology elements specified with rdf:about 
		@return Associative array with key = URI and value = jOWL object.
		*/
		case "ID":
			if(i.IDs === null || wipe){
				if(wipe){ i.reset();}
				i.IDs = {};
				i.T = {};
				var start = new Date();

				var rID = jOWL.Xpath("//*[@"+__.rdf("ID")+"]").each(function(){
					var jowl = jOWL.getResource($(this)); 
					if(jowl){
						i.IDs[jowl.URI] = jowl;
						if(jowl.isThing){
							if(!i.T[jowl.Class]){ i.T[jowl.Class] = new jOWL.Ontology.Array();}
							i.T[jowl.Class].push(jowl);
						}
					}
				});

				var rAbout = jOWL.Xpath("/"+__.rdf("RDF")+"/*[@"+__.rdf("about")+"]").each(function(){
					var jnode = $(this);
					var jowl = jOWL.getResource($(this));
					if(!jowl){ return;}
						if(jowl.isClass || jowl.isProperty || jowl.isThing){
							if(i.IDs[jowl.URI]){ jnode.children().appendTo(i.IDs[jowl.URI].jnode); return;}
							i.IDs[jowl.URI] = jowl; 
							if(jowl.isThing){
								if(!i.T[jowl.Class]){ i.T[jowl.Class] = new jOWL.Ontology.Array();}
								i.T[jowl.Class].push(jowl);
							}
							return; 
						}
				});
				console.log("Loaded in "+(new Date().getTime() - start.getTime())+"ms");
				}
			return i.IDs;
		/** Generated together with ID index.
		* @return Associative Array, key = class, value = jOWL Array of individuals.
		*/
		case "Thing":
			return i.T;
		case "intersection":
			if(i.I === null || wipe){
				var temp =  new jOWL.Ontology.Array();
				i.I  = {};
				jOWL.Xpath("//"+__.owl("intersectionOf")).each(function(){
					var isect = new jOWL.Ontology.Intersection($(this));
					if(!isect.URI){return;}
					var dupe = temp.get(isect);
					if(dupe){
						console.log("duplicate intersection found between : (Ignoring) "+isect.URI+"  and "+dupe.URI);
					} else {
						if(!i.I[isect.URI]){i.I[isect.URI] = new jOWL.Ontology.Array();}
						temp.push(isect);
						i.I[isect.URI].push(isect);
					}
				});
				}
			return i.I;
		case "property":
			if(i.P === null || wipe)
			{
			jOWL.options.cacheProperties = false;
			i.P = new jOWL.Ontology.Array();
			for(x in i.IDs){
				var jowl = i.IDs[x];
				if(jowl.isProperty){ i.P.push(jowl);}
			}
			jOWL.options.cacheProperties = true;
			}
			return i.P;
		case "dictionary":
			/**Dictionary: Array of Arrays, where secondary array is of form: [0] = term, [1] = rdfID, [2] = locale */
			if(i.D === null || wipe)
			{
				i.D = [];
				for(x in i.IDs){
					var entry = i.IDs[x];
					i.D = i.D.concat(entry.terms());
				}
			}
			return i.D;
		}
};

/** Internal Function, storing data in associative array (JSON),
jquery data function cannot be used as expando data does not work in IE for ActiveX XMLhttprequest*/
jOWL.data = function(rdfID, dtype, data){
	var d = jOWL.indices.data;
	if(!d[rdfID]){ d[rdfID] = {};}
	if(!data){ return d[rdfID][dtype];}
	d[rdfID][dtype] = data;
};

/**
* Initialize jOWL with an OWL-RDFS document.
* @param path relative path to xml document
* @param callback callback function to be called when loaded.
* @options : optional settings:
*	onParseError : function(msg){} function to ba called when parsing fails
*	reason : true/false, turns on additional reasoning at the expense of performance
*	locale: set preferred language (if available), examples en, fr...
*/
jOWL.load = function(path, callback, options){
	var that = this;
	if($.browser.msie && location.toString().indexOf('file') === 0){ //IE won't load local xml files otherwise
		var xml = document.createElement("xml");
		xml.validateOnParse = false; //IE throws DTD errors (for 'rdf:') on perfectly defined OWL files otherwise
		xml.src = path;
		xml.onreadystatechange = function(){
			if(xml.readyState == "interactive"){ var xmldoc = xml.XMLDocument; document.body.removeChild(xml);callback(that.parse(xmldoc, options));}
			};
		document.body.appendChild(xml);
		}
	else {
		$.get(path, function(xml){callback(that.parse(xml, options));});
	}
};

/**
* initialize jOWL with some OWL-RDFS syntax
* @param doc Either an xmlString or an xmlDocument
* @param options optional, onParseError(msg) : function to execute when parse fails
* @returns false on failure, or the jOWL object
*/
jOWL.parse = function(doc, options){
	jOWL.document = null;
	this.options = $.extend(jOWL.options, options);
	if(typeof doc == 'string'){ doc = jOWL.fromString(doc);}
	jOWL.document = doc;
	if($.browser.msie){
		if(doc.parseError.errorCode !== 0){ jOWL.options.onParseError(doc.parseError.reason); return false;}
		}
	else if(doc.documentElement.nodeName == 'parsererror'){jOWL.options.onParseError(doc.documentElement.firstChild.nodeValue); return false;}
	var root = $(doc.documentElement);
	jOWL.NS(root);
	if($.browser.msie){
		jOWL.document.setProperty("SelectionLanguage", "XPath");
		jOWL.document.setProperty("SelectionNamespaces", __());
	}
	this.index('ID', true);
	if(jOWL.options.cacheProperties){ this.index('property', true);}
	if(jOWL.options.dictionary.create){ jOWL.index("dictionary");}
	jOWL.Thing = new jOWL.Ontology.Thing($(jOWL.create(__.owl, "Class").attr(__.rdf, 'about', __.owl()+'Thing').node)); 
	jOWL.Thing.type = false;	
	return this;
};

/**
* A String representation of the OWL-RDFS document
* @param xmlNode optional, node to generate a string from, when unspecified the entire document
*/
jOWL.toString = function(xmlNode){
	if(!xmlNode){ return jOWL.toString(jOWL.document);}
	if($.browser.msie){ return xmlNode.xml;}
	return new XMLSerializer().serializeToString(xmlNode);// Gecko-based browsers, Safari, Opera.
};

/** create a document from string */
jOWL.fromString = function(doc){
	var owldoc;
	if(document.implementation.createDocument){ owldoc = new DOMParser().parseFromString(doc, "text/xml");} // Mozilla and Netscape browsers
	else if(window.ActiveXObject){ // MSIE
		var xmldoc = new ActiveXObject("Microsoft.XMLDOM");
		xmldoc.async="false";
		xmldoc.validateOnParse = false;
		xmldoc.loadXML(doc);
		owldoc = xmldoc;
		}
	return owldoc;
};

/** @return false if belongs to this namespace, or an array with length two, arr[0] == url, arr[1] == id */
jOWL.isExternal = function(resource){
	var r = jOWL.resolveURI(resource, true);
	return r[0] != jOWL.namespace ? r : false;
};

/** 
if a URI belongs to the loaded namespace, then strips the prefix url of, else preserves URI 
also able to parse and reference html (or jquery) elements for their URI.
*/
jOWL.resolveURI = function(URI, array){
	if(typeof URI != "string"){
		var node = URI.jquery ? URI.get(0) : URI;
		URI = node.localName || node.baseName;
		if(node.namespaceURI){ URI = node.namespaceURI + URI;}
		return jOWL.resolveURI(URI, array);
	}
	var rs = URI, ns = jOWL.namespace;
	if(URI.indexOf('http') === 0){
		var tr = URI.indexOf('#');
		if(tr <= 0){ tr = URI.lastIndexOf('/');}
		if(tr > 0)
		{
			ns = URI.substring(0, tr+1);
			rs = URI.substring(tr+1);
		}
	} else if(URI.charAt(0) == '#'){ return URI.substring(1);}
	if(array){ return [ns, rs];}
	if(ns == jOWL.namespace){ return rs;}
	return URI;
};

/**
Main method to get an Ontology Object, access via jOWL(>String>, options);
resource: rdfID/rdfResource<String> or jQuery node.
*/
jOWL.getResource = function(resource, options){
	if(!jOWL.document){ throw "You must successfully load an ontology before you can find anything";}
	if(!resource){ throw "No resource specified";}
	var node;
	var opts = $.extend({}, options);
	if(typeof resource == 'string'){
		resource = jOWL.resolveURI(resource);
		if(resource == 'Thing' || resource == __.owl()+'Thing'){ return jOWL.Thing;}
		if(opts.type == 'property' && jOWL.options.cacheProperties){
			var c = jOWL.index('property').get(resource);
			if(c){ return c;}
			if(jOWL.isExternal(resource)){ console.log("undeclared resource: "+resource); return new jOWL.Ontology.Property(resource);}
			}
		var match = jOWL.index("ID")[resource];
		if(!match){ //try case insensitive
			for(caseIns in jOWL.index("ID")){
				if(caseIns.toLowerCase() == resource.replace(/ /g, "").toLowerCase()){ match = jOWL.index("ID")[caseIns]; break;}
			}
		}
		if(!match){
			if(jOWL.isExternal(resource)){
				console.log("undeclared resource: "+resource);
				return new jOWL.Ontology.Thing(resource);
			}
			console.log(resource+" not found"); 
			return null; 
		}
		return match;
	}
	node = resource.jquery ? resource : $(resource);
	var jj = jOWL.type(node); if(!jj){ return null;}
	return new (jj)(node);
};

/** 
* @param node jquery or html element.
* @return the ontology type of the object.
*/
jOWL.type = function(node){
	var xmlNode = node.jquery ? node.get(0) : node;
	switch(xmlNode.nodeName){
		case __.owl("Class") : return jOWL.Ontology.Class;
		case __.rdfs("Class") : return jOWL.Ontology.Class; //test
		case __.owl("Ontology") : return jOWL.Ontology;
		case __.owl("ObjectProperty") : return jOWL.Ontology.ObjectProperty;
		case __.owl("DatatypeProperty") : return jOWL.Ontology.DatatypeProperty;
		case __.owl("FunctionalProperty") : return jOWL.Ontology.Property;
		case __.rdf("Property") : return jOWL.Ontology.Property;
		case __.owl("InverseFunctionalProperty") : return jOWL.Ontology.ObjectProperty;
		case __.owl("TransitiveProperty") : return jOWL.Ontology.ObjectProperty;
		case __.owl("SymmetricProperty") : return jOWL.Ontology.ObjectProperty;
		//jOWL currently treats annotationproperties as string datatypeproperties.
		case __.owl("AnnotationProperty") : return jOWL.Ontology.DatatypeProperty;
		default :
			switch(xmlNode.namespaceURI){
				case __.owl(): if(xmlNode.nodeName == __.owl("Thing") ){ return jOWL.Ontology.Individual;} return false;
				case __.rdf(): return false;
				case __.rdfs(): return false;
				default : return jOWL.Ontology.Individual;
			}
	}
};

/**
@param rdfID <String> or Array<String>
@return Array of DOM (xml) Nodes
*/
jOWL.getXML = function(rdfID){
	var node = [];
	function fetchFromIndex(rdfID){ 
		var el = jOWL.index("ID")[rdfID];
		return el ? el : null;
	}

	if(typeof rdfID == 'string'){ var q = fetchFromIndex(rdfID); if(q){ node.push(q);} }
	else if(jOWL.priv.Array.isArray(rdfID)){ //assume an array of string rdfIDs
		$.each(rdfID, function(){  
			var el = fetchFromIndex(this); if(el){ node.push(el);}
			});
	}
	return node;
};

/** Create new ontology elements */
jOWL.create = function(namespace, name, document){
	var doc = document ? document : jOWL.document;

	var el = {
		attr : function(namespace, name, value){
			if($.browser.msie){
				var attribute = doc.createNode(2, namespace(name), namespace());
				attribute.nodeValue = value;
				this.node.setAttributeNode(attribute);
			}
			else { this.node.setAttributeNS(namespace(), namespace(name), value);}
			return this;
		},
		appendTo : function(node){
			var n = node.node ? node.node : node;
			n.appendChild(this.node);
			return this;
		},
		text : function(text, cdata){
			var txt = cdata ? doc.createCDATASection(text) : doc.createTextNode(text);
			this.node.appendChild(txt);
			return this;
		}
	};

	if($.browser.msie){ el.node = doc.createNode(1, namespace(name), namespace());}
	else { el.node = doc.createElementNS(namespace(), namespace(name));}
	return el;
};

/** Create a blank ontology document */
jOWL.create.document = function(href){
	var owl = [];
	var base = href || window.location.href+"#";
	owl.push('<?xml version="1.0"?>');
	owl.push('<'+__.rdf('RDF')+' xml:base="'+base+'" xmlns="'+base+'" '+__()+'>');
	owl.push('   <'+__.owl('Ontology')+' '+__.rdf('about')+'=""/>');
	owl.push('</'+__.rdf('RDF')+'>');
	return jOWL.fromString(owl.join('\n'));
};

/** Extracts RDFa syntax from current page and feeds it to jOWL, simple implementation, only classes for the time being */
jOWL.parseRDFa = function(fn, options){
	var entries = options.node ? $("[typeof]", options.node) : $("[typeof]");
	var doc = jOWL.create.document();

	 function property(p, node){
		var arr = [];
		$("[property="+p+"]", node).each(function(){ arr.push($(this).attr('content') || $(this).html());});
		if(node.attr('property') === p){ arr.push(node.attr('content') || node.html());}
		return arr;
	}

	function rel(p, node){
		var arr = [];
		$("[rel="+p+"]", node).each(function(){ arr.push($(this).attr('resource'));});
		if(node.attr("rel") === p){ arr.push(node.attr('resource'));}
		return arr;
	}

	function makeClass(node, ID){
		var cl = jOWL.create(__.owl, "Class", doc).attr(__.rdf, 'about', ID).appendTo(doc.documentElement);

		var parents = property(__.rdfs("subClassOf"), node).concat(rel(__.rdfs("subClassOf"), node));
		for(var i = 0;i<parents.length;i++){
			var p = jOWL.create(__.rdfs, "subClassOf", doc).attr(__.rdf, "resource", parents[i]).appendTo(cl);
		}
		return cl;
	}

	entries.each(function(){
		var node = $(this);
		var type = node.attr("typeof"), el;

		if(type == __.owl("Class")){ el = makeClass(node, jOWL.resolveURI(node.attr("about")));}

		$.each(property(__.rdfs('comment'), node), function(){
			jOWL.create(__.rdfs, "comment", doc).appendTo(el).text(this, true);
		});

		$.each(property(__.rdfs('label'), node), function(){
			jOWL.create(__.rdfs, "label", doc).appendTo(el).text(this);
		});
	});
	jOWL.parse(doc, options);
	fn();
};

/**
Match part or whole of the rdfResource<String>
Used for term searches, intend to (partially) replace it by a sparql-dl query later on
options:
    filter: filter on a specific type, possible values: Class, Thing, ObjectProperty, DatatypeProperty
    exclude: exclude specific types, not fully implemented
*/
jOWL.query = function(match, options){
	options = $.extend({exclude : false}, options);
	if(options.filter == 'Class'){ options.filter = __.owl("Class");}
	var that = this;
	//filter : [], exclude : false
	var items = new jOWL.Ontology.Array();
	var jsonobj = {};
	var test = jOWL.index("dictionary");

	function store(item){
			var include = false, i = 0;
			if(options.filter){
				if(typeof options.filter == 'string'){ include = (options.filter == item[3]);}
				else { for(i = 0;i<options.filter.length;i++){ if(options.filter[i] == item[3]){ include = true;} } }
				}
			else if(options.exclude){
				include = true;
				if(typeof options.exclude == 'string'){ include = (options.exclude !== item[3]);}
				else { for(i = 0;i<options.exclude.length;i++){ if(options.exclude[i] == item[3]){ include = false;} } }
			}
			else { include = true;}
			if(!include){ return;}
			if(!jsonobj[item[1]]){ jsonobj[item[1]] = [];}
			jsonobj[item[1]].push( { term : item[0], locale: item[2], type: item[3] });
	}

	for(var y = 0;y<test.length;y++){
		var item = test[y];
		var bool = options.exclude;
		var r = item[0].searchMatch(match);
		if(r > -1){
			if(options.locale){ if(options.locale == item[2]){ store(item);} }
			else { store(item);}
		}
	}
	return jsonobj;
};

/**
allows asynchronous looping over arrays (prevent bowser freezing).
arr the array to loop asynchonrously over.
options.modify(item) things to do with each item of the array
options.onUpdate array the size of chewsize or smaller, containing processed entries
options.onComplete(array of results) function triggered when looping has completed
*/
jOWL.throttle =function(array, options){
	options = $.extend({
		modify : function(result){},
		//onUpdate : function(arr){},
		onComplete : function(arr){},
		async : true,
		chewsize : 5,
		startIndex : 0,
		timing : 5
		}, options);
	var temp = array.jOWL ? array.items : (array.jquery) ? $.makeArray(array) : array;
	var items = options.startIndex ? temp.slice(startIndex) : temp.concat(); //clone the array
	var results = [];

	(function(){
		var count = options.chewsize;
		var a = [];
		while (count > 0 && items.length > 0)
		{
			var item = items.shift(); count--;
			var result = options.modify.call(item, item);
			if(result){ results.push(result); a.push(result);}
		}
		if(options.onUpdate){ options.onUpdate(a);}

		if(items.length> 0){
			if(options.async){ setTimeout(arguments.callee, options.timing);}
			else {arguments.callee();}
		}
		else{ options.onComplete(results);}
	})();
};

/** Creates a new resultobj for the SPARQL-DL functionality */
jOWL.SPARQL_DL_Result = function(){
	this.assert = undefined;
	this.head = {}; //associative array of query parameters, with value jOWL Array of results
	this.results = []; //sparql-dl bindings
	this.isBound = false;
};

jOWL.SPARQL_DL_Result.prototype = {
	sort : function(param){
		if(!param){ throw "parameter must be defined for sort function";}
		function sortResults(a, b){
			var o = a[param].name || a[param];
			var p = b[param].name || b[param];
			return (o < p) ? -1 : 1;
		}
		if(this.results){ this.results.sort(sortResults); }
	},
	jOWLArray : function(param){
		if(!param){ throw "parameter must be defined for jOWLArray function";}
		var arr = new jOWL.Ontology.Array();
		for(var i=0;i<this.results.length;i++){
		if(this.results[i][param]){ arr.pushUnique(this.results[i][param]);}
		}
		return arr;
	},
	/** Filter head Parameters */
	filter : function(param, arr){
		if(this.head[param] === undefined){this.head[param] = arr;}
		else {
			var self = this; 
			this.head[param].filter(function(){ return (arr.contains(this));});
			arr.filter(function(){ return (self.head[param].contains(this));});
		}
	},
	/** Update result section, results = SPARQL_DL_Array */
	bind : function(results){
		if(!this.isBound){//new results
			this.results = this.results.concat(results.arr);
			this.isBound = true;
			return;
		}
		var multimapping = -1;
		for(x in results.mappings){ multimapping++; }
		var toAdd = [];

		for(x in results.mappings){
			var otherKeys;
			if(multimapping){
				otherKeys = results.keyCentric(x);
			}
			for(var i = this.results.length-1;i>=0;i--){
				var valueX = this.results[i][x];
				if(valueX){
					if(!results.mappings[x].contains(valueX)){
						this.results.splice(i, 1);
						continue;
					}
					if(multimapping){
						var keyArr= otherKeys[valueX.URI];
						//ignoring the opposite for now (assuming original key x is unique (limits statements))
						//TODO: improve these result merging methods/flexibility
						for(var oK = 0; oK < keyArr.length;oK++){
							var obj = (oK === 0) ? this.results[i] : {};
							var valueY = keyArr[oK];
							obj[x] = valueX;
							for(yK in valueY){ obj[yK] = valueY[yK]; }
							toAdd.push(obj);
						}
						this.results.splice(i, 1);
					}
				}
			}
		}
		this.results = this.results.concat(toAdd);
	}
};
/** Creates a new query for the SPARQL-DL functionality */
jOWL.SPARQL_DL_Query = function(syntax, parameters){
		this.parse(syntax);
		this.fill(parameters);
		this.entries = this.entries.sort(this.sort);
};

jOWL.SPARQL_DL_Query.prototype = {
	parse : function(syntax){
		 var r2 = /(\w+)[(]([^)]+)[)]/;
		 var entries = syntax.match(/(\w+[(][^)]+[)])/g);
		 if(!entries){ this.error =  "invalid abstract sparql-dl syntax"; return;}
		 entries = jOWL.priv.Array.unique(entries);
		 for(var i = 0;i<entries.length;i++){
			var y = entries[i].match(r2);
			if(y.length != 3){ this.error = "invalid abstract sparql-dl syntax"; return;}
			entries[i] = [y[1], y[2].replace(/ /g, "").split(',')];
		 }
		 this.entries = entries;
	},
	fill : function(parameters){
		for(var i = 0;i<this.entries.length;i++){
			for(var j =0; j<this.entries[i][1].length; j++){
				var p = parameters[this.entries[i][1][j]];
				if(p !== undefined)  { this.entries[i][1][j] = p;}
				else {
					p = this.entries[i][1][j];
					if(p.charAt(0) != '?')
					{
						if(this.entries[i][0] == "PropertyValue" && j == 2)
						{
						var m = p.match(/^["'](.+)["']$/);
						if(m && m.length == 2){ this.entries[i][1][j] = {test: m[1]}; break;}
						}
					this.entries[i][1][j] = jOWL(p);
					if(this.entries[i][1][j] === null){this.entries.error = "a parameter in the query was not found"; return;}
					}
				}
			}
		}
	},
	sort : function(a, b){
		var i;
		if(a[1].length == 1){ return (b[0] == 'PropertyValue') ? 1 : -1;}
		if(b[1].length == 1){ return (a[0] == 'PropertyValue') ? -1 : 1;}
		var avar = 0; for(i = 0;i<a[1].length;i++){ if(typeof a[1][i] == 'string'){ avar++;} }
		var bvar = 0; for(i = 0;i<a[1].length;i++){ if(typeof b[1][i] == 'string'){ bvar++;} }
		if(avar != bvar){ return avar - bvar;}
		if(a[0] == 'Type' && b[0] != 'Type'){ return -1;}
		if(a[0] != 'Type' && b[0] == 'Type'){ return 1;}
		return 0;
	}
};

/** Private function */
function _Binding(bindingarray){
	this.value = {};
	this.arr = bindingarray;
}

_Binding.prototype = {
	bind : function(key, value){
		this.value[key] = value;
		if(!this.arr.mappings[key]){ this.arr.mappings[key] = new jOWL.Ontology.Array();}
		this.arr.mappings[key].push(value);
		return this;
	}
};

/** Local Function, private access, Temp results */
function SPARQL_DL_Array(keys){	
	this.arr = [];
	this.mappings = {};

	if(keys){
		for(var i =0;i<keys.length;i++){
			if(keys[i]){this.mappings[keys[i]] = new jOWL.Ontology.Array();}
		}
	}
}

SPARQL_DL_Array.prototype = {
	add : function(binding){
		this.arr.push(binding.value);
		return binding;
	},
	push : function(key, value){
		var binding = new _Binding(this);
		binding.bind(key, value);
		this.arr.push(binding.value);
		return binding;
	},
	keyCentric : function(keyX){
		var arr = {};
		for(var i = this.arr.length-1;i>=0;i--){
			if(this.arr[i][keyX]){
				if(!arr[this.arr[i][keyX].URI]){ arr[this.arr[i][keyX].URI] = []; }
				arr[this.arr[i][keyX].URI].push(this.arr[i]);
			}
		}
		return arr;
	},
	get : function(key)
	{
		return (this.mappings[key]) ? this.mappings[key] : new jOWL.Ontology.Array();
	},
	getArray : function(){
		//check mappings for presence, discard arr entries based on that, return remainder.
		for(var i = this.arr.length - 1;i>=0;i--){
			var binding = this.arr[i], splice = false;
			for(key in binding){
				if(!splice){
					splice = (!this.mappings[key] || !this.mappings[key].contains(binding[key]));
				}
			}
			if(splice){
				this.arr.splice(i, 1);
			}
		}
		return this;
	}
};

/**
Support for abstract SPARQl-DL syntax
options.onComplete: function triggered when all individuals have been looped over
options.childDepth: depth to fetch children, default 5, impacts performance
options.chewsize: arrays will be processed in smaller chunks (asynchronous), with size indicated by chewsize, default 10
options.async: default true, query asynchronously
parameters: prefill some sparql-dl parameters with jOWL objects
execute: start query, results are passed through options.onComplete
*/
jOWL.SPARQL_DL = function(syntax, parameters, options){
	if(!(this instanceof arguments.callee)){ return new jOWL.SPARQL_DL(syntax, parameters, options);}
	var self = this;
	this.parameters = $.extend({}, parameters);
	this.query = new jOWL.SPARQL_DL_Query(syntax, this.parameters).entries;
	this.result = new jOWL.SPARQL_DL_Result();
	this.options = $.extend({onComplete: function(results){}}, options);
};

jOWL.SPARQL_DL.prototype = {
	error: function(msg){ this.result.error = msg; return this.options.onComplete(this.result);},
	/**
	if(options.async == false) then this method returns the result of options.onComplete,
	no matter what, result is always passed in options.onComplete
	*/
	execute : function(options){
		var self = this;
		this.options = $.extend(this.options, options);
		if(this.query.error){ return this.error(this.query.error);}
		
		var resultobj = this.result;
		var i = 0;  
		var loopoptions = $.extend({}, this.options);
		loopoptions.onComplete = function(results){ i++; resultobj = results; loop(i);};
		
		if(!this.query.length){
			resultobj.error = "no query found or query did not parse properly";
			return self.options.onComplete(resultobj);
			}  
			
		function loop(i){
			if(i < self.query.length){
				self.process(self.query[i], resultobj, loopoptions );
				}
			else {
				for(var j =0;j<resultobj.results.length;j++){ //Convert Literals into strings
					var b = resultobj.results[j];
					for(x in b){
						if(b[x] instanceof jOWL.Literal){b[x] = b[x].name;}
					}
				}
				return self.options.onComplete(resultobj);
			}
		} 
		loop(i);
	},
	/** results are passed in the options.onComplete function */
	process: function(entry, resultobj, options){
		var self = this;
		options = $.extend({chewsize: 10, async : true, onComplete : function(results){}}, options);
		var q = entry[0];
		var sizes = {
			"Type": [__.owl('Thing'), __.owl('Class')],
			"DirectType": [__.owl('Thing'), __.owl('Class')],
			"PropertyValue" : [false, false, false],
			"Class": [false],
			"Thing": [false],
			"ObjectProperty": [false],
			"DatatypeProperty": [false],
			"SubClassOf" : [__.owl('Class'), __.owl('Class')],
			"DirectSubClassOf" : [__.owl('Class'), __.owl('Class')]
			};
		
		if(!sizes[q]){ return self.error("'"+q+"' queries are not implemented");}
		if(sizes[q].length != entry[1].length){ return self.error("invalid SPARQL-DL "+q+" specifications, "+sizes[q].length+" parameters required");}
		for(var i = 0;i<entry[1].length;i++){
			var v = sizes[q][i];
			if(v){
				var m = entry[1][i];
				if(typeof m != 'string' && m.type != v){ return self.error("Parameter "+i+" in SPARQL-DL Query for "+q+" must be of the type: "+v);}
			}
		}
		if(q == "DirectType"){ options.childDepth = 0; return self.fn.Type.call(self, entry[1], resultobj, options);}
		else if(q == "DirectSubClassOf"){ options.childDepth = 1; return self.fn.SubClassOf.call(self, entry[1], resultobj, options);}
		return self.fn[q].call(self, entry[1], resultobj, options);
	},
	fn : {
			"SubClassOf" : function(syntax, resultobj, options){
				var atom = new jOWL.SPARQL_DL.DoubleAtom(syntax, resultobj.head);
				var results = new SPARQL_DL_Array();

				if(atom.source.isURI() && atom.target.isURI()){//assert
					if(resultobj.assert !== false){
						var parents = atom.source.value.ancestors();
						resultobj.assert = parents.contains(atom.target.value);
					}
					return options.onComplete(resultobj);
				}
				else if(atom.source.isURI()){//get parents
					atom.source.value.ancestors().each(function(){
						results.push(atom.target.value, this);
						});
					resultobj.filter(atom.target.value, results.get(atom.target.value));
					resultobj.bind(results.getArray());
					return options.onComplete(resultobj);
				}
				else if(atom.target.isURI()){//get children
					atom.target.value.descendants(options.childDepth).each(function(){
						results.push(atom.source.value, this);
						});
					resultobj.filter(atom.source.value, results.get(atom.source.value));
					resultobj.bind(results.getArray());
					return options.onComplete(resultobj);
				}
				else{//both undefined
					return this.error('Unsupported SubClassOf query');
				}
			},
			"Type" : function(syntax, resultobj, options){
				var atom = new jOWL.SPARQL_DL.DoubleAtom(syntax, resultobj.head);
			
			function addIndividual(cl){
				if(indivs[this.URI]){ return;}
				var b = results.push(atom.source.value, this);
				if(addTarget){  b.bind(atom.target.value, cl);}
				indivs[this.URI] = true;
			}

			function traverse(node, match){
					var a = node.parents();
					var found = false;
					if(a.contains(match)){ found = true;}
					else { 
						a.each(function(){
							if(this == jOWL.Thing){ return;}
							if(!found && traverse(this, match)){ found = true;} });
						}
					return found;
				}
				
				if(atom.source.isURI() && atom.target.isURI()){//assert
					return jOWL.SPARQL_DL.priv.assert(resultobj, function(){
						var cl = atom.source.value.owlClass();
						if(cl.URI == atom.target.value.URI){ return true;}
						return traverse(cl, atom.target.value); 
					}, options.onComplete);
				}
				else if(atom.source.getURIs() && !atom.target.getURIs()){//get class
					var results = new SPARQL_DL_Array();
					var addSource = !atom.source.isURI();
					var addTarget = !atom.target.isURI();
					 atom.source.getURIs().each(function(){
						var b;
						if(addTarget){ b = results.push(atom.target.value, this.owlClass());}
						if(addSource){ 
							if(addTarget){ b.bind(atom.source.value, this);}
							else {results.push(atom.source.value, this);}
						}
					 });
					if(addSource){  resultobj.filter(atom.source.value, results.get(atom.source.value));}
					if(addTarget){  resultobj.filter(atom.target.value, results.get(atom.target.value));}
					resultobj.bind(results.getArray());
					return options.onComplete(resultobj);
				}
				else if(atom.target.getURIs()){//get Individuals, slow
					var addTarget = !atom.target.isURI();
					var classlist = atom.target.getURIs(),
						classes = {}, indivs = {};

						var results = new SPARQL_DL_Array();


						classlist.each(function(){ //expand list of classes, not very fast!
							if(classes[this.URI]){ return;}
							var oneOf = this.oneOf(), cl = this;
							if(oneOf.length){ oneOf.each(function(){ addIndividual.call(this, cl);});}
							else{ this.descendants(options.childDepth).each(function(){ //this is the slower call
								classes[this.URI] = true;
							}); }
							classes[this.URI] = true;
						});

						for(x in classes){
							var individuals = jOWL.index("Thing")[x];
							if(individuals){
								var cl = jOWL.index('ID')[x];
								if(options.onUpdate){ options.onUpdate(individuals);}
								individuals.each(function(){
									addIndividual.call(this, cl);
								});
							}
						}
						resultobj.filter(atom.source.value, results.get(atom.source.value));
						resultobj.bind(results.getArray());
						return options.onComplete(resultobj);
				}
				return this.error('Unsupported Type query');
			},
			"Thing" : function(syntax, resultobj, options){
				jOWL.SPARQL_DL.priv.IDQuery(syntax[0], "isThing", resultobj, options);
			},
			"Class" : function(syntax, resultobj, options){ console.log('cl');
				jOWL.SPARQL_DL.priv.IDQuery(syntax[0], "isClass", resultobj, options);
			},
			"ObjectProperty" : function(syntax, resultobj, options){
				jOWL.SPARQL_DL.priv.PropertyQuery(syntax[0], jOWL.index("property").items, "isObjectProperty", resultobj, options);
			},
			"DatatypeProperty" : function(syntax, resultobj, options){
				jOWL.SPARQL_DL.priv.PropertyQuery(syntax[0], jOWL.index("property").items, "isDatatypeProperty", resultobj, options);
			},
			"PropertyValue" : function(syntax, resultobj, options){
				var atom = new jOWL.SPARQL_DL.TripleAtom(syntax, resultobj.head);
				
				if(atom.source.isURI() && atom.property.isURI() && atom.target.isURI()){//assert
					if(resultobj.assert !== false){
						jOWL.SPARQL_DL.priv.PropertyValuegetSourceInfo(atom.source.value, atom.property.value, atom.target.value, resultobj, { assert : true });
					}
					return options.onComplete(resultobj);
				}

				if(!atom.source.getURIs()){
					jOWL.SPARQL_DL.priv.IDQuery(atom.source.value, ["isClass", "isThing"], resultobj, options);
					return;
				}
				var filterTarget = atom.target.isVar() ? atom.target.value : false;
				var filterProperty = atom.property.isVar() ? atom.property.value : false;
				var filterSource = atom.source.isVar() ? atom.source.value : false;
				jOWL.SPARQL_DL.priv.PropertyValuegetSourceInfo(atom.source.getURIs(), atom.property.getURIs(), atom.target.getURIs(), resultobj,
					{
						filterTarget : filterTarget, filterProperty : filterProperty, filterSource : filterSource
					});
				return options.onComplete(resultobj);
			}
		}
};

jOWL.SPARQL_DL.priv = {
	assert : function(resultobj, fn, onComplete){
		if(resultobj.assert !== false){
			resultobj.assert = fn();
		}
		onComplete(resultobj);	
	},
	//reusable function
	PropertyValuegetSourceInfo : function(jSource, property, target, resultobj, options){
		if(!(jSource.isArray)){
			return jOWL.SPARQL_DL.priv.PropertyValuegetSourceInfo(new jOWL.Ontology.Array([jSource]), property, target, resultobj, options);
		}
		
		options = $.extend({}, options);
		var results = new SPARQL_DL_Array([options.filterSource, options.filterProperty, options.filterTarget]), 
			match = false;
		jSource.each(function(){
			var source = this;
			if(target && target.isArray && target.length == 1){
				var literal = target.get(0).test;
				if(literal){ target = literal;}//unwrap literal expressions
			}
			var restrictions = source.sourceof(property, target);
			if(options.assert){
				if(restrictions.length > 0){ match = true;}
				return;
			}
			if(!restrictions.length){ return;}
			restrictions.each(function(){
				var binding = new _Binding(results);
				if(options.filterSource){
					binding.bind(options.filterSource, source);
					if(!options.filterProperty && !options.filterTarget){ results.add(binding); return false;}
				}
				if(options.filterProperty){
					binding.bind(options.filterProperty, this.property);
				}
				if(options.filterTarget){
					binding.bind(options.filterTarget, this.getTarget());
				}
				results.add(binding);
			});
			return true;
		});
		if(options.assert){
			resultobj.assert = match;
			return resultobj.assert;
		}
		if(options.filterSource){ resultobj.filter(options.filterSource, results.get(options.filterSource));}
		if(options.filterProperty){ resultobj.filter(options.filterProperty, results.get(options.filterProperty));}
		if(options.filterTarget)  { resultobj.filter(options.filterTarget, results.get(options.filterTarget));}
		resultobj.bind(results.getArray());
	},
	hasClassID: function(match, classID){
		if(Object.prototype.toString.call(classID) === '[object Array]'){
			for(var i =0;i<classID.length;i++){
				if(match[classID]){ return true;}
			}
		} else if(match[classID]){  return true;}
		return false;	
	},
	IDQuery : function(parameter, classID, resultobj, options){
		var atom = new jOWL.SPARQL_DL.Atom(parameter, resultobj.head);
		if(atom.isURI()){
			return jOWL.SPARQL_DL.priv.assert(resultobj, function(){
				return jOWL.SPARQL_DL.priv.hasClassID(atom.getURIs().get(0), classID);
			}, options.onComplete);
		}
		var results = new SPARQL_DL_Array();
		for(x in jOWL.index("ID")){
			var match = jOWL.index("ID")[x];
			if(jOWL.SPARQL_DL.priv.hasClassID(match, classID)){ results.push(parameter, match);}
		}
		resultobj.filter(parameter, results.get(parameter));
		resultobj.bind(results.getArray());
		options.onComplete(resultobj);
	},
	PropertyQuery : function(parameter, index, className, resultobj, options){
		var atom = new jOWL.SPARQL_DL.Atom(parameter, resultobj.head);
		if(atom.isURI()){
			return jOWL.SPARQL_DL.priv.assert(resultobj, function(){
				return jOWL.SPARQL_DL.priv.hasClassID(atom.getURIs().get(0), className);
			}, options.onComplete);
		}
		var results = new SPARQL_DL_Array();
		var tr = new jOWL.throttle(index, $.extend({}, options, {
			modify : function(result){
				if(!result.jOWL){ result = jOWL(result);}
				if(jOWL.SPARQL_DL.priv.hasClassID(result, className)){results.push(parameter, result);}
				return false;
			},
			onComplete : function(){
				resultobj.filter(parameter, results.get(parameter));
				resultobj.bind(results.getArray());
				options.onComplete(resultobj);
			}
		}));
	}
};

jOWL.SPARQL_DL.TripleAtom = function(syntax, store){
	this.source = new jOWL.SPARQL_DL.Atom(syntax[0], store);
	this.property = new jOWL.SPARQL_DL.Atom(syntax[1], store);
	this.target = new jOWL.SPARQL_DL.Atom(syntax[2], store);
};

jOWL.SPARQL_DL.DoubleAtom = function(syntax, store){
	this.source = new jOWL.SPARQL_DL.Atom(syntax[0], store);
	this.target = new jOWL.SPARQL_DL.Atom(syntax[1], store);
};


jOWL.SPARQL_DL.Atom = function(syntax, store){
	this.value = syntax;
	this.type = 0;
	if(typeof syntax == 'string'){
		if(syntax.indexOf('?') === 0){
			this.type = this.VAR;
			if(store && store[syntax]){ this.mappings = store[syntax];}
		} else {
			this.type = this.LITERAL;
		}
	} else {
		this.type = this.URI;
	}
};

jOWL.SPARQL_DL.Atom.prototype = {
	URI : 1, LITERAL : 2, VAR : 3,
	getURIs : function(){
		if(this.isURI()){return new jOWL.Ontology.Array([this.value]);}
		return this.mappings;
	},
	isVar : function(){return this.type == this.VAR;},
	isLiteral :  function(){return this.type == this.LITERAL;},
	isURI : function(){ return this.type == this.URI;}
};

/**
* @return Associative array of parameters in the current documents URL 
*/
jOWL.getURLParameters = function(){
	var href = window.location.href.split("?", 2), param = {};
	if(href.length == 1){ return {};}
	var qstr = href[1].split('&');
	for(var i =0;i<qstr.length;i++){
		var arr = qstr[i].split("=");
		if(arr.length == 2){ param[arr[0]] = arr[1];}
	}
	return param;
};

/**
Without arguments this function will parse the current url and see if any parameters are defined, returns a JOWL object
@return With argument it will return a string that identifies the potential permalink fr the given entry
*/
jOWL.permalink = function(entry){
	if(!entry){
		var param = jOWL.getURLParameters();
		if(param.owlClass){ return jOWL(unescape(param.owlClass));}
	}
	else {
		if(!entry.URI){ return false;}
		var href = window.location.href.split("?", 2);
		if(window.location.search){ href = href[0];}
		if(entry.isClass){ return href+'?owlClass='+escape(entry.URI);}
	}
	return false;
};

/** Convert an item into Manchester syntax, currently only for oneOf 
* @return String
*/
jOWL.Manchester = function(owlElement){
	var syntax = [];
	if(owlElement.isClass){
		var oneOf = owlElement.oneOf().map(function(){ return this.label();});
		if(oneOf.length){ syntax.push("{ "+oneOf.join(", ")+" }");}
	}
	return syntax.join(", ");
};

})(jQuery);

/**
* @return 1 for exact match, 0 for partial match, -1 for no match.
*/
String.prototype.searchMatch = function(matchstring, exact){
	if(this.search(new RegExp(matchstring, "i")) > -1){ return 1;} //contained within
	var c = 0; var arr = matchstring.match(new RegExp("\\w+", "ig"));
	for(var i = 0;i<arr.length;i++){ if(this.search(arr[i]) > -1){ c++;} }
	if(c == arr.length){ return 0;} //word shift
	return -1; //nomatch
};
/**
* @return Modified String.
*/
String.prototype.beautify = function(){
	var e1 = new RegExp("([a-z0-9])([A-Z])", "g");
	var e2 = new RegExp("([A-Z])([A-Z0-9])([a-z])", "g");
	var e3 = new RegExp("_", "g");
	return this.replace(e1, "$1 $2").replace(e2, "$1 $2$3").replace(e3, " ");
};