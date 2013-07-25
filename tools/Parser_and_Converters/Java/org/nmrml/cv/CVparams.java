package org.nmrml.cv;

/*
 * $Id: CVparams.java,v 0.1 2013-07-24 09:50:00 DJ $
 */

import java.io.*;
import java.util.*;
import java.lang.*;

public class CVparams
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
