Generic Ontology Browser
built for the jOWL - Semantic Javascript Library
Version 1.0
Creator: David Decraene
Released: 11-03-2009
___________________________________________________________________________________________________________

This package contains additional files necessary to set up a generic jOWL browser similar to what can be found at:
http://jowl.ontologyonline.org/jOWLBrowser.html

Usage:
	1. Unzip this package to your disk
	2. Unzip the latest jOWL package to the same folder (minimum version: 1.0).
	3. Modify the configuration object in the jOWLBrowser.html file to suit your needs:

	Example:

	var configuration = {
		ontology : "data/wine.owl", //the ontology to load
		owlClass       : "wine", //The class to show when loading
		classOverview  : true, //show or hide the class overview list.
		propertiesTab  : true, //show or hide the properties panel
		individualsTab : true, //show or hide the individuals panel
		sparqldlTab    : true  //show or hide the sparq-dl panel
	}


This package contains:

jOWLBrowser.html	html file that allows browsing of ontologies
data/wine.owl		the prototypical wine ontology, for testing purposes
css/			contains the blueprint css framework, can be updated with more recent version found at: http://www.blueprintcss.org/
			contains basic jQuery themeroller css files (UI version 1.7) , can be updated with custom themeroller files found at: http://ui.jquery.com/themeroller
scripts/			empty directory where the latest jOWL scripts should be placed. 
img/			empty directory where the jOWL images will be put

This package does NOT contain:
	a jOWL version, for that, proceed to http://code.google.com/p/jowl-plugin/ and download the latest release.
	Unzip the contents into this generic jOWL browser folder (if done properly scripts go automatically into the scripts folder, etc)...
	Upload all files to the web in their current folder structure to allow online browsing.

More information on jOWL at http://jowl.ontologyonline.org