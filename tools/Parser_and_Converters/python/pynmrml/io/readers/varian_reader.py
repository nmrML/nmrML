import os, nmrglue
from abstract_reader import AbstractReader
from ...util import convert

class VarianOneDReader(AbstractReader):
    def load_params(self):
        dic, _ = nmrglue.varian.read(self.input_dir)
        self.varian_params = dic["procpar"]

    # TODO deal with cases where endian is not correct ??
    def read_fid_data(self):
        fidfile = os.path.join(self.input_dir, "fid")
        dic, self.varian_fid = nmrglue.fileio.varian.read_fid(fidfile)
        return self.varian_fid

    def get_param(self,name):
        # Returns the value from the procpar file for the varian parameter
        # passed in as the argument. 
        return self.varian_params[name]['values'][0]

    def number_of_scans(self):
        return self.get_param('nt')

    def number_of_steady_state_scans(self):
        return self.get_param('ss')

    def sample_acquisition_temperature(self):
        # need to output in kelvins, but the varian format stores it
        # in C so we need to convert
        return convert.celcius_to_kelvin(self.get_param('temp'))
        #return format( float(self.get_param('temp')) + 274.15 )

    # TODO make sure this value is in Hz
    def spinning_rate(self):
        return self.get_param('spin')

    def relaxation_delay(self):
        return self.get_param('d1')

    def number_of_data_points(self):
        return self.get_param('np')

    def sweep_width(self):
        return self.get_param('sw')

    def dwell_time(self):
        # dwell time is actually not available in varian, simply use
        # the inverse of sweep width to get the dwell time in Hz
        return 1/float(self.sweep_width())

    # in microseconds
    def pulse_width(self):
        return self.get_param('pw90')

    # TODO convert the term to the one we need for the CV
    def acquisition_nucleus(self):
        return self.get_param('tn')

    # TODO make sure this value is in Hz
    def irradiation_frequency(self):
        return self.get_param('sfrq')

    # TODO how to get this value ??
    def decoupling_method(self):
        return "??"

    # TODO get info about the files in the directory??
    def source_file_descriptions(self):
        return []


