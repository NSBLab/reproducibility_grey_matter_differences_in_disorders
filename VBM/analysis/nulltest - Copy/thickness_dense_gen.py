# -*- coding: utf-8 -*-
"""
Created on Tue Feb 22 15:36:20 2022

@author: tcao0011
"""
import numpy as np
import random
import datetime
import nibabel as nib
import os
import re
import sys
# Get conditions from command-line arguments
dataset = sys.argv[1]  # This will take all arguments after the script name
qdec = sys.argv[2]
smoothkernel = sys.argv[3]
#dataset='ABIDEI'
# only compute dismat when changing the matrix input

distance_files = {'distmat': '/scratch2/kg98/trangc/VBM/data/nulltest/distmat.npy','index': '/scratch2/kg98/trangc/VBM/data/nulltest/index.npy'}
now = datetime.datetime.now()
random.seed(int(now.strftime("%d%H%M%S")))
from brainsmash.mapgen.sampled import Sampled
# smoothing kernel
#smoothkernel = '6'
# number of surrogate
nSur = 1000
# Iterate through the array using a for loop

# Specify the directory path (replace with your actual path)
dataDir = '/projects/kg98/trangc/VBM/data/' + dataset + '/derivatives/freesurfer/qdec'
# List all directories in the folder that end with '_sex_age_combat'
#qdecs = [f for f in os.listdir(dataDir) if f.endswith('_sex_age_combat') and os.path.isdir(os.path.join(dataDir, f))]

# Loop through the matching folders
#for qdec in qdecs:
match = re.search(r'_(.*?)_.*smooth', qdec)
site = match.group(1)
statDir = os.path.join(dataDir, qdec)  # Get the full path
contrast = [f for f in os.listdir(statDir) if
         f.startswith('lh-Diff') and os.path.isdir(os.path.join(statDir, f))]
contrastDir = os.path.join(statDir,contrast[0])  # Get the full path
# Step 1: Load the MGH file
mgh_file = os.path.join(contrastDir, 'z.mgh')  # Replace with your file path
img = nib.load(mgh_file)
data = np.squeeze(img.get_fdata(), axis=None)
mask_file = "/projects/kg98/trangc/atlases/Human_standard_surface/fsaverage_164k_cortex-lh_mask.txt"
maskdata = np.loadtxt(mask_file)


# Step 2: mask the data
maskedData = data[maskdata > 0]

# Step 3: Save the data to a text file
brain_map = contrastDir + '/' + 'z.txt'
np.savetxt(brain_map, maskedData, fmt='%.6f')  # Save with 6 decimal precision
dist_mat_mmap = distance_files['distmat']
index_mmap = distance_files['index']
sampled = Sampled(brain_map, dist_mat_mmap, index_mmap, resample=True)
surrogates = sampled(n=nSur)
output_folder = '/scratch2/kg98/trangc/VBM/data/nulltest/surrogateSBM/s' + smoothkernel + 'COMBAT/diag' + qdec[0] + '/' + site
if not os.path.exists(output_folder):
    os.makedirs(output_folder)
output_filename = output_folder + '/' + 'z_surrogate.txt'
np.savetxt(output_filename, surrogates)