/*
 * Copyright (c) 2014 EMBL, European Bioinformatics Institute
 *
 * CC-BY 4.0
 */

package org.nmrml.cv;

import org.ini4j.Ini;
import org.ini4j.Wini;
import org.nmrml.schema.CVParamType;
import org.nmrml.schema.CVTermType;
import org.nmrml.schema.CVType;
import org.nmrml.schema.ObjectFactory;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

/**
 * Created with IntelliJ IDEA.
 *
 * @author Luis F. de Figueiredo
 * @update 02/04/14 Daniel Jacob - INRA UMR 1332

 */
public class CVLoader {

    private HashMap<String,CVType> cvTypeHashMap;
    private Wini ontologyIni;

    public CVLoader(InputStream inputStream) throws IOException {
        this.ontologyIni = new Wini(inputStream);
        this.cvTypeHashMap = new HashMap<String, CVType>();
    }

    public Set<String> getCVOntologySet() throws Exception {
        return ontologyIni.get("ontologies").keySet();
    }

    public CVType fetchCVType(String ontology) throws Exception {
        // automatically add the ontology to the cv list
        if(!cvTypeHashMap.containsKey(ontology)){
            CVType cvType = new ObjectFactory().createCVType();
            Ini.Section ontologies = ontologyIni.get("ontologies");

            if(!ontologies.containsKey(ontology))
                throw new Exception("ontology ["+ ontology +"] not found");

            cvType.setId(ontology);
            String [] ontologyData = ontologies.get(ontology).split(";");
            cvType.setFullName(ontologyData[0]);
            cvType.setVersion(ontologyData[1]);
            cvType.setURI(ontologyData[2]);
            cvTypeHashMap.put(ontology,cvType);
        }
        return (CVType) cvTypeHashMap.get(ontology);
    }

    public CVParamType fetchCVParam(String ontology, String term) throws Exception {
        // automatically add the ontology to the cv list
        if(!cvTypeHashMap.containsKey(ontology)){
            CVType cvType = new ObjectFactory().createCVType();
            Ini.Section ontologies = ontologyIni.get("ontologies");

            if(!ontologies.containsKey(ontology))
                throw new Exception("ontology ["+ ontology +"] not found");

            cvType.setId(ontology);
            String [] ontologyData = ontologies.get(ontology).split(";");
            cvType.setFullName(ontologyData[0]);
            cvType.setVersion(ontologyData[1]);
            cvType.setURI(ontologyData[2]);
            cvTypeHashMap.put(ontology,cvType);
        }

        Ini.Section ontologyTerms = ontologyIni.get(ontology);
        //String cvTerm = ontologyTerms.fetch(term);
        String cvTerm = ontologyTerms.get(term);
        if(cvTerm == null)
            throw new Exception("Term ["+term + "] not found in "+ontology);
        CVParamType cvParamType = new ObjectFactory().createCVParamType();
        cvParamType.setCvRef(cvTypeHashMap.get(ontology));
        cvParamType.setAccession(cvTerm.split(";")[0]);
        cvParamType.setName(cvTerm.split(";")[1]);
        return cvParamType;
    }

    public CVTermType fetchCVTerm(String ontology, String term) throws Exception {
        CVParamType cvParamType = this.fetchCVParam(ontology,term);
        CVTermType cvTermType = new ObjectFactory().createCVTermType();
        cvTermType.setCvRef(cvParamType.getCvRef());
        cvTermType.setAccession(cvParamType.getAccession());
        cvTermType.setName(cvParamType.getName());
        return cvTermType;
    }

    public HashMap<String, CVType> getCvTypeHashMap() {
        return cvTypeHashMap;
    }
}
