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

distance_files = {'D': '/scratch2/kg98/trangc/VBM/data/nulltest/volume_'+ diaggroup +'_index_lh/distmat.npy','index': '/scratch2/kg98/trangc/VBM/data/nulltest/volume_'+ diaggroup +'_index_lh/index.npy'}

# smoothing kernel
smoothkernel = '6'

# Specify the directory path (replace with your actual path)
directory_path = '/projects/kg98/trangc/VBM/data/derivatives/s' + smoothkernel + 'COMBAT/' + condition

full_path = os.path.join(directory_path, item)  # Get the full path
if os.path.isdir(full_path):  # Check if the item is a directory
    # Step 1: Load the NIfTI file
    nii_file = full_path + '/' + 'spmT_0001_binary.nii'  # Replace with your file path
    img = nib.load(nii_file)
    data = img.get_fdata()
    mask_file = '/projects/kg98/trangc/VBM/data/derivatives/s' + smoothkernel + 'COMBAT/mask_' + diaggroup + '/mask_lh.nii'  # Replace with your file path
    mask = nib.load(mask_file)
    maskdata = mask.get_fdata()

    # Step 2: mask the data
    maskedData = data[maskdata>0]

    # Step 3: Save the data to a text file
    brain_map = full_path + '/' + 'spmT_0001_lh_binary.txt'
    np.savetxt(brain_map, maskedData, fmt='%.6f')  # Save with 6 decimal precision
#for val in range(2000, 10000, 1000):
# These are three of the key parameters affecting the variogram fit
kwargs = {'ns': in1,
      'knn': in2,
      'pv': in3,
      'seed': 2,
          'resample': True
      }

#now = datetime.datetime.now()
#random.seed(int(now.strftime("%d%H%M%S")))
output1_filename = "/home/trangc/kg98/trangc/VBM/code/nulltest/pythonProject/test_dense_vol_emp_vario" + str(
kwargs['ns']) + '_' + str(kwargs['knn']) + '_' + str(kwargs['pv']) + "_index_lh_binary.txt"

(emp_var, u0, surr_var, surrogate_maps) = sampled_fit(x=brain_map, D=distance_files['D'],  index=distance_files['index'],nsurr=2,return_data=True, **kwargs)
np.savetxt(output1_filename, emp_var)
output2_filename = "/home/trangc/kg98/trangc/VBM/code/nulltest/pythonProject/test_dense_vol_sur_vario"+str(kwargs['ns']) + '_'+ str(kwargs['knn'])+'_'+str(kwargs['pv'])+"_index_lh_binary.txt"
np.savetxt(output2_filename, surr_var)
# fill in the surrogate map values
null_map = np.zeros_like(maskdata, dtype=float)
null_map[maskdata>0] = surrogate_maps[0]

# Combine output with s132_img header and save
null_img = nib.Nifti1Image(null_map, mask.affine, mask.header)
output3_filename = "/home/trangc/kg98/trangc/VBM/code/nulltest/pythonProject/test_dense_vol_map" + str(
    kwargs['ns']) + '_' + str(kwargs['knn']) + '_' + str(kwargs['pv']) + "_smooth" + smoothkernel + "_index_lh_binary.nii.gz"
nib.save(null_img, output3_filename)
#np.savetxt(output3_filename, surrogate_maps)
