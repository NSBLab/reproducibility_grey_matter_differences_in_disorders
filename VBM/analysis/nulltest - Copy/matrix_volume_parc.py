# -*- coding: utf-8 -*-
"""
Created on Thu Mar 31 16:08:31 2022

@author: tcao0011
"""

from brainsmash.workbench.geo import cortex
import os
from brainsmash.workbench.geo import volume





# Specify the path to add (replace with your actual path)
new_path = '/projects/kg98/trangc/library/workbench/bin_linux64'

# Add the new path to the existing PATH
os.environ['PATH'] += os.pathsep + new_path

# Verify that the path has been added
print("Updated PATH:", os.environ['PATH'])

for value in [200, 300, 400, 500, 600, 700, 800, 900, 1000]:
    output_dir = f'/scratch2/kg98/trangc/VBM/data/nulltest/volume_parc_{value}'  # directory to which output binaries are written
    os.makedirs(output_dir, exist_ok=True)  # Create folder if not exists
    coord_file = (f'/projects/kg98/trangc/VBM/code/nulltest/pythonProject/'
              f'parc_Coordinate_Buckner-whole_1mm_Tian_Subcortex_S1_3T_2009cAsym_Schaefer2018_{value}Parcels_7Networks_order_CAT12MNI.txt')
    filenames = volume(coord_file, output_dir)

