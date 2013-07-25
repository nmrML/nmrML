/*
 * Copyright (c) 2013. EMBL, European Bioinformatics Institute
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package uk.ac.ebi.nmr.fid;

/**
 * Spectrum data structure.
 *
 * @author  Luis F. de Figueiredo
 *
 * User: ldpf
 * Date: 29/04/2013
 * Time: 12:22
 *
 */
public class Spectrum {


    private Acqu acqu;
    private Proc proc;
    private double [] fid;
    private double [] realChannelData;
    private double [] imaginaryChannelData;
    private double [] baselineModel;
    private boolean [] baseline;

    public Spectrum(double[] fid, Acqu acqu, Proc proc) {
        this.fid=fid;
        this.acqu=acqu;
        this.proc=proc;
    }
    public Spectrum(double[] fid, Acqu acqu) throws Exception {
        this(fid, acqu, new Proc(acqu));
    }

    public Proc getProc() {
        return proc;
    }

    public Acqu getAcqu() {
        return acqu;
    }

    public double[] getFid() {
        return fid;
    }

    public void setFid(int i, double value) {
        this.fid[i]= value;
    }

    public double[] getRealChannelData() {
        return realChannelData;
    }

    public void setRealChannelData(double[] realChannelData) {
        this.realChannelData = realChannelData;
    }

    public void setRealChannelData(int i, double value) {
        this.realChannelData[i] = value;
    }

    public double[] getImaginaryChannelData() {
        return imaginaryChannelData;
    }

    public void setImaginaryChannelData(double[] imaginaryChannelData) {
        this.imaginaryChannelData = imaginaryChannelData;
    }
    public void setImaginaryChannelData(int i, double value) {
        this.imaginaryChannelData[i] = value;
    }

    private void splitData() {
        realChannelData=new double[fid.length/2];
        imaginaryChannelData=new double [fid.length/2];
        for(int i=0; i < fid.length; i+=2){
            realChannelData[i/2]=fid[i];// real are in even positions
            imaginaryChannelData[i/2]=fid[i+1];// imaginary are in odd positions
        }
    }

    public double[] getBaselineModel() {
        return baselineModel;
    }

    public void setBaselineModel(double[] baselineModel) {
        this.baselineModel = baselineModel;
    }

    public boolean[] getBaseline() {
        return baseline;
    }

    public void setBaseline(boolean[] baseline) {
        this.baseline = baseline;
    }
}
