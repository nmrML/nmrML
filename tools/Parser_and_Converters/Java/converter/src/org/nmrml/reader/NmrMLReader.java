/*
 * $Id: Reader.java,v 1.0.alpha March 2014 (C) INRA - DJ $
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

package org.nmrml.reader;

import java.io.File;

import org.nmrml.parser.*;
import org.nmrml.schema.*;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Unmarshaller;

public class NmrMLReader {

    private static String nmrMLVersion;

    public static AcquParams acq;
    public static ProcParams proc;
    public static BinDataType fidData;
    public static BinDataType realSpectrum;

    public String getNmrMLVersion() { return this.nmrMLVersion; }

    public static class AcquParams extends Acqu {
        private String sweepWidthUnitName;
        private String relaxationDelayUnitName;
        private String temperatureUnitName;
        private String spectralWidthHzUnitName;
        private String transmiterFreqUnitName;
        private String spectralFrequencyUnitName;

        public String getSweepWidthUnitName() { return this.sweepWidthUnitName;  }
        public void setSweepWidthUnitName(String value) { this.sweepWidthUnitName = value; }
        public String getRelaxationDelayUnitName() { return this.relaxationDelayUnitName;  }
        public void setRelaxationDelayUnitName(String value) { this.relaxationDelayUnitName = value; }
        public String getTemperatureUnitName() { return this.temperatureUnitName;  }
        public void setTemperatureUnitName(String value) { this.temperatureUnitName = value; }
        public String getSpectralWidthHzUnitName() { return this.spectralWidthHzUnitName;  }
        public void setSpectralWidthHzUnitName(String value) { this.spectralWidthHzUnitName = value; }
        public String getTransmiterFreqUnitName() { return this.transmiterFreqUnitName;  }
        public void setTransmiterFreqUnitName(String value) { this.transmiterFreqUnitName = value; }
        public String getSpectralFrequencyUnitName() { return this.spectralFrequencyUnitName;  }
        public void setSpectralFrequencyUnitName(String value) { this.spectralFrequencyUnitName = value; }
    }

    public static class ProcParams extends Proc {
    }

    public static class BinDataType {
        private int numberOfDataPoints;
        private double[] Xvalues;
        private double[][] Yvalues;
        private int Ydimension;
        public int getNumberOfDataPoints() { return this.numberOfDataPoints; }
        public double[] getXvalues() { return this.Xvalues; }
        public double[][] getYvalues() { return this.Yvalues; }
        public int getYdimension() { return this.Ydimension; }
    }

    public NmrMLReader(File inputFile) {
          this(inputFile,false, false );
    }
    public NmrMLReader(File inputFile, boolean readFid) {
          this(inputFile,readFid, false );
    }

    public NmrMLReader(File inputFile,boolean readFid, boolean readRealData ) {

        try {

            AcquParams acq = new AcquParams();
            ProcParams proc = new ProcParams();
            this.acq = null;
            this.proc = null;

        /* Read nmrML file */
            JAXBContext jc = JAXBContext.newInstance(NmrMLType.class);
            Unmarshaller unmarshaller = jc.createUnmarshaller();
            NmrMLType nmrMLtype = (NmrMLType) unmarshaller.unmarshal(inputFile);

            nmrMLVersion = nmrMLtype.getVersion();

    /* ACQUISITION PARAMETERS */
            AcquisitionType schema_acq = nmrMLtype.getAcquisition();
            Acquisition1DType acq1D = schema_acq.getAcquisition1D();
            AcquisitionParameterSet1DType acq1DParamSet = acq1D.getAcquisitionParameterSet();

            acq.setNumberOfScans(acq1DParamSet.getNumberOfScans());
            acq.setNumberOfSteadyStateScans(acq1DParamSet.getNumberOfSteadyStateScans());

            acq.setTemperature(Double.parseDouble(acq1DParamSet.getSampleAcquisitionTemperature().getValue()));
            acq.setTemperatureUnitName(acq1DParamSet.getSampleAcquisitionTemperature().getUnitName());

            acq.setRelaxationDelay(Double.parseDouble(acq1DParamSet.getRelaxationDelay().getValue()));
            acq.setRelaxationDelayUnitName(acq1DParamSet.getRelaxationDelay().getUnitName());

            //acq.setSpiningRate(Double.parseDouble(acq1DParamSet.getSpinningRate().getValue()));
            //acq.setSpiningRateUnitName(acq1DParamSet.getSpinningRate().getUnitName());

            AcquisitionDimensionParameterSetType acqdimparam = acq1DParamSet.getDirectDimensionParameterSet();
            acq.setSpectralWidthHz(Double.parseDouble(acqdimparam.getSweepWidth().getValue()));
            acq.setSweepWidthUnitName(acqdimparam.getSweepWidth().getUnitName());

            acq.setTransmiterFreq(Double.parseDouble(acqdimparam.getIrradiationFrequency().getValue()));
            acq.setTransmiterFreqUnitName(acqdimparam.getIrradiationFrequency().getUnitName());
            acq.setSpectralFrequency(Double.parseDouble(acqdimparam.getEffectiveExcitationField().getValue()));
            acq.setSpectralFrequencyUnitName(acqdimparam.getEffectiveExcitationField().getUnitName());
