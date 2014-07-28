/*
 * jOWL_UI, User Interface Elements for jOWL, semantic javascript library
 * Creator - David Decraene
 * Version 1.0
 * Website: http://Ontologyonline.org
 * Licensed under the MIT license
 * Verified with JSLint http://www.jslint.com/
 */
(function($){

jOWL.UI = {
	broadcaster : function(){
		var listeners = [];
		this.addListener = function(obj){
			function add(obj){if(obj.propertyChange) { listeners.push(obj); } }
			if(obj.constructor == Array){for(var i=0;i<obj.length;i++){ add(obj[i]); } }
			else { add(obj); }
			return this; 
		};
		this.broadcast = function(item){ for(var i=0;i<listeners.length;i++){ listeners[i].propertyChange.call(item, item); } };
		if(!this.propertyChange){ this.propertyChange = function(item){}; }
	},
	asBroadcaster : function(ui_elem){ ui_elem.broadcaster = jOWL.UI.broadcaster; ui_elem.broadcaster(); },
	defaults : {
		contentClass: "jowl-content",
		focusClass: "ui-state-hover",
		wrapperClass : "ui-widget-content"
	}
};

/** 
WIDGETS 
all widgets: 
	addListener : add an object with a propertyChange function, will be triggered on select
	propertyChange: update the widget with a new jowl object
Events:
	onSelect: (look into propertylens click), return false to suppress the event, this = jquery element, first argument = jOWL object
CSS:
	wrapperClass: css class(es) for main element, the el itself
	contentClass: css class(es) for main content element, accessible by el.content
	focusClass: css class(es) for element in focus,
*/
$.fn.extend({
/* 
owl_navbar
options:
	onSelect : this element refers to jquery node, first argument = jOWL object
*/
	owl_navbar: function(options){
		options = $.extend({
			contentClass : jOWL.UI.defaults.contentClass,
			focusClass : jOWL.UI.defaults.focusClass,
			onSelect : function(item){},
			onPropertyChange : function(item){}
		}, options);
		var self = this;
		this.addClass("jowl-navbar");
		this.content = $("."+options.contentClass, this).empty();
			if(!this.content.length) { this.content = $("<div/>").addClass(options.contentClass).appendTo(this); }
		this.parents =  $('<div/>').appendTo(this.content);
		this.focus = $('<div/>').addClass(options.focusClass).appendTo(this.content);
		this.children = $('<div/>').appendTo(this.content);
		var listnode = $('<span/>').click(function(){
			var node = $(this);
			var res = jOWL(node.attr('title'));
			if(options.onSelect.call(node, res) === false) { return; }
			if(res && res.isClass) { self.propertyChange.call(res, res); self.broadcast(res); }
		});

		jOWL.UI.asBroadcaster(this);

		this.propertyChange = function(item){
			if(options.onPropertyChange.call(this, item) === false) { return; }
			if(item.isClass){
				item.bind(self.focus);
				if(jOWL.options.reason) { item.hierarchy();}
				self.parents.empty().append(item.parents().bind(listnode));
				self.children.empty().append(item.children().bind(listnode));
			}
		};
		return this;
	},
/** 
autocomplete field.
*/
	owl_autocomplete : function(options){
		options = $.extend({
			time:500, //responsetime to check for new keystrokes, default 500
			chars:3, //number of characters needed before autocomplete starts searching
			focus:false, //put cursor on the input field when loading
			limit:10, //limit size of result list to given amount
			contentClass : "ui-widget-content",
			focusClass : jOWL.UI.defaults.focusClass,
			hintClass : "ui-autocomplete-hint",
			hint: false, //Message (if any) to show when unfocused.
			onSelect : function(item){}, //function that can be overridden
			formatListItem : function(listitem, type, identifier, termarray){ //formatting of results, can be overridden
				if(type){ listitem.append($('<div class="type"/>').text(type)); }
				listitem.append($('<div class="name"/>').text(identifier));
				if(termarray.length) { listitem.append($('<div class="terms"/>').text(termarray.join(', '))
					.prepend($('<span/>').addClass('termlabel').text("Terms: ")));
			}
		}}, options);
		jOWL.UI.asBroadcaster(this);

		this.showHint = function(){
			this.hinted = true;
			if(options.hint){
				this.addClass(options.hintClass).val(options.hint);
			}
			else {this.val(''); }
		};
		this.showHint();

		var self = this; var old = ''; var open = false; self.val('');
		var results = $('<ul/>').addClass(options.contentClass).addClass("jowl_autocomplete_results");
		var div = $("<div/>").addClass(options.wrapperClass).append(results); this.after(div);
		results.cache = {};
		results.isEmpty = function(){ for(x in results.cache) { return false; } return true; };
		results.close = function(){this.hide();};
		results.open = function(q, cache){
			this.show(); 
			if(q){
				if(!cache || results.isEmpty()) { results.cache = jOWL.query(q, options); }
				else { 
					var newcache = {};
					for(x in results.cache){
						var entry = results.cache[x]; 
						var found = false;
						var newentries = [];
						if(x.searchMatch(q) > -1) { found = true; }
						for(var i = 0;i<entry.length;i++){
							if(entry[i].term.searchMatch(q) > -1) { found = true; newentries.push(entry[i]); }
						}
						if(found) { newcache[x] = newentries; }
						}
					results.cache = newcache;
					}
				this.populate(results.cache);
				}
		};

		results.populate = function(data){
			var res = this; this.empty(); var count =0;
			var clickFunction = function(){
				var node = $(this), res = jOWL(node.data("jowltype"));
				if(options.onSelect.call(node, res) === false) { return; }
				self.broadcast(res);
			};

			var onHover = function(){ $(this).addClass(options.focusClass); };
			var offHover = function(){$(this).removeClass(options.focusClass);};

			for(x in data){
				if(count < options.limit){
					var item = data[x];
					var v = jOWL.isExternal(x);
					v = v ? v[1] : x;
					var list = $('<li/>').data("jowltype", x)
					.click(clickFunction).hover(onHover, offHover)
					.appendTo(res);
					var terms = [];
					for(var l = 0;l<item.length;l++){ 
						var found = false; var newterm = item[l].term;
						for(var y=0; y < terms.length;y++){ if(terms[y].toLowerCase() == newterm.toLowerCase()) { found = true; } }
						if(!found) { terms.push(newterm); }
						}
					options.formatListItem.call(list, list, item[0].type, v, terms);

				}
				count++;
			}
		};

		setInterval(function(){
			var newvalue = self.val();
			var cache = true;
			if(old != newvalue){
				var longervalue = newvalue.length > old.length && newvalue.indexOf(old) === 0;
				if(!old) { cache = false; }
				old = newvalue; 
				if(newvalue.length < options.chars && open){ results.close();open = false;}
				else if(newvalue.length >=options.chars && newvalue.length > 0){
					if(cache) { cache = longervalue && newvalue.length > options.chars; }
					results.open(newvalue, cache);
					open = true;
					}
				
			}
		}, options.time);

		self.bind('keyup', function(){ if(!this.value.length){ results.close(); open = false; } });
		self.bind('blur', function(){
			if(open){setTimeout(function(){results.close();}, 200);open = false;}
			if(!self.val().length){self.showHint();}
			});
		//timeout for registering clicks on results.
		self.bind('focus', function(){
			if(self.hinted){
				self.hinted = false;
				$(this).removeClass(options.hintClass).val('');
			}
			if(self.val().length && !open){results.open('', open);open = true;}});
		//reopen, but do not get results
		return this;
	},
/** 
Tree View
*/
	owl_treeview : function(options){
		options = $.extend({
			contentClass : jOWL.UI.defaults.contentClass,
			focusClass: "focus",
			nameClass: "name",
			treeClass: "jowl-treeview",
			rootClass: "root",
			onSelect : function(item){}, //function that can be overwritten to specfy behavior when something is selected
			rootThing : false, //if true then topnode is (owl) 'Thing'
			isStatic : false, // if static then selections will refresh the entire tree
			addChildren : false //add a given objects children to the treeview as well
		}, options);

		/** construct the hierarchy & make a tree of it */
		function TreeModel(owlobject){
			
			function clear(el){ //reset invParents, for later use.
				if(el.parents) { el.parents().each(function(){
					this.invParents = null; clear(this);
				}); }
			}

			function leaf(node){
				node.jnode.addClass(options.focusClass);
				if(options.addChildren){
					var entry = jOWL(node.$name.attr('title'));
					if(entry && entry.children){ entry.children().each(function(){ node.add(this); }); } }
			}

			function traverse(itemarray, appendto){
				if(!itemarray) { return; }
				itemarray.each(function(){
					var node = appendto.add(this);
					if(this.invParents){ traverse(this.invParents, node); }
					else { leaf(node); }
				});

			}	

			var h = owlobject.hierarchy(true);
			if(options.rootThing) { traverse(h, tree.root(jOWL("Thing"))); }
			else { 
				var root = tree.root(h); 
				for(var i=0;i<root.length;i++){ 
						traverse(root[i].invParents, root[i]);
						if(!root[i].invParents) { leaf(root[i]); }
					}

				}
			clear(owlobject);

		}

		/**
		var tree = $(selector).owl_treeview();
		var root = tree.root("node");
		root.add("node2").add("child");
		*/
		function Tree(node, treemodel, options){
			var rack = $('<ul/>').addClass(options.treeClass).appendTo(node);
			var tree = this;
			/**item can be text, a jOWL object, or a jOWL array */
			this.root = function(item){
				var rt = null; //root
				rack.empty();  
				if(item && item.each) {
					rt = [];
					item.each(function(it){
						var x =  new fn.node(it, true); 
						x.wrapper.addClass("tv");
						x.jnode.appendTo(rack);
						x.invParents = it.invParents; it.invParents = null;	//reset for later use
						rt.push(x);
					}); 
					return rt;
				}
				rt = new fn.node(item, true);
				rt.wrapper.addClass("tv"); 
				rt.jnode.appendTo(rack);
				return rt;
			};

			var fn = {};
			fn.node = function(text, isRoot){ //creates a new node
				this.jnode = isRoot ? $('<li/>').addClass(options.rootClass) : $('<li class="tvi"/>');
				this.$name = null;
				if(text){
					this.$name = $('<span/>').addClass(options.nameClass);
					if(typeof text == "string") { this.$name.html(text); }
					else if(text.bind) { text.bind(this.$name); }
					var n = this.$name; 
					this.$name.appendTo(this.jnode).click(function(){
						var entry = jOWL(n.attr('title'));
						if(entry && options.onSelect.call(n, entry) === false) { return; }
						tree.broadcast(entry); 
						if(options.isStatic) { tree.propertyChange(entry); }
						return false;});
				}
				
				this.wrapper = $('<ul/>').appendTo(this.jnode);
				var self = this;
					self.jnode.click(function(){toggle(); return false;});

				this.add = function(text){
					var nn = new fn.node(text);
					if(!self.wrapper.children().length) { toNode();	}
					else { 
						var lastchild = self.wrapper.children(':last'); 
						lastchild.swapClass("tvilc", "tvic");
						lastchild.swapClass("tvile", "tvie");
						lastchild.swapClass("tvil", "tvi");
						
						}//children - change end of list
					self.wrapper.append(nn.jnode.swapClass('tvi', 'tvil'));
					return nn;
					};

				function toggle(){ 
					var t = self.jnode.hasClass("tvic") || self.jnode.hasClass("tvie") || self.jnode.hasClass("tvilc") || self.jnode.hasClass("tvile");
					if(!t) { return; }
					self.jnode.swapClass('tvic', 'tvie'); self.jnode.swapClass('tvilc', 'tvile');
					self.wrapper.slideToggle();
					}

				function toNode(){ 
					self.jnode.swapClass('tvil', 'tvilc');
					self.jnode.swapClass('tvi', 'tvic');
					}
				};
				return this;
		}// end Tree

		this.addClass("jowl-tree");
		this.content = $("."+options.contentClass, this).empty();
		if(!this.content.length){ this.content = $('<div/>').addClass(options.contentClass).appendTo(this); }
		var tree = new Tree(this.content, null, options);
		jOWL.UI.asBroadcaster(tree);
		tree.propertyChange = function(item){ if(item.isClass) { var m = new TreeModel(item); } };
		return tree;
	},
/** Uses templating 	
options: 
onChange: owl:Class, owl:Thing, etc..., tell the widget what to do with the different kinds of Ontology Objects.
"data-jowl" : {split: ",  ", "somevariable" : function_triggered_for_each_result } 
   example: "rdfs:label" : {split: ",  ", "rdfs:label" : function(){ //'this' keyword refers to HTML element}} )
   example: "sparql-dl:PropertyValue(owl:Class, ?p, ?x)" : {"?p": function(){ //'this' keyword refers to HTML element }}
   //prefil: for sparql-dl queries
   //onComplete: function to trigger when the specific propertybox query is completed, this refers to the HTML element for propertybox
   //sort: sort results on specified parameter, for sparql-dl results.
onUpdate: called when the widget updates itself
*/
		owl_propertyLens : function(options){ 
			var self = this;
			self.options = $.extend({
				backlinkClass : "backlink",
				split: {},
				disable : {},
				click : {}},
				options);
			self.resourcetype = this.attr('data-jowl') || "owl:Class";
			var propertyboxes = [];
			$('.propertybox', this).each(function(){
				var node = new jOWL.UI.PropertyBox($(this), self);
				propertyboxes.push(node);
				node.el.hide();
			});
			var backlink = $('.backlink', this).hide();
			if(!backlink.length) { backlink = $('<div class="jowl_link"/>').addClass(self.options.backlinkClass).text("Back").hide().appendTo(this); }
			jOWL.UI.asBroadcaster(this);

			/** fn: optional function to execute*/
			this.link = function(source, target, htmlel, fn){
				htmlel.addClass("jowl_link").click(function(){
				if(fn) { fn(); }
				self.broadcast(target);
				self.propertyChange(target);
				backlink.source = source.name;
				backlink.show().unbind('click').click(function(){
					self.broadcast(source); self.propertyChange(source); backlink.hide();
				});

				});

			};

			var action = {
				"rdfs:label": function(item){ return [{"rdfs:label": item.label() }]; },
				"rdf:ID" : function(item){ return [{"rdf:ID": [item.name, item] }]; },
				"rdfs:comment" : function(item){
					return $.map(item.description(), function(n){return {"rdfs:comment":n }; });
					},
				"rdf:type" : function(item){
					if(item.owlClass) { return [{"rdf:type": item.owlClass() }]; }
					return [{"rdf:type": item.type }];
				},
				"term" : function(item){
					return $.map(item.terms(), function(n, i){ return { "term" : n[0] }; });
				},
				"rdfs:range": function(item){if(item.range) { return [{"rdfs:range": item.range }]; } },
				"rdfs:domain": function(item){if(item.domain) { return [{"rdfs:domain": item.domain }]; } },
				"permalink": function(item){
					var href = jOWL.permalink(item);
					return [{"permalink": "<a href='"+href+"'>Permalink</a>" }];
				},
				"owl:disjointWith": function(item){
					if(!(item.isClass)) { return; }
					return $.map(
							jOWL.Xpath('*', item.jnode)
								.filter(function(){return this.nodeName == "owl:disjointWith"; }), 
							function(n, i){ return {"owl:disjointWith": jOWL($(n).RDF_Resource())};
							});	
				},
				"default" : function(item){
					var type = this.attr("data-jowl");
					return $.map(
								jOWL.Xpath('*', item.jnode).filter(function(){return this.nodeName == type; }),
								function(n, i){ var x = {}; x[type] = $(n).text(); return x; }
								);	
				}
			};

			this.propertyChange = function(item){ 
				if(!item) { return; }
				self.property = item;
				if(backlink.source != item.name) { backlink.hide(); } else { backlink.source = false; }
				
				if(item.type != self.resourcetype){
					if(item.isDatatypeProperty && self.resourcetype == "rdf:Property") {}
					else if(item.isObjectProperty && self.resourcetype == "rdf:Property"){}
					else { return; }
				}

				for(var i = 0;i<propertyboxes.length;i++){
					var pbox = propertyboxes[i];
					pbox.clear();
					if(!pbox.actiontype){return; }
					var actiontype = pbox.actiontype;
					if(self.options.disable[actiontype]) { return; }

					if(!self.options[actiontype]) { self.options[actiontype] = {}; }

					if(actiontype.indexOf("sparql-dl:") === 0){ 
						var query = actiontype.split("sparql-dl:", 2)[1];
						var fill = {}; fill[self.resourcetype] = item;
						if(self.options[actiontype].prefill) { $.extend(fill, self.options[actiontype].prefill); }
						var qr = new jOWL.SPARQL_DL(query, fill).execute({onComplete : function(r){
							if(self.options[actiontype].sort) { r.sort(self.options[actiontype].sort); }
							pbox.setResults(r.results, item);
							}});
					}
					else {
						var choice = (action[actiontype]) ? actiontype : "default";
						var results = action[choice].call(pbox.valuebox, item);
						pbox.setResults(results, item);
					}
				}
					
					if(self.options.onUpdate) { self.options.onUpdate.call(this, item); }
			}; //end property change
		
		if(self.options.tooltip){
			var lens = this.remove();
			this.display = function(element, htmlel){
				htmlel.tooltip({
					title: element.label(), 
					html: function(){	lens.propertyChange(element); backlink.hide(); return lens.get(0); }
				}); 
			};
		}
		return this;
		},

/**
Use propertyChange to set the class
Use addField to add property refinements
Use serialize to serialize input
*/
	owl_datafield: function(options){
		options = $.extend({
			selectorClass : "jowl-datafield-selector",
			messageClass : "jowl-datafield-message",
			labelClass : "jowl-datafield-property-label"
		}, options);
		var self = this;
		var pArray = {}; //associative array for properties.
		this.messages = {};
		this.messages[jOWL.NS.xsd()+"positiveInteger"] = "Allowed values: positive numbers or comparisons like  '>5 && <15' ";

		this.addClass("owl_UI");
		jOWL.UI.asBroadcaster(this);

		this.property = null;

		this.propertyChange = function(item){
			if(item.isClass){
				this.property = item;
					for(x in pArray){//reset all properties
						if(pArray[x].remove){ pArray[x].remove(); delete pArray[x]; }
					}
			}
		};

		/** Sets up a new field */
        this.addField = function(property){
            if(pArray[property.URI]){
                //allow for multiple fields?
				return;
            }

			var $content = $("<div/>");
				 pArray[property.URI] = $content;

			var $title = property.bind($("<div/>")).addClass(options.labelClass).appendTo($content).click(function(){ $content.remove(); delete pArray[property.URI]; });

            if(property.isObjectProperty){

				var sp = new jOWL.SPARQL_DL("Type(?t, ?c),PropertyValue(concept, property, ?c)", {concept : self.property, property : property }).execute({ 
					onComplete : function(obj){
						if(!obj.results.length){ return; } //modify to deal with non value results
						obj.sort("?t");
						
						$select = $("<select class='"+options.selectorClass+"'/>").appendTo($content);

						for(var i=0;i<obj.results.length;i++){
							obj.results[i]['?t'].bind($("<option/>")).appendTo($select);
						}

						$content.appendTo(self);
					}});

            }
            else if(property.isDatatypeProperty){
				var msg ="";
				if(self.messages[property.range]){ msg = self.messages[property.range];	}

				var $input = $('<div/>').addClass(options.selectorClass).attr("title", property.range).append($('<input type="text" style="font-size:11px;width:100px;"/>'));
				var $message = $('<div/>').addClass(options.messageClass).text(msg).appendTo($input);

				$content.append($input).appendTo(self);
				$('input', $content).focus(function(){
					$message.animate({opacity: 1.0}, 1500).fadeOut();
				});

				
			}

		};

		this.serialize = function(){
			var q = { "Type": self.property, "PropertyValue" : [] };

			$('.'+options.selectorClass, self).each(function(){
				var $this = $(this);
				var $prop = $this.siblings('.'+options.labelClass);
				var prop = $prop.attr('title');
				if( $this.is("select")){
						var s = $this.get(0);
						var thing = $(s[s.selectedIndex]).attr('title');
						q.PropertyValue.push([prop, thing]);
					}
				else {
					var $input = $this.find("input");
					var datatype = $this.attr('title');
					var entry = $input.get(0).value;
					if(entry) { q.PropertyValue.push([prop, '"'+entry+'"']); }
				}
			});
			return q;
		};

		return this;
	}
});

/** Used by owl_PropertyLens */
jOWL.UI.PropertyBox = function($el, resourcebox){
	var v = $('[data-jowl]', $el);
	if(v.length){	this.descendant = true;}

	this.el = $el;
	this.resourcebox = resourcebox;
	this.valuebox = v.length ? v : $el;
	this.actiontype = this.valuebox.attr('data-jowl'); 
};

jOWL.UI.PropertyBox.prototype = {
	setResults : function(results, item){
		var nodes = jOWL.UI.Template(results, this.valuebox, this.resourcebox.options[this.actiontype].split);
		this.complete(nodes, item);
		if(nodes && nodes.length && this.descendant) { this.el.show(); this.valuebox.hide(); } 
		if(this.resourcebox.options[this.actiontype].onComplete) { this.resourcebox.options[this.actiontype].onComplete.call(this.el.get(0)); }	
	},
	complete : function(nodes, item){
		var res = this.resourcebox;
		if(!nodes || !nodes.length) { return; }
		var v = $.data(nodes, "parameters"); 
		for(x in v){ 
			if(v[x].length && typeof res.options[this.actiontype][x] == "function") {
				v[x].each(res.options[this.actiontype][x]);
			}}
		for(x in res.options.onChange){
			var data = $('[typeof='+x+']', nodes).add(nodes.filter('[typeof='+x+']'));
			if(x.charAt(0) == "." || x.charAt(0) == "#"){ data = data.add($(x, nodes));}
			data.each(function(){
				var node = $(this);
				$.data(node, 'data-jowl', x);
				var id = node.attr('title');
				if(id != "anonymousOntologyObject") { res.options.onChange[$.data(node, 'data-jowl')].call(node, item, jOWL(id), res); }
			});
		}
	},
	clear : function(){
		var prev = this.valuebox.prev('.jowl-template-result');
		if(!prev.length){ prev = this.valuebox.prev('.jowl-template-splitter');}
		if(prev.length) { prev.remove(); this.clear(this.valuebox); }
	}
};

/**arr: associative array of variablrd, jqel: node for which variables need to be substituted,  */
jOWL.UI.Template = function(arr, jqel, splitter){
	var options = {
		resultClass : "jowl-template-result",
		splitterClass : "jowl-template-splitter"
	};
	if(!arr) { return; }

	function bindObject(value, jnode){
		var bound = false;
		if(!value) { return false; }
		if(typeof value == 'string') { jnode.html(value); bound = true;}
		else if(value.constructor == Array){ 
			if(value.length == 2) { value[1].bind(jnode).text(value[0]); bound = true;	} 
			}
		else if(value.bind){ value.bind(jnode); bound = true; }
		return bound;
	}
	var count = 0, a = [], b = {};
	var remnantFn = function(){
		var txt = $(this).text(); 
		if(txt.indexOf('${') === 0 && txt.lastIndexOf('}') == txt.length-1 ) { $(this).hide(); }
	};
	for(var i=0;i<arr.length;i++){ 
		var x = jqel.clone(true).wrapInner("<"+jqel.get(0).nodeName+" class='"+options.resultClass+"'/>").children();
		/** copy style settings */
			x.addClass(jqel.attr('class')).removeClass('propertybox');
		/** accepted obj types= string, array["string", "jowlobject"], jowlobject*/
		for(obj in arr[i]){
			if(!b[obj]) { b[obj] = []; }
			var occurrences = $(':contains(${'+obj+'})', x);
			if(!occurrences.length){
				if(x.text() == "${"+obj+"}") { if(bindObject(arr[i][obj], x)) {
					count++; b[obj].push(x.get(0));
				}}
			}
			else { 
				occurrences.each(function(){	
					if(this.innerHTML == "${"+obj+"}") { var node = $(this); if(bindObject(arr[i][obj], node)) { count++;  b[obj].push(this); }	}
				});
			}
		}
		var remnants = $(':contains(${)', x); //hide parameters that weren't substituted
			remnants.each(remnantFn);
		if(count){
			x.insertBefore(jqel);
			a.push(x.get(0));
			if(count > 1 && splitter) { 
				$splitter = (splitter.indexOf('<') === 0) ? $(splitter) : $("<span/>").text(splitter);
				$splitter.addClass(options.splitterClass).insertBefore(x);
				}
		}
	}
	for(x in b){ if(b[x].length) { b[x] = $(b[x]); } }
	var nodes = $(a);
	$.data(nodes, "parameters", b);
	return nodes;
};

/** 
Supporting functionality
*/

$.fn.swapClass = function(c1,c2) {
	return this.each(function() {
		if ($(this).hasClass(c1)) { $(this).removeClass(c1); $(this).addClass(c2);} 
		else if ($(this).hasClass(c2)) {$(this).removeClass(c2);$(this).addClass(c1);}
		});
};

})(jQuery);