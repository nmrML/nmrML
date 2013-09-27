/*
 * $Id: CVTest.java,v 0.1 2013-07-24 09:50:00 DJ $
 */
package org.nmrml.test;

import java.io.*;
import java.util.*;
import java.lang.*;

import org.nmrml.cv.*;


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
