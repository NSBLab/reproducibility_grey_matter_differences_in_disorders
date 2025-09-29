# -*- coding: utf-8 -*-
"""
Created on Thu Mar 31 16:08:31 2022

@author: tcao0011
"""

from brainsmash.workbench.geo import cortex
import os
from brainsmash.workbench.geo import volume
import nibabel as nib
import numpy as np


diag = "psy"


# Specify the path to add (replace with your actual path)
#new_path = '/projects/kg98/trangc/library/workbench/bin_linux64'

# Add the new path to the existing PATH
#os.environ['PATH'] += os.pathsep + new_path

# Verify that the path has been added
#print("Updated PATH:", os.environ['PATH'])


output_dir = "/scratch2/kg98/trangc/VBM/data/nulltest/volume_" + diag +'_index'# directory to which output binaries are written
if not os.path.exists(output_dir):
    os.mkdir(output_dir)
coord_file = "/projects/kg98/trangc/VBM/code/nulltest/pythonProject/mnimaskedtemplate_" + diag + "_index.txt"

# Load atlas
s132_img = nib.load('/projects/kg98/trangc/VBM/data/derivatives/s6COMBAT/mask_' + diag +'/mask.nii')
atlas = s132_img.get_fdata()

coords = np.column_stack(np.where(atlas > 0))
np.savetxt(coord_file, coords, fmt='%d')

filenames = volume(coord_file, output_dir)

