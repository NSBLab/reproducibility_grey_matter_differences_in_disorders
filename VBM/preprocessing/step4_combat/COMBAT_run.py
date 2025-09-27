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
print("Hello")
#smoothKernel = '8'
#maskDiag = 'psy'
smoothKernel = sys.argv[1]
maskDiag = sys.argv[2]
outDir = inDir + 'derivatives/s' + smoothKernel + 'COMBAT'


metadata_filename = inDir + 'metadataVBM_' + maskDiag + '.csv'
metadata = pd.read_table(metadata_filename, delimiter=',')

anat_filename = outDir + '/mask_' + maskDiag + '/anat_s' + smoothKernel + 'mwp1_T1w_masked.txt'
data = np.loadtxt(anat_filename, delimiter=' ') # rows (gmv) columns (subs)

# load mask
mask_filename = outDir + '/mask_' + maskDiag + '/mask.nii'
maskNifti = nib.load(mask_filename) 
maskData = maskNifti.get_fdata() 
maskNifti_dims = np.shape(maskData)
maskData_1d = maskData.reshape(-1)

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

anat_combat_filename = outDir + '/mask_' + maskDiag + '/anat_s' + smoothKernel + 'mwp1_T1w_masked_combat.txt'
np.savetxt(anat_combat_filename, data_combat) # rows (gmv) columns (subs)
