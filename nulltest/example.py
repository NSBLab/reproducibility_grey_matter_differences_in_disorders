# -*- coding: utf-8 -*-
"""
Created on Tue Feb 22 09:13:53 2022

@author: tcao0011
"""
from brainsmash.mapgen.base import Base
#from wbplot import pscalar
import numpy as np
#Using BrainSMASH requires specifying two inputs:

# A brain map, i.e. a one-dimensional scalar vector, and

# A distance matrix, containing a measure of distance between each pair of elements in the brain map


brain_map_file = "LeftParcelMyelin.txt"  # use absolute paths if necessary!
dist_mat_file = "LeftParcelGeodesicDistmat.txt"
base = Base(x=brain_map_file, D=dist_mat_file)
surrogates = base(n=10)
#pscalar("surrogates.png", surrogates)
# path_str='UCLA/'+line[0:9]+'/surf/'
# data_folder = Path(path_str)
#output_filename = "LeftParcelMyelin.txt"
#np.savetxt(output_filename, surrogates)