# -*- coding: utf-8 -*-
"""
Created on Tue Feb 22 15:36:20 2022

@author: tcao0011
"""
import numpy as np
import random
import datetime
import sys


distance_files = {'D': '/scratch2/kg98/trangc/VBM/data/nulltest/volume_parc_100/distmat.npy','index': '/scratch2/kg98/trangc/VBM/data/nulltest/volume_parc_100/index.npy'}

from brainsmash.mapgen.eval import sampled_fit
import nibabel as nib
import numpy as np
import os

# These are three of the key parameters affecting the variogram fit
kwargs = {'ns': 122,
          'knn': 122,
          'pv': 70
          }


now = datetime.datetime.now()
random.seed(int(now.strftime("%d%H%M%S")))
from brainsmash.mapgen.sampled import Sampled


    # Step 3: Save the data to a text file
brain_map = '/home/trangc/kg98/trangc/VBM/data/ABIDEI/sub-50432/anat/mwp1sub-50432_T1w_Buckner-whole_1mm_Tian_Subcortex_S1_3T_2009cAsym_Schaefer2018_100Parcels_7Networks_order_CAT12MNI.txt'
#data = np.loadtxt(brain_map)
#maskedData = data[1:]
#brain_map_masked = '/home/trangc/kg98/trangc/VBM/code/nulltest/pythonProject/testsub_parc_mask.txt'
#np.savetxt(brain_map_masked, maskedData, fmt='%.6f')  # Save with 6 decimal precision

gen = Sampled(x=brain_map, D=distance_files['D'], index=distance_files['index'], **kwargs)
surrogate_maps = gen(n=100)

from brainsmash.mapgen.eval import sampled_fit

    # from brainsmash.utils.eval import sampled_fit  analogous function for Sampled class
sampled_fit(x=brain_map, D=distance_files['D'], index=distance_files['index'], nsurr=100, **kwargs)