// ... 
            this.acq = acq;

            /* Read FID data */
            if (readFid) {
                BinaryDataArrayType schema_fidData = acq1D.getFidData();
                BinaryData fidData_tmp = new BinaryData();
                fidData_tmp.setByteFormat(schema_fidData.getByteFormat());
                if (schema_fidData.isCompressed()) {
                     fidData_tmp.setData(fidData_tmp.decompress(schema_fidData.getValue()));
                } else {
                     fidData_tmp.setData(schema_fidData.getValue());
                }
                double [] fidValues = fidData_tmp.getDataAsDouble();
                
                BinDataType fidData = new BinDataType();
                fidData.Ydimension = fidData_tmp.getEncodedSize()[1];
                fidData.numberOfDataPoints = (int)(fidValues.length/fidData.Ydimension);
                double [][] fidMulValues = new double [fidData.Ydimension][fidData.numberOfDataPoints];
                for (int i=0; i<fidData.numberOfDataPoints; i++ ) {
                     for (int j=0; j<fidData.Ydimension; j++) {
                          fidMulValues[j][i] = fidValues[i*fidData.Ydimension+j];
                     }
                }
                fidData.Yvalues = fidMulValues;
                this.fidData = fidData;
            }

    /* PROCESSING PARAMETERS */

            this.proc = null;
            SpectrumListType spectrumList = nmrMLtype.getSpectrumList();
            Spectrum1DType spectrum1D = spectrumList.getSpectrum1D().get(0);
            FirstDimensionProcessingParameterSetType procParam1D = spectrum1D.getFirstDimensionProcessingParameterSet();
            AxisWithUnitType ppmAxis = spectrum1D.getXAxis();
            proc.setMaxPpm(Double.parseDouble(ppmAxis.getStartValue()));
            proc.setMinPpm(Double.parseDouble(ppmAxis.getEndValue()));
// ... 
            this.proc = proc;

            /* Read Real Spectrum data */
            if (readRealData) {
                BinaryDataArrayType schema_realSpectrum = spectrum1D.getSpectrumDataArray();
                BinaryData realSpectrum_tmp = new BinaryData();
                realSpectrum_tmp.setByteFormat(schema_realSpectrum.getByteFormat());
                if (schema_realSpectrum.isCompressed()) {
                     realSpectrum_tmp.setData(realSpectrum_tmp.decompress(schema_realSpectrum.getValue()));
                } else {
                     realSpectrum_tmp.setData(schema_realSpectrum.getValue());
                }
                double [] realSpectrumValues = realSpectrum_tmp.getDataAsDouble();
                
                BinDataType realSpectrum = new BinDataType();
                realSpectrum.Ydimension = realSpectrum_tmp.getEncodedSize()[1];
                realSpectrum.numberOfDataPoints = (int)(realSpectrumValues.length/realSpectrum.Ydimension);
                double delta_ppm = (proc.getMaxPpm() - proc.getMinPpm())/(realSpectrumValues.length - 1);
                double [] ppmValues = new double [realSpectrum.numberOfDataPoints];
                double [][] realDataValues = new double [realSpectrum.Ydimension][realSpectrum.numberOfDataPoints];
                for (int i=0; i<realSpectrum.numberOfDataPoints; i++ ) {
                     ppmValues[i] = proc.getMaxPpm() - i*delta_ppm;
                     for (int j=0; j<realSpectrum.Ydimension; j++) {
                          realDataValues[j][i] = realSpectrumValues[i*realSpectrum.Ydimension+j];
                     }
                }
                realSpectrum.Xvalues = ppmValues;
                realSpectrum.Yvalues = realDataValues;
                this.realSpectrum = realSpectrum;
            }

        } catch(NullPointerException e){
            //System.err.println("Error while parsing the XML file: "+e.getMessage());
            //System.exit(1);
        } catch( JAXBException je ) {
            je.printStackTrace();
        } catch( Exception e ) {
            e.printStackTrace();
        }

    }

}