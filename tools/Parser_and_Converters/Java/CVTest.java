/*
 * $Id: CVTest.java,v 0.1 2013-07-24 09:50:00 DJ $
 */

import java.io.*;
import java.util.*;
import java.lang.*;

/*
public static String[][] cvList = {
      {"NMR", "Nuclear Magnetic Resonance CV", "http://msi-ontology.sourceforge.net/ontology/NMR.owl", "0.1.0" },
      {"OBI", "Ontology for Biomedical Investigations", "http://purl.obolibrary.org/obo/obi", "2012.07.01" },
      {"UO", "Unit Ontology", "http://purl.obolibrary.org/obo/", "3.2.0" }
};
*/

/* to be put in a separated file: cv.java as a public class */
class cv
{
    public static final Integer NO_UNIT  = 0;
    public static final Integer PPM_UNIT = 1;
    public static final Integer HZ_UNIT  = 2;
    public static final Integer DEG_UNIT = 3;

    public static String[][] Units = {
            {"UO", "UO_0000186", "dimensionless unit"},
            {"UO", "UO_0000169", "parts per million"},
            {"UO", "UO_0000106", "Hertz"},
            {"UO", "UO_0000185", "degree"}
    };

    public static final Integer NO_WF   = 0;
    public static final Integer EM_WF   = 1;
    public static final Integer GM_WF   = 2;
    public static final Integer SINE_WF = 3;

    public static String[][] WindowFunction = {
            {"NMR", "#NMR_400xxx", "no window function"},
            {"NMR", "#NMR_400097", "Line Broadening"},
            {"NMR", "#NMR_400097", "Gaussion"},
            {"NMR", "#NMR_400097", "Sine"}
    };
    
    public static final Integer D2O_SOL   = 0;

    public static String[][] Solvent = {
            {"CHEBI", "CHEBI_41981", "D20"}
    };

    /* to be extended ... */

}

/* to be put in a separated file: CVparams.java as a public class */
class CVparams
{
    private String IDREF;
    private String Accession;
    private String Name;

    public CVparams(String[][] CV, int id) {
        this.IDREF=CV[id][0];
        this.Accession=CV[id][1];
        this.Name=CV[id][2];
    }
    public String getIDREF(){ return this.IDREF; }
    public String getAccession(){ return this.Accession; }
    public String getName(){ return this.Name; }

}

public class CVTest
{

    public static void main(String[] args)
    {
        CVparams cv_unit = new CVparams(cv.Units,cv.PPM_UNIT);
        System.out.println("Unit: Name="+cv_unit.getName()+", Accession="+cv_unit.getAccession());

        CVparams cv_solvent = new CVparams(cv.Solvent,cv.D2O_SOL);
        System.out.println("Solvent: Name="+cv_solvent.getName()+", Accession="+cv_solvent.getAccession());

        CVparams cv_wfunc = new CVparams(cv.WindowFunction,cv.GM_WF);
        System.out.println("Window Function: Name="+cv_wfunc.getName()+", Accession="+cv_wfunc.getAccession());
    }
}
