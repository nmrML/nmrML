#import xml.etree.ElementTree as ET
from lxml import etree

class OwlParser(object):

    def __init__(self,cvfile,namespaces,id_separator):
        self.cvfile = cvfile
        self.terms = {}
        self.namespaces = namespaces
        self.id_separator = id_separator
        self.parse_cvfile()


    def parse_cvfile(self):
        tree = etree.parse(self.cvfile)
        classes = tree.xpath("//owl:Class", namespaces=self.namespaces)

        for e in classes:
            about_attributes = e.get('{'+self.namespaces['rdf']+'}about')
            labels = e.xpath('./rdfs:label',namespaces=self.namespaces)

            if about_attributes and labels:
                id = about_attributes.split(self.id_separator)[-1]
                self.terms[id] = labels[0].text