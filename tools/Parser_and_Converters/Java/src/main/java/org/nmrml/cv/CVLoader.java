package org.nmrml.cv;

import org.ini4j.Ini;
import org.ini4j.Wini;
import org.nmrml.model.CVParamType;
import org.nmrml.model.CVType;
import org.nmrml.model.ObjectFactory;

import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;

/**
 * Created with IntelliJ IDEA.
 * User: ldpf
 * Date: 02/10/2013
 * Time: 11:49
 * To change this template use File | Settings | File Templates.
 */
public class CVLoader {

    private HashMap<String,CVType> cvTypeHashMap;
    private Wini ontologyIni;

    public CVLoader() throws IOException {
        this(ClassLoader.getSystemResourceAsStream("org/nmrml/ontologies/onto.ini"));
    }

    public CVLoader(InputStream inputStream) throws IOException {
        this.ontologyIni = new Wini(inputStream);
        this.cvTypeHashMap = new HashMap<String, CVType>();
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
        String cvTerm = ontologyTerms.fetch(term);
        if(cvTerm == null)
            throw new Exception("Term ["+term + "] not found in "+ontology);
        CVParamType cvParamType = new ObjectFactory().createCVParamType();
        cvParamType.setCvRef(cvTypeHashMap.get(ontology));
        cvParamType.setAccession(cvTerm.split(";")[0]);
        cvParamType.setName(cvTerm.split(";")[1]);
        return cvParamType;
    }

    public HashMap<String, CVType> getCvTypeHashMap() {
        return cvTypeHashMap;
    }
}
