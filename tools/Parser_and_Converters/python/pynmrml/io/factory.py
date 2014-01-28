# Using a factory to build readers and writers will allow us to easily
# handle backwards compatability, multiple CV version, multiple schema versions,
# building a factory based on an input dir, etc.

import readers, writers

#from .readers.varian_reader import *
#from .writers.nmrml import *


def varian_converter(input_file):
    return writers.nmrmlWriter(readers.VarianOneDReader,input_file)

#def bruker_to_nmrml(input_file):
#    return nmrmlWriter(BrukerOneDReader,input_file)

