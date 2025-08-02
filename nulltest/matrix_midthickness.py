# -*- coding: utf-8 -*-
"""
Created on Thu Mar 31 16:08:31 2022

@author: tcao0011
"""

from brainsmash.workbench.geo import cortex
import os
from brainsmash.mapgen.memmap import txt2memmap
import numpy as np
# Specify the path to add (replace with your actual path)
new_path = '/projects/kg98/trangc/library/workbench/bin_linux64'

# Add the new path to the existing PATH
os.environ['PATH'] += os.pathsep + new_path

# Verify that the path has been added
print("Updated PATH:", os.environ['PATH'])

surface = "/projects/kg98/trangc/atlases/standard_mesh_atlases/resample_fsaverage/lh.fsaverage_164k.midthickness.surf.gii"
cortex(surface=surface, outfile="/scratch2/kg98/trangc/VBM/data/nulltest/LeftDenseGeodesicDistmat_midthickness_fsaverage_164k.txt", euclid=False)

dist_mat_fin = "/scratch2/kg98/trangc/VBM/data/nulltest/LeftDenseGeodesicDistmat_midthickness_fsaverage_164k.txt"  # input text file
output_dir = "/scratch2/kg98/trangc/VBM/data/nulltest"  # directory to which output binaries are written
mask = "/projects/kg98/trangc/atlases/Human_standard_surface/fsaverage_164k_cortex-lh_mask.txt"

# Read the mask file
with open(mask, "r") as file:
    mask = file.read().splitlines()

# Reverse the mask values
reversed_mask = ["1" if value == "0" else "0" for value in mask]

# Write the reversed mask to a new file
reversemaskfile = "/projects/kg98/trangc/atlases/Human_standard_surface/fsaverage_164k_cortex-lh_reversed_mask.txt"
with open(reversemaskfile, "w") as file:
    file.write("\n".join(reversed_mask))

print("Reversed mask saved to 'reversed_mask.txt'")

output_files = txt2memmap(dist_mat_fin, output_dir, maskfile=reversemaskfile, delimiter=' ')