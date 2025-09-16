# -*- coding: utf-8 -*-
"""
Created on Tue Feb 22 15:36:20 2022

@author: tcao0011
"""
import numpy as np
import random
import datetime
import sys

# Get conditions from command-line arguments
condition = sys.argv[1]  # This will take all arguments after the script name
site = sys.argv[2]
# input the index of the null map and generate random seed from that
ranseed = sys.argv[3]
random.seed(ranseed)
#condition = 'AD'
# Conditional assignment to use fdifferent mask
if condition == 'AD':
    diaggroup = 'AD'
else:
    diaggroup = 'psy'
# only compute dismat when changing the matrix input

# from brainsmash.mapgen.memmap import txt2memmap
# dist_mat_fin = "LeftDenseGeodesicDistmat_midthickness.txt"  # input text file
# output_dir = "."  # directory to which output binaries are written
# mask = "LeftDense32k_mask.txt"
# output_files = txt2memmap(dist_mat_fin, output_dir, maskfile=mask, delimiter=' ')
distance_files = {'D': '/scratch2/kg98/trangc/VBM/data/nulltest/volume_'+ diaggroup +'_index/distmat.npy','index': '/scratch2/kg98/trangc/VBM/data/nulltest/volume_'+ diaggroup +'_index/index.npy'}

from brainsmash.mapgen.eval import sampled_fit
import nibabel as nib
import numpy as np
import os

# These are three of the key parameters affecting the variogram fit
kwargs = {'ns': 500,
          'knn': 1500,
          'kernel': 'gaussian',
          'pv': 60,
          'n_jobs': 12,
          'resample': True
          }

## Running this command will generate a matplotlib figure
#sampled_fit(brain_map, output_files['D'], output_files['index'], nsurr=10, **kwargs)

now = datetime.datetime.now()
random.seed(int(now.strftime("%d%H%M%S")))
from brainsmash.mapgen.sampled import Sampled


# smoothing kernel
smoothkernel = '6'


# Iterate through the array using a for loop

# Specify the directory path (replace with your actual path)
directory_path = '/projects/kg98/trangc/VBM/data/derivatives/s' + smoothkernel + 'COMBAT/' + condition

full_path = os.path.join(directory_path, site)  # Get the full path
if os.path.isdir(full_path):  # Check if it is a directory
    # Step 1: Load the NIfTI file
    nii_file = full_path + '/' + 'spmT_0001_binary.nii'  # Replace with your file path
    img = nib.load(nii_file)
    data = img.get_fdata()
    mask_file = '/projects/kg98/trangc/VBM/data/derivatives/s' + smoothkernel + 'COMBAT/mask_' + diaggroup + '/mask.nii'  # Replace with your file path
    mask = nib.load(mask_file)
    maskdata = mask.get_fdata()

    #

    # Step 2: mask the data
    maskedData = data[maskdata>0]

    # Step 3: Save the data to a text file
    brain_map = full_path + '/' + 'spmT_0001_binary.txt'
    np.savetxt(brain_map, maskedData, fmt='%.6f')  # Save with 6 decimal precision

    gen = Sampled(x=brain_map, D=distance_files['D'], index=distance_files['index'], **kwargs)
    output_folder = '/scratch2/kg98/trangc/VBM/data/nulltest/surrogateVBM_binary/s' + smoothkernel + 'COMBAT/' + condition + '/' + site
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)
    #for index in range(1, nSur):
    surrogate_maps = gen(n=1)
    # fill in the surrogate map values
    null_map = np.zeros_like(maskdata, dtype=float)
    null_map[maskdata > 0] = surrogate_maps

    # Combine output with s132_img header and save
    null_img = nib.Nifti1Image(null_map, mask.affine, mask.header)
    output_filename = output_folder + '/' + 'spmT_0001_binary_surrogate_' + ranseed + '.nii.gz'
    nib.save(null_img, output_filename)
    #
    #np.savetxt(output_filename, surrogate_maps)


