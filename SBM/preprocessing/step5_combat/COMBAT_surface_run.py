#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Dec 10 15:47:26 2021

@author: asegal
"""

from neuroCombat import neuroCombat
import nibabel as nib
import pandas as pd
import numpy as np
import sys

inDir = '/projects/kg98/trangc/VBM/data/'
smoothKernel = sys.argv[1] 
maskDiag = sys.argv[2] 
hemi = sys.argv[3] 
outDir = inDir + 'derivatives/freesurfer/s' + smoothKernel + 'COMBAT'

metadata_filename = inDir + 'metadataSBM_' + maskDiag + '.csv'
metadata = pd.read_table(metadata_filename, delimiter=',')

anat_filename = outDir + '/' + hemi + '_thickness_s' + smoothKernel + '_' + maskDiag + '.txt'
data = np.loadtxt(anat_filename, delimiter=',') # rows (gmv) columns (subs)

sites = metadata['site']
sex = metadata['sex']
age = metadata['age']
diagnosis = metadata['diagnosis']

# Specifying the batch (scanner variable) as well as a biological covariate to preserve:
covars = {'batch':sites,
          'sex':sex,
          'age':age,
          'diagnosis':diagnosis} 
covars = pd.DataFrame(covars)  

# To specify names of the variables that are categorical:
categorical_cols = ['sex','diagnosis']

# To specify the name of the variable that encodes for the scanner/batch covariate:
batch_col = 'batch'

#Harmonization step:
data_combat = neuroCombat(dat=data,
    covars=covars,
    batch_col=batch_col,
    categorical_cols=categorical_cols)["data"]

anat_combat_filename = outDir + '/' + hemi + '_thickness_s' + smoothKernel + '_' + maskDiag + '_combat.txt'
np.savetxt(anat_combat_filename,data_combat) # rows (gmv) columns (subs)


