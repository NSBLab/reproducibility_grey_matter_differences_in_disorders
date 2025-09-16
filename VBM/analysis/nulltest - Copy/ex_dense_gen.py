# -*- coding: utf-8 -*-
"""
Created on Tue Feb 22 15:36:20 2022

@author: tcao0011
"""
import numpy as np
import random
import datetime
# only compute dismat when changing the matrix input

# from brainsmash.mapgen.memmap import txt2memmap
# dist_mat_fin = "LeftDenseGeodesicDistmat_midthickness.txt"  # input text file
# output_dir = "."  # directory to which output binaries are written
# mask = "LeftDense32k_mask.txt"
# output_files = txt2memmap(dist_mat_fin, output_dir, maskfile=mask, delimiter=' ')
distance_files = {'distmat': 'distmat.npy','index': 'index.npy'}

now = datetime.datetime.now()
random.seed(int(now.strftime("%d%H%M%S")))
from brainsmash.mapgen.sampled import Sampled
brain_map_file = "P_masked_lh.thickness.fsLR_32k.txt"  # use absolute paths if necessary!
dist_mat_mmap = output_files['distmat']
index_mmap = output_files['index']
sampled = Sampled(brain_map_file, dist_mat_mmap, index_mmap,resample=True)
surrogates = sampled(n=10)
#for i in range(2,10,1):
    # surrogates = sampled(n=1000)
    # output_filename = "dense_left_gen_P_"+str(i)+".txt"
    # np.savetxt(output_filename, surrogates)
sampled_fit(x, D, index, nsurr=10, return_data=False, **params)
generator = Sampled(x=x, D=D, index=index, **params)
emp_var_samples = np.empty((nsurr, generator.nh))
    u0_samples = np.empty((nsurr, generator.nh))
    for i in range(nsurr):
        idx = generator.sample()  # Randomly sample a subset of brain areas
        v = generator.compute_variogram(generator.x, idx)
        u = generator.D[idx, :]
        umax = np.percentile(u, generator.pv)
        uidx = np.where(u < umax)
        emp_var_i, u0i = generator.smooth_variogram(
            u=u[uidx], v=v[uidx], return_h=True)
        emp_var_samples[i], u0_samples[i] = emp_var_i, u0i
u0 = u0_samples.mean(axis=0)
emp_var = emp_var_samples.mean(axis=0)