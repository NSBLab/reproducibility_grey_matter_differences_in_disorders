# -*- coding: utf-8 -*-
"""
Generate one BrainSMASH surrogate T-map for a diagnosis/site.
Paths are read from environment (set by step6b / vol_dense_gen_job.sh).

Usage (env):
  DATA_ROOT, smoothKernel, harmonize, maskDiag, NULL_ROOT
  argv: diag site ranseed
"""

import datetime
import os
import random
import sys

import nibabel as nib
import numpy as np
from brainsmash.mapgen.sampled import Sampled


condition = sys.argv[1]
site = sys.argv[2]
ranseed = sys.argv[3]
random.seed(ranseed)

data_root = os.environ.get('DATA_ROOT')
smooth_kernel = os.environ.get('smoothKernel', '6')
harmonize = int(os.environ.get('harmonize', '1'))
mask_diag_cfg = os.environ.get('maskDiag', 'psy')
null_root = os.environ.get('NULL_ROOT') or os.path.join(data_root, 'nulltest')

if not data_root:
    raise SystemExit('DATA_ROOT environment variable not set')

diaggroup = 'AD' if condition == 'AD' else mask_diag_cfg

deriv_tag = f's{smooth_kernel}COMBAT' if harmonize == 1 else f's{smooth_kernel}'
distance_dir = os.path.join(null_root, f'volume_{diaggroup}_index')
distance_files = {
    'D': os.path.join(distance_dir, 'distmat.npy'),
    'index': os.path.join(distance_dir, 'index.npy'),
}

kwargs = {
    'ns': 500,
    'knn': 1500,
    'kernel': 'gaussian',
    'pv': 60,
    'n_jobs': 12,
}

now = datetime.datetime.now()
random.seed(int(now.strftime('%d%H%M%S')))

directory_path = os.path.join(data_root, 'derivatives', deriv_tag, condition)
full_path = os.path.join(directory_path, site)

if not os.path.isdir(full_path):
    raise SystemExit(f'Not a directory: {full_path}')

nii_file = os.path.join(full_path, 'spmT_0001.nii')
img = nib.load(nii_file)
data = img.get_fdata()

mask_file = os.path.join(data_root, 'derivatives', f's{smooth_kernel}', f'mask_{diaggroup}', 'mask.nii')
if not os.path.isfile(mask_file):
    mask_file = os.path.join(data_root, 'derivatives', deriv_tag, f'mask_{diaggroup}', 'mask.nii')
mask = nib.load(mask_file)
maskdata = mask.get_fdata()

masked_data = data[maskdata > 0]
brain_map = os.path.join(full_path, 'spmT_0001.txt')
np.savetxt(brain_map, masked_data, fmt='%.6f')

gen = Sampled(x=brain_map, D=distance_files['D'], index=distance_files['index'], **kwargs)
output_folder = os.path.join(null_root, 'surrogateVBM', deriv_tag, condition, site)
os.makedirs(output_folder, exist_ok=True)

surrogate_maps = gen(n=1)
null_map = np.zeros_like(maskdata, dtype=float)
null_map[maskdata > 0] = surrogate_maps

null_img = nib.Nifti1Image(null_map, mask.affine, mask.header)
output_filename = os.path.join(output_folder, f'spmT_0001_surrogate_{ranseed}.nii.gz')
nib.save(null_img, output_filename)
print(f'Saved: {output_filename}')
