/*
 * CC-BY 4.0
 */

package org.nmrml.parser.jeol;

import org.nmrml.parser.Acqu;
import org.nmrml.parser.Proc;
import org.nmrml.cv.SpectrometerMapper;

import java.math.BigInteger;
import java.io.BufferedReader;
import java.io.File;
import java.io.RandomAccessFile;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.charset.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.Locale;

/**
 * Reader for Jeol JDF file
 *
 * @author Daniel Jacob
 *
 * Date: 18/09/2017
 *
 */
public class JeolAcquReader implements AcquReader {

    private RandomAccessFile in;
    private SpectrometerMapper vendorMapper;

    public void setVendorMapper(SpectrometerMapper vendorMapper) {
        this.vendorMapper = vendorMapper;
    }

    public static Charset charset = Charset.forName("UTF-8");
    public static CharsetEncoder encoder = charset.newEncoder();
    public static CharsetDecoder decoder = charset.newDecoder();

    private int readInt(ByteOrder endian) throws IOException {
        byte[] buf = new byte[4]; 
        in.read(buf);
        ByteBuffer buffer = ByteBuffer.wrap(buf, 0, 4);
        buffer.order( endian );
        return (int)buffer.getInt();
    }

    private JeolParameter readParam(int len, ByteOrder endian) throws IOException {
        byte[] buf = new byte[len];
        int nb=in.read(buf);

        JeolParameter param = new JeolParameter();

        ByteBuffer buffer = ByteBuffer.wrap(buf, 4, 2);
        buffer.order( endian );
        param.unit_scaler = (int)buffer.getShort();

        buffer = ByteBuffer.wrap(buf, 6, 10);
        buffer.order( endian );
        int u1 = (int)buffer.get() & 0xFF;
        int v1 = (int)Math.floor(u1 / 16);
        int v2 = (v1>8) ? (v1 % 8) : (v1 % 8) + 8;
        param.unit_prefix = v2;
        param.unit = buffer.get();

        buffer = ByteBuffer.wrap(buf, 32, 2);
        buffer.order( endian );
        int value_type = (int)buffer.getShort();
        param.value_type = value_type;

        switch (value_type) {
           case 0: buffer = ByteBuffer.wrap(buf, 16, 16);
                   buffer.order( endian );
                   param.valueString = decoder.decode(buffer).toString().trim();
               break;
           case 1: buffer = ByteBuffer.wrap(buf, 16, 4);
                   buffer.order( endian );
                   param.valueInt = (int)buffer.getInt();
               break;
           case 2: buffer = ByteBuffer.wrap(buf, 16, 8);
                   buffer.order( endian );
                   param.valueDouble = (double)buffer.getDouble();
               break;
           case 3: buffer = ByteBuffer.wrap(buf, 16, 16);
                   buffer.order( endian );
               break;
        }
        buffer = ByteBuffer.wrap(buf, 36, 28);
        buffer.order( endian );
        param.name = decoder.decode(buffer).toString().toLowerCase();

        return param;
    }

    private String readString(int len) throws IOException {
        char[] array=new char[len];
        for(int count=0;count<len;count++) array[count]=(char)in.readByte();
        String str = new String(array);
        return str;
    }

    public JeolAcquReader() {
    }
    
    public JeolAcquReader(File acquFile) throws IOException {
        in = new RandomAccessFile(acquFile, "r");
    }
    
    public JeolAcquReader(String filename) throws IOException {
        this(new File(filename));
    }

/**
* acquisition.setSoftware()						Author
* acquisition.setSoftVersion()					version
* acquisition.setProbehead()					x_probe_map
* acquisition.setSolvent()						solvent
* acquisition.setNumberOfScans()				total_scans
* acquisition.setNumberOfSteadyStateScans()		x_prescans
* acquisition.setTemperature()					temp_set
* acquisition.setRelaxationDelay()				relaxation_delay 
* acquisition.setSpiningRate()					spin_set
* acquisition.setDspGroupDelay()				orders & factors
* acquisition.setPulseProgram()					experiment
* acquisition.setAquiredPoints()				x_points
* acquisition.setObservedNucleus()				x_domain
* acquisition.setDecoupledNucleus
* acquisition.setSpectralWidthHz()				x_sweep
* acquisition.setTransmiterFreq()				x_freq / irr_freq ??? (SF01)
acquisition.setSpectralFrequency()				???  (BF1)
* acquisition.setPulseWidth()					x_pulse
**/

