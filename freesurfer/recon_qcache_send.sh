#!/bin/env bash

DATASET=SRPBS
SUBJLIST=/home/trangc/kg98/trangc/VBM/data/${DATASET}/sub_to_recon.txt
#ses=ses-1


for sub in `cat ${SUBJLIST}`
do

	export sub=$sub
	export DATASET=$DATASET

	sbatch --job-name=fs_qcache_${DATASET} fs_qcache.sh         

done
