import os, nmrglue
from abstract_reader import AbstractReader
from ...util import convert
import re

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

    # Determines the state of first decoupler during different status periods within a
    # pulse sequence (refer to the manual VNMR User Programming for a discussion
    # of status periods). Pulse sequences may require one, two, three, or more
    # different decoupler states. The number of letters that make up the dm parameter
    # vary appropriately, with each letter representing a status period (e.g.,
    # dm='yny' or dm='ns'). If the decoupler status is constant for the entire
    # pulse sequence, it can be entered as a single letter (e.g., dm='n').
    #
    # Values: 'n', 'y', 'a', or 's' (or a combination of these values), where:
    #
    #       'n' specifies no decoupler rf.
    #       'y' specifies the asynchronous mode. In this mode, the decoupler rf is gated
    #       on and modulation is started at a random places in the modulation sequence.
    #       'a' specifies the asynchronous mode, the same as 'y'. The 'a' value is not
    #       available on MERCURY series and GEMINI 2000 systems.
    #       's' specifies the synchronous mode in which the decoupler rf is gated on and
    #
    # modulation is started at the beginning of the modulation sequence. This value
    # has meaning only on UNITYINOVA and UNITYplus systems. On UNITY and
    # VXR-S systems it is equivalent to 'y'. The 's' value is not available on
    # MERCURY series and GEMINI 2000
    #
    def decoupling_method(self):
        pattern = re.compile('^n+$')
        return not pattern.match(self.get_param('dm'))

    # TODO get info about the files in the directory??
    def source_file_descriptions(self):
        return []


