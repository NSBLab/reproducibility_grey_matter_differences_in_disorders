# -*- coding: utf-8 -*-
"""
Build BrainSMASH volume distance matrix from the VBM group mask.
Reads paths from a pipeline JSON config (or CLI overrides).

Usage:
  python step6a_matrix_volume.py --config ../../../config_hpc.json
  python step6a_matrix_volume.py --data-root /path/to/data --mask-diag psy --smooth-kernel 6
"""

from brainsmash.workbench.geo import volume
import argparse
import json
import os
import nibabel as nib
import numpy as np


def load_config(config_file):
    with open(config_file, 'r', encoding='utf-8') as f:
        return json.load(f)


def main():
    parser = argparse.ArgumentParser(description='Build BrainSMASH volume distance matrix')
    parser.add_argument('--config', default=None, help='Path to pipeline config JSON')
    parser.add_argument('--data-root', default=None)
    parser.add_argument('--mask-diag', default=None)
    parser.add_argument('--smooth-kernel', type=int, default=None)
    parser.add_argument('--harmonize', type=int, default=None)
    args = parser.parse_args()

    data_root = args.data_root
    mask_diag = args.mask_diag
    smooth_kernel = args.smooth_kernel
    harmonize = args.harmonize

    if args.config:
        cfg = load_config(args.config)
        data_root = data_root or cfg['data_directories']['dataset_root']
        mask_diag = mask_diag or cfg['analysis_settings'].get('mask_diagnostic_group', 'psy')
        smooth_kernel = smooth_kernel if smooth_kernel is not None else int(
            cfg['analysis_settings'].get('vbm_smoothing_kernel', 6))
        harmonize = harmonize if harmonize is not None else int(
            cfg['analysis_settings'].get('harmonize', 1))

    if not data_root or mask_diag is None or smooth_kernel is None:
        raise SystemExit('Need --config or --data-root/--mask-diag/--smooth-kernel')

    if harmonize is None:
        harmonize = 1

    # Mask is built in step4 under s{K}/mask_{diag} (not COMBAT)
    mask_file = os.path.join(
        data_root, 'derivatives', f's{smooth_kernel}', f'mask_{mask_diag}', 'mask.nii')
    if not os.path.isfile(mask_file):
        # fallback to COMBAT mask location used in older runs
        mask_file_combat = os.path.join(
            data_root, 'derivatives', f's{smooth_kernel}COMBAT', f'mask_{mask_diag}', 'mask.nii')
        if os.path.isfile(mask_file_combat):
            mask_file = mask_file_combat
        else:
            raise FileNotFoundError(f'Mask not found: {mask_file}')

    output_dir = os.path.join(data_root, 'nulltest', f'volume_{mask_diag}_index')
    os.makedirs(output_dir, exist_ok=True)
    coord_file = os.path.join(output_dir, f'mnimaskedtemplate_{mask_diag}_index.txt')

    print(f'Data root:     {data_root}')
    print(f'Mask:          {mask_file}')
    print(f'Output dir:    {output_dir}')
    print(f'Coord file:    {coord_file}')

    atlas = nib.load(mask_file).get_fdata()
    coords = np.column_stack(np.where(atlas > 0))
    np.savetxt(coord_file, coords, fmt='%d')
    filenames = volume(coord_file, output_dir)
    print(f'Distance matrix written: {filenames}')


if __name__ == '__main__':
    main()