    @Override
    public Acqu read() throws Exception {

        boolean fprt=false;

        Matcher matcher;
        Locale.setDefault(new Locale("en", "US"));
        Acqu acquisition = new Acqu(Acqu.Spectrometer.JEOL);

        in.seek(0);
        String File_Identifier = this.readString(8);
if( fprt) System.err.println( String.format( "Header: File_Identifier = %s", File_Identifier ) );

        int Endian = in.readUnsignedByte();
        ByteOrder byteOrder = Endian==1 ? ByteOrder.LITTLE_ENDIAN : ByteOrder.BIG_ENDIAN ;
        acquisition.setByteOrder(byteOrder);
        acquisition.setBiteSyze(8);

if( fprt) System.err.println( String.format( "Header: Endian = %d", Endian ) );

        int Major_version = in.readUnsignedByte();
if( fprt) System.err.println( String.format( "Header: Major_version = %d", Major_version ) );

        in.seek(12);
        int Data_Dimension_Number = in.readUnsignedByte();
if( fprt) System.err.println( String.format( "Header: Data_Dimension_Number = %d", Data_Dimension_Number ) );

        in.seek(14);
        int Data_Type = in.readUnsignedByte();
if( fprt) System.err.println( String.format( "Header: Data_Type = %d", Data_Type ) );

        String Instrument = this.vendorMapper.getTerm("INSTRUMENT", String.format("%d", in.readUnsignedByte() ) );
if( fprt) System.err.println( String.format( "Header: Instrument = %s", Instrument ) );

        in.seek(24);
        byte[] Data_Axis_Type = new byte[8]; in.read(Data_Axis_Type);
if( fprt) System.err.println( String.format( "Header: Data_Axis_Type = %d, ... ", Data_Axis_Type[0] ));

        byte[] Data_Units = new byte[16]; in.read(Data_Units);
if( fprt) System.err.println( String.format( "Header: Data_Units = %d, %d, ...", Data_Units[0],Data_Units[1] ));

        String Title = this.readString(124);
if( fprt) System.err.println( String.format( "Header: Title = %s", Title ) );

        in.seek(176);
        int Data_Points = in.readInt();
if( fprt) System.err.println( String.format( "Header: Data_Points = %d", Data_Points ) );

        in.seek(208);
        int Data_Offset_Start = in.readInt();
if( fprt) System.err.println( String.format( "Header: Data_Offset_Start = %d", Data_Offset_Start ) );

        in.seek(408);
        String Node_Name = this.readString(16);
if( fprt) System.err.println( String.format( "Header: Node_Name = %s", Node_Name ) );
        String Site = this.readString(128);
if( fprt) System.err.println( String.format( "Header: Site = %s", Site ) );
        String Author = this.readString(128);

if( fprt) System.err.println( String.format( "Header: Author = %s", Author ) );
        String Comment = this.readString(128);
if( fprt) System.err.println( String.format( "Header: Comment = %s", Comment ) );
        String Data_Axis_Titles = this.readString(256);
if( fprt) System.err.println( String.format( "Header: Data_Axis_Titles = %s", Data_Axis_Titles ) );

        in.seek(1064);
        double Base_Freq = in.readDouble();
if( fprt) System.err.println( String.format( "Header: Base_Freq = %f", Base_Freq ) );

        in.seek(1128);
        double Zero_Freq = in.readDouble();
if( fprt) System.err.println( String.format( "Header: Zero_Freq = %s", Zero_Freq ) );

        in.seek(1212);
        int Param_Start = in.readInt();
if( fprt) System.err.println( String.format( "Header: Param_Start = %d", Param_Start ) );

//        in.seek(1228);
        in.seek(1284);
        long Data_Start = (long)in.readInt();
if( fprt) System.err.println( String.format( "Header: Data_Start = %d", Data_Start ) );
        long Data_Length = in.readLong();
if( fprt) System.err.println( String.format( "Header: Data_Length = %d", Data_Length ) );

if( fprt) System.err.println("------");

        in.seek((long)Param_Start);

        int Parameter_Size = this.readInt(byteOrder);
        int Low_Index      = this.readInt(byteOrder);
        int High_Index     = this.readInt(byteOrder);
        int Total_Size     = this.readInt(byteOrder);
if( fprt) System.err.println( String.format( "Header: Params: Size=%d, Low_Index=%d, High_Index=%d, Total_Size=%d", Parameter_Size, Low_Index, High_Index, Total_Size ) );

if( fprt) System.err.println("------");

        boolean irr_mode = false;
        int[] factors = null;
        int[] orders = null;

        for( int count=0;count<=High_Index;count++) {

            JeolParameter param = this.readParam(64, byteOrder);
            String param_name = param.name.trim();
            String Unit_label = "";

            boolean flg = false;
            if ( param_name.equals("inst_model_number") ) {
                 acquisition.setInstrumentName(param.valueString);
                 flg = true;
            }
            if ( param_name.equals("version") ) {
                 acquisition.setSoftVersion(param.valueString);
                 flg = true;
            }
            if ( param_name.equals("experiment") ) {
                 acquisition.setPulseProgram(param.valueString);
                 flg = true;
            }
            if ( param_name.equals("sample_id") ) {
                 flg = true;
            }
            if ( param_name.equals("probe_id") ) {
                 flg = true;
            }
            if ( param_name.equals("total_scans") ) {
                 acquisition.setNumberOfScans(BigInteger.valueOf(param.valueInt));
                 flg = true;
            }
            if ( param_name.equals("acq_delay") ) {
                 flg = true;
            }
            if ( param_name.equals("delay_of_start") ) {
                 flg = true;
            }
            if ( param_name.equals("relaxation_delay") ) {
                 acquisition.setRelaxationDelay(param.valueDouble);
                 flg = true;
            }
            if ( param_name.equals("exp_total") ) {
                 flg = true;
            }
            if ( param_name.equals("solvent") ) {
                 acquisition.setSolvent(param.valueString);
                 flg = true;
            }
            if ( param_name.equals("temp_set") ) {
                 Unit_label = this.vendorMapper.getTerm("Unit_labels", String.format("%d", param.unit ));
                 if(Unit_label.equals("dC")) {
                    acquisition.setTemperature(param.valueDouble + 273.15);
                 } else {
                    acquisition.setTemperature(param.valueDouble);
                 }
                 flg = true;
            }
            if ( param_name.equals("spin_set") ) {
                 acquisition.setSpiningRate((int)(param.valueDouble));
                 flg = true;
            }
            if ( param_name.equals("irr_mode") ) {
                 if (param.valueString.toLowerCase().equals("off") ) {
                    acquisition.setDecoupledNucleus("off");
                 }
                 flg = true;
            }
            if ( param_name.equals("irr_domain") ) {
                 if (param.valueString.toLowerCase().equals("proton") ) {
                     acquisition.setDecoupledNucleus("1H");
                 }
                 if (param.valueString.toLowerCase().equals("Carbon13") ) {
                     acquisition.setDecoupledNucleus("13C");
                 }
                 flg = true;
            }
            if ( param_name.equals("irr_freq") ) {
                 flg = true;
            }
            if ( param_name.equals("irr_offset") ) {
                 flg = true;
            }
            if ( param_name.equals("x_acq_time") ) {
                 flg = true;
            }
            if ( param_name.equals("x_acq_duration") ) {
                 flg = true;
            }
            if ( param_name.equals("x_probe_map") ) {
                 acquisition.setProbehead(param.valueString);
                 flg = true;
            }
            if ( param_name.equals("x_prescans") ) {
                 acquisition.setNumberOfSteadyStateScans(BigInteger.valueOf(param.valueInt));
                 flg = true;
            }
            if ( param_name.equals("x_points") ) {
                 acquisition.setAquiredPoints(param.valueInt);
                 flg = true;
            }
            if ( param_name.equals("x_domain") ) {
                 String ObservedNucleus = param.valueString;
                 if (param.valueString.toLowerCase().equals("proton") ) {
                       ObservedNucleus = "1H";
                 }
                 acquisition.setObservedNucleus(ObservedNucleus);
                 acquisition.setDecoupledNucleus("off");
                 flg = true;
            }
            if ( param_name.equals("x_freq") ) {
                 Unit_label = this.vendorMapper.getTerm("Unit_labels", String.format("%d", param.unit ));
                 if(Unit_label.equals("Hz")) {
                      acquisition.setTransmiterFreq(param.valueDouble/1000000.0);
                 } else {
                      acquisition.setTransmiterFreq(param.valueDouble);
                 }
                 flg = true;
            }
            if ( param_name.equals("x_sweep") ) {
                 acquisition.setSpectralWidthHz(param.valueDouble);
                 flg = true;
            }
            if ( param_name.equals("x_offset") ) {
                 flg = true;
            }
            if ( param_name.equals("x_pulse") ) {
                 acquisition.setPulseWidth(param.valueDouble);
                 flg = true;
            }
            if ( param_name.equals("x_resolution") ) {
                 flg = true;
            }
            if ( param_name.equals("factors") ) {
                 String[] sfactors = param.valueString.trim().replace("  ", " ").split(" ");
                 factors = new int[sfactors.length];
                 for(int i=0; i<sfactors.length; i++)
                 {
                     try {
                         factors[i] = Integer.parseInt(sfactors[i]);
                     } catch (NumberFormatException nfe) {
                         //Not an integer 
                     }
                 }
                 flg = true;
            }
            if ( param_name.equals("orders") ) {
                 String[] sorders = param.valueString.trim().replace("  ", " ").split(" ");
                 orders = new int[sorders.length];
                 for(int i=0; i<sorders.length; i++)
                 {
                     try {
                         orders[i] = Integer.parseInt(sorders[i]);
                     } catch (NumberFormatException nfe) {
                         //Not an integer 
                     }
                 }
                 flg = true;
            }
            if (fprt & flg) {
               System.err.print( String.format( "Param: %s", param.name ) );
               if (param.value_type==0) System.err.print( String.format( "\t = \t %s ", param.valueString ) );
               if (param.value_type==1) System.err.print( String.format( "\t = \t %d", param.valueInt ) );
               if (param.value_type==2) System.err.print( String.format( "\t = \t %f", param.valueDouble ) );
               System.err.println( String.format( " %s%s", 
                    this.vendorMapper.getTerm("Unit_prefix", String.format("%d", param.unit_prefix )),
                    this.vendorMapper.getTerm("Unit_labels", String.format("%d", param.unit )) ) );
            };
        }

        /* Software */
        acquisition.setSoftware(vendorMapper.getTerm("SOFTWARE", "SOFTWARE"));

        /* sweep width in ppm*/
        acquisition.setSpectralWidth( acquisition.getSpectralWidthHz()/acquisition.getTransmiterFreq());

        /* Group Delay = 0 */
        acquisition.setDspGroupDelay( 0.0 );
        if (orders.length>0 && factors.length>0) {
            double GroupDelay = 0;
            int nbo = orders[0];
            for (int k=0; k<nbo; k++) {
                double prodfac = 1;
                for (int i=k; i<nbo; i++) prodfac *= factors[i];
                GroupDelay = GroupDelay + 0.5*(( orders[k+1] - 1)/prodfac);
            }
            acquisition.setDspGroupDelay( GroupDelay );
        }

        /* Pointer (offset) into the JDF file where data start  (in octets) */
        acquisition.setDataOffset(Data_Start);
        /* Data length into the JDF file from data start  (in octets) */
        acquisition.setDataLength(Data_Length);

if( fprt) System.err.println("------");

        in.close();

        return acquisition;
    }

}
