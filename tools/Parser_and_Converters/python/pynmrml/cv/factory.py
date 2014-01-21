from owl_parser import *
import os


class CvFactory(object):

    # TODO decide on what to do with the value here
    @classmethod
    def ontology_dir(cls,filename):
        return os.path.join( "/Users/mike/Projects/nmrML/nmrML/ontologies/",filename)

    @classmethod
    def nmrCV(cls):
        namespaces = {
            'dc': "http://purl.org/dc/elements/1.1/",
            'protege': "http://protege.stanford.edu/plugins/owl/protege#",
            'meta': "http://www.co-ode.org/ontologies/meta.owl#",
            'rdfs': "http://www.w3.org/2000/01/rdf-schema#",
            'obo': "http://purl.obolibrary.org/obo/",
            'xsd': "http://www.w3.org/2001/XMLSchema#",
            'owl': "http://www.w3.org/2002/07/owl#",
            'rdf': "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
            'ru-meta': "http://purl.org/imbi/ru-meta.owl#",
            'doap': "http://usefulinc.com/ns/doap#",
            'oboInOwl': "http://www.geneontology.org/formats/oboInOwl#",
            'skos': "http://www.w3.org/2004/02/skos/core#",
            'btl2': "http://purl.org/biotop/btl2.owl#"
        }

        return OwlParser(cls.ontology_dir("nmrCV.owl"), namespaces, '#')

    @classmethod
    def uo(cls):
        namespaces = {
            'obo': "http://purl.obolibrary.org/obo/",
            'rdfs': "http://www.w3.org/2000/01/rdf-schema#",
            'owl': "http://www.w3.org/2002/07/owl#",
            'xsd': "http://www.w3.org/2001/XMLSchema#",
            'rdf': "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
            'oboInOwl': "http://www.geneontology.org/formats/oboInOwl#",
            'uo': "http://purl.obolibrary.org/obo/uo#"
        }

        return OwlParser(cls.ontology_dir("ImportedOntologies/uo.owl"), namespaces, '/')


if __name__ == "__main__":
    CvFactory.uo()
    CvFactory.nmrCV()