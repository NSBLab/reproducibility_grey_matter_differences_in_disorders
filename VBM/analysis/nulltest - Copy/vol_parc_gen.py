# -*- coding: utf-8 -*-
"""
Created on Tue Feb 22 15:36:20 2022

@author: tcao0011
"""
import numpy as np
import random
import datetime
import sys
from brainsmash.mapgen.eval import sampled_fit
import nibabel as nib
import os
from brainsmash.mapgen.sampled import Sampled
from scipy.io import loadmat

# Get conditions from command-line arguments
diag = sys.argv[1]  # diagnosis
dataset = sys.argv[2] # dataset
nParc = sys.argv[3] # number of parcels
#diag = 'BD'  # diagnosis
#dataset = 'Baltimore' # dataset
#nParc = '100' # number of parcels

distance_files = {'D': '/scratch2/kg98/trangc/VBM/data/nulltest/volume_parc_'+ nParc + '/distmat.npy','index': '/scratch2/kg98/trangc/VBM/data/nulltest/volume_parc_'+ nParc + '/index.npy'}

# These are three of the key parameters affecting the variogram fit
kwargs = {'ns': 122,
          'knn': 122,
          'pv': 70
          }

now = datetime.datetime.now()
random.seed(int(now.strftime("%d%H%M%S")))

    # Step 3: Save the data to a text file
brain_map = '/projects/kg98/trangc/VBM/data/derivatives/roi' + '/' +diag + '/' + dataset + '/' + nParc + '_parcCon_statMap.txt'

gen = Sampled(x=brain_map, D=distance_files['D'], index=distance_files['index'], **kwargs)
surrogate_maps = gen(n=100)

output_filename = '/projects/kg98/trangc/VBM/data/derivatives/roi' + '/' +diag + '/' + dataset + '/' + nParc + '_parcCon_statMap_null.txt'
np.savetxt(output_filename, surrogate_maps)