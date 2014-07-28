/**
* jOWL Browser -extension to jOWL to easily visualize ontologies.
* Creator - David Decraene
* Version 1.0
* Website: 
*	http://jowl.ontologyonline.org
*/

var jOWLBrowser = {
	isReady : true,
	views : []
};
	
function createSparqlDLWidget(){
		function displayResults(obj){
			var display = $('#sparqlresults');
			if(obj.error){ display.text("Error: "+obj.error); }
			else {
				display.empty();
				if(!obj.results || !obj.results.length) {  display.text("No results found"); $(".loader").hide(); return; }
				display.append($('<div class="stats"/>').text("Number of results: "+obj.results.length));
				
				for(var i=0;i<obj.results.length;i++){
					var txt = [];
					for(x in obj.results[i]){ 
							var str = (typeof obj.results[i][x] == 'string') ? obj.results[i][x] : obj.results[i][x].label();
							txt.push(x+' : '+str);
						}
					display.append($('<div/>').text(txt.join(', ')));
				}

			}
			$(".loader").hide();
		}

		$('#sparql').submit(function(){
			var v = $('input', this).val(); 
			$(".loader").show();
			new jOWL.SPARQL_DL(v).execute({ onComplete : displayResults, expandQuery : true});	 
			return false; 
			});
}

function showOverviewResults(results, list, widget){
	var maxcount = 50;
	var hidden = $('<div/>').hide();
	jOWL.throttle(results, {
		limit : 200,
		modify : function(item){
			maxcount--;
			var $el = item.bind($("<span class='jowl_link'/>"));
			$el.click(function(){
				if(widget && widget.propertyChange){ widget.propertyChange(jOWL(this.title)); }
			});
			if(maxcount > 0)  { if(maxcount != 49) list.append($("<span/>").text(",   ")); $el.appendTo(list); }
			else if(maxcount === 0){ list.append(hidden); }
			if(maxcount <=0) {if(maxcount != 0) hidden.append($("<span/>").text(",   "));  $el.appendTo(hidden);}
		},
		onComplete : function(arr){
			if(maxcount < 0) list.append($("<div class='jowl_link' style='margin-top:5px;'/>").text("... ["+maxcount*-1+" more]").click(function(){hidden.slideDown(); $(this).hide(); }));
		},
		chewsize : 20,
		timing : 5
	})

}

function createOverviewWidget(){

	function sparql(query, list, widget, cb){
		var maxcount = 50; var hidden = $('<div/>').hide();
		new jOWL.SPARQL_DL(query).execute({
			limit : 200,
			onComplete : function(res){
				if(!res.results) {return; }
				showOverviewResults(res.jOWLArray("?x"), list, widget);
				if(cb){ cb();}
			}
		});
	}

	function triggerView(num){
		var v = jOWLBrowser.views[num];
		if(v){
			sparql(v.query, v.element, v.widget, function(){
				triggerView(num+1);
			});
		}
	}
	triggerView(0);

};

function createConceptWidget(){
		var widget = {};
		jOWL.UI.asBroadcaster(widget);
		widget.propertyChange = function(item){ widget.broadcast(item); }

		var jnode = $('#conceptwidget');

		var descriptionpanel = $('.resourcebox', jnode).owl_propertyLens({
			"term" : {split: ", "},
			"sparql-dl:DirectType(?i, owl:Class)": {split: ", "},
			"owl:disjointWith": {split: ", "},
			onChange : {
				"owl:Thing": function(source, target, resourcebox){	this.addClass("jowl_tooltip"); tooltip.display(target, this); },
				"owl:Class": function(source, target, resourcebox){ resourcebox.link(source, target, this); }
			}
		});
		
		var tooltip = $('#thingwidget .resourcebox').clone(true).removeClass("owl_UI_box").addClass("owl_UI");
		tooltip.children('.title').remove();
		tooltip = tooltip.owl_propertyLens({tooltip: true});

		//initialize UI components
		var tree = $('#treeview').owl_treeview({addChildren: true, isStatic: true});
		var autocomplete = $('#owlauto').owl_autocomplete({focus : true, chars : 2, filter : 'Class'});
		var navbar = $('#navbar').owl_navbar();

		widget.show = function(){
			var concept = null;
			if(configuration.owlClass){ concept = jOWL(configuration.owlClass);}
			else {
				for(x in jOWL.index("ID")){
					var entry = jOWL.index("ID")[x];
					if(entry.isClass)  { concept = entry; break; }
				}
			}
			if(concept){
				this.propertyChange(concept);
			}
		}

		function toggleView(id){
			switch (id)
			{
			case 'navbar': $('#navbar').show(); $('#treeview').hide(); break;
			case 'treeview': $('#navbar').hide(); $('#treeview').show(); break;
			} return this;
		}
		toggleView($(':radio:checked').val());
		//show hint section
		$('#owlauto').blur(function(){$(this).siblings('.info').show();}).focus(function(){$(this).siblings('.info').fadeOut(1000);}).blur();
		$(':radio').change(function(){toggleView($(this).val());});
		//making sure components respond to each others input:
		widget.addListener([tree, navbar, descriptionpanel]);
		autocomplete.addListener([tree, navbar, descriptionpanel]);
		tree.addListener([navbar, descriptionpanel]);
		navbar.addListener([tree, descriptionpanel]);
		descriptionpanel.addListener([tree, navbar]);
		widget.show();
		return widget;
	}

function createPropertyWidget(){
	$('#propertywidget').show();
	return $('#propertywidget .resourcebox').owl_propertyLens({"term" : {split: ", "}});
}

function createIndividualsWidget(){
	$('#thingwidget').show();
	return $('#thingwidget .resourcebox').owl_propertyLens({"sparql-dl:PropertyValue(owl:Thing, ?p, ?t)" : {sort: "?p"}});
}

function createOntologyWidget(){
	var ontologywidget = $('#title').owl_propertyLens();
	ontologywidget.propertyChange(new jOWL.Ontology());
}
