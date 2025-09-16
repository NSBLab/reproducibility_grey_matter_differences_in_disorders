#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import numpy as np
import pandas as pd
import nibabel as nib
import pandas as pd

# Directories
inDir = '/projects/kg98/trangc/VBM/data/'
smoothKernel = '12'
outDir = inDir + 'derivatives/s' + smoothKernel

#datasets = ["YMDD","Modul_vent"]
datasets = ["ABIDEI","ABIDEII","Advan_inno","Atypical","BrainGluSchi","BSNIP","BSNIP2","COBRE","HCP","PARDIP","SRPBS",
            "UCLA","YMDD","Modul_vent","Inhi_dys","Study_neura","MCIC","STAGES","speech"]

for d, dataset in enumerate(datasets):

    # Load in metadata
    metadataFilename = inDir + dataset + '/' + dataset + '_dems.csv';
    metadata_dataset = pd.read_table(metadataFilename, delimiter=',');

    if d == 0:
        metadata = metadata_dataset
    else:
        metadata = pd.concat([metadata, metadata_dataset])

metadata = metadata.reset_index()

# Give unique site id to each site
sites = np.unique(metadata['site_string'])

for s, site in enumerate(sites):
    idx = np.where(metadata['site_string'] == site)[0]
    metadata['site'].iloc[idx] = s

# Save metadata
metadata_outFilename = outDir + '/metadata.csv'
metadata.to_csv(metadata_outFilename, index=False)
