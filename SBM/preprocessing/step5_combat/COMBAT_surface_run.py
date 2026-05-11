#!/usr/bin/env python3
"""Run neuroCombat harmonization on smoothed surface thickness data."""

from neuroCombat import neuroCombat
import pandas as pd
import numpy as np
import sys
import os

smooth_kernel = sys.argv[1]
group         = sys.argv[2]
hemi          = sys.argv[3]
data_root     = sys.argv[4]

out_dir = os.path.join(data_root, 'derivatives', 'freesurfer', f's{smooth_kernel}COMBAT')

metadata_file = os.path.join(data_root, f'metadataSBM_{group}.csv')
metadata = pd.read_csv(metadata_file)

anat_file = os.path.join(out_dir, f'{hemi}_thickness_s{smooth_kernel}_{group}.txt')
data = np.loadtxt(anat_file)  # vertices x subjects

covars = pd.DataFrame({
    'batch':     metadata['site'],
    'sex':       metadata['sex'],
    'age':       metadata['age'],
    'diagnosis': metadata['diagnosis'],
})

data_combat = neuroCombat(
    dat=data,
    covars=covars,
    batch_col='batch',
    categorical_cols=['sex', 'diagnosis'],
)["data"]

out_file = os.path.join(out_dir, f'{hemi}_thickness_s{smooth_kernel}_{group}_combat.txt')
np.savetxt(out_file, data_combat)
print(f'Saved: {out_file}')
