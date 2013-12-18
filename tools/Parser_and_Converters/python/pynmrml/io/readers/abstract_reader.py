from abc import ABCMeta, abstractmethod
import os, struct, zlib, base64

class AbstractReader(object):
    __metaclass__ = ABCMeta

    def __init__(self,input_dir):
        self.input_dir = input_dir
        self.fid_data_memo = None
        self.fid_data_length_memo = None
        self.load_params()

    @abstractmethod
    def load_params(self):
        return

    @abstractmethod
    def number_of_scans(self):
        return

    @abstractmethod
    def number_of_steady_state_scans(self):
        return

    @abstractmethod
    def sample_acquisition_temperature(self):
        return

    @abstractmethod
    def spinning_rate(self):
        return

    @abstractmethod
    def relaxation_delay(self):
        return

    @abstractmethod
    def number_of_data_points(self):
        return

    @abstractmethod
    def acquisition_nucleus(self):
        return

    @abstractmethod
    def gamma_b1_pulse_field_strength(self):
        return

    @abstractmethod
    def irradiation_frequency(self):
        return

    @abstractmethod
    def irradiation_frequency(self):
        """
        @return: irradiation frequency in Hz
        """
        return

    @abstractmethod
    def decoupling_method(self):
        return

    @abstractmethod
    def source_file_descriptions(self):
        """
        @return: description of the source files that are
        present in the input directory
        """
        return

    @abstractmethod
    def read_fid_data(self):
        """
        Read FID data from the input format

        @return: FID data as an array of floats
        """
        return

    # TODO this only work for 1D data
    def fid_data(self):
        if self.fid_data_memo is None:
            self.fid_data_memo = self.fid_to_string(self.read_fid_data())
        return self.fid_data_memo

    def fid_data_length(self):
        if self.fid_data_length_memo is None:
            self.fid_data_length_memo = len(self.fid_data())
        return self.fid_data_length_memo

    def fid_to_string(self,fid_data_array):
        """
        Convert the fid data array into a bytestring, in row-major
        order then compress the string uzing zlib and the encode
        the resulting bytes in base64

        @return: base64 string
        """
        float_list = [[x.real,x.imag] for x in fid_data_array]
        array = [item for sublist in float_list for item in sublist]
        array_length = len(array)

        # Pack the array into a byte string, need to make sure
        # to use '<' so that the bits will be little-endian
        byte_string = struct.pack( '<'+str(array_length)+'f', *array )
        # Compress the bytes and encode the compressed_bytes
        # into base64 so that we can store it in xml
        compressed_bytes = zlib.compress(byte_string)
        # Python adds newline every 60 characters, we need to remove them to
        # ensure that tools do not have to deal with that
        return base64.encodestring(compressed_bytes).replace("\n","")
