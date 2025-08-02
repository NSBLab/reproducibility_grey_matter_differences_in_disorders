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

in1 = 500 #int(sys.argv[1])
in2 = 1000 #int(sys.argv[2])
in3 = 70 #int(sys.argv[3])
condition = 'BD'
item = 'Baltimore'
# Conditional assignment
if condition == 'AD':
    diaggroup = 'AD'
else:
    diaggroup = 'psy'

distance_files = {'D': '/scratch2/kg98/trangc/VBM/data/nulltest/volume_'+ diaggroup +'_GB/distmat.npy','index': '/scratch2/kg98/trangc/VBM/data/nulltest/volume_'+ diaggroup +'_GB/index.npy'}

# smoothing kernel
smoothkernel = '6'

# Specify the directory path (replace with your actual path)
directory_path = '/projects/kg98/trangc/VBM/data/derivatives/s' + smoothkernel + 'COMBAT/' + condition

full_path = os.path.join(directory_path, item)  # Get the full path
if os.path.isdir(full_path):  # Check if the item is a directory
    # Step 1: Load the NIfTI file
    nii_file = full_path + '/' + 'spmT_0001.nii'  # Replace with your file path
    img = nib.load(nii_file)
    data = img.get_fdata()
    #mask_file = '/projects/kg98/trangc/VBM/data/derivatives/s' + smoothkernel + 'COMBAT/mask_' + diaggroup + '/mask.nii'  # Replace with your file path
    #mask = nib.load(mask_file)
    #maskdata = mask.get_fdata()
    # Load atlas
    s132_img = nib.load('/fs03/kg98/gchan/Atlases/Tian/Schaefer_Tian/reordered/Schaefer2018_100Parcels_' +
                        '7Networks_order_Tian_Subcortex_S2_MNI152NLin6Asym_1.5mm_reordered.nii.gz')
    atlas = s132_img.get_fdata()

    # Define the ROI range
    roi_i = 51
    roi_j = 66
    #data_dir = './data/l_subcx/'

    # Get the indices of voxels that are within the ROI range
    maskdata = (atlas >= roi_i) & (atlas <= roi_j)

    # Step 2: mask the data
    maskedData = data[maskdata>0]

    # Step 3: Save the data to a text file
    brain_map = full_path + '/' + 'spmT_0001_GB.txt'
    np.savetxt(brain_map, maskedData, fmt='%.6f')  # Save with 6 decimal precision

#for val in range(2000, 10000, 1000):
# These are three of the key parameters affecting the variogram fit
kwargs = {'ns': in1,
      'knn': in2,
      'pv': in3,
      'seed': 2
      }

#now = datetime.datetime.now()
#random.seed(int(now.strftime("%d%H%M%S")))
output1_filename = "/home/trangc/kg98/trangc/VBM/code/nulltest/pythonProject/test_dense_vol_emp_vario" + str(
kwargs['ns']) + '_' + str(kwargs['knn']) + '_' + str(kwargs['pv']) + "_smooth" + smoothkernel +"_GB.txt"

(emp_var, u0, surr_var, surrogate_maps) = sampled_fit(x=brain_map, D=distance_files['D'],  index=distance_files['index'],nsurr=2,return_data=True, **kwargs)
np.savetxt(output1_filename, emp_var)
output2_filename = "/home/trangc/kg98/trangc/VBM/code/nulltest/pythonProject/test_dense_vol_sur_vario"+str(kwargs['ns']) + '_'+ str(kwargs['knn'])+'_'+str(kwargs['pv'])+ "_smooth" + smoothkernel +"_GB.txt"
np.savetxt(output2_filename, surr_var)
output3_filename = "/home/trangc/kg98/trangc/VBM/code/nulltest/pythonProject/test_dense_vol_map" + str(
    kwargs['ns']) + '_' + str(kwargs['knn']) + '_' + str(kwargs['pv']) + "_smooth" + smoothkernel + "_GB.txt"
np.savetxt(output3_filename, surrogate_maps)


