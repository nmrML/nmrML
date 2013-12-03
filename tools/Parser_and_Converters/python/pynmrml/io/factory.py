# Using a factory to build readers and writers will allow us to easily
# handle backwards compatability, multiple CV version, multiple schema versions,
# building a factory based on an input dir, etc.

from ..readers.varian_reader import *
from ..writers.nmrml import *


def varian_to_nmrml(input_file):
    return nmrmlWriter(VarianOneDReader,input_file)

            #.write(open(output_file,"w"))
