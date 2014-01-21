from abstract_reader import AbstractReader
import os
import nmrglue

class BrukerOneDReader(AbstractReader):
    #def __init__(self, input_dir):
    #    self.load_params()
    #    self.super(VarianOneDReader, self, input_dir)

    def load_params(self):
        dic, _ = nmrglue.bruker.read(self.input_dir)
        self.varian_params = dic["procpar"]
        print self.input_dir

    # TODO deal with cases where endian is not correct ??
    def read_fid_data(self):
        fidfile = os.path.join(self.input_dir, "fid")
        dic, self.varian_fid = nmrglue.fileio.varian.read_fid(fidfile)
        return self.varian_fid

    def get_param(self,name):
        return self.varian_params[name]['values'][0]

    def number_of_scans(self):
        return self.get_param('nt')

    def number_of_steady_state_scans(self):
        return self.get_param('ss')

    def sample_acquisition_temperature(self):
        return self.get_param('temp')

    # TODO make sure this value is in Hz
    def spinning_rate(self):
        return self.get_param('spin')

    def relaxation_delay(self):
        return self.get_param('d1')

    def number_of_data_points(self):
        return self.get_param('np')

    # TODO convert the term to the one we need for the CV
    def acquisition_nucleus(self):
        return self.get_param('tn')

    # TODO calculate this value..
    def gamma_b1_pulse_field_strength(self):
        return "??"

    # TODO make sure this value is in Hz
    def irradiation_frequency(self):
        return self.get_param('sfrq')

    # TODO how to get this value ??
    def decoupling_method(self):
        return "??"

    # TODO get info about the files in the directory??
    def source_file_descriptions(self):
        return []


