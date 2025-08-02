#!/bin/env bash

DATASET=Inhi_dys
SUBJLIST=/home/trangc/kg98/trangc/VBM/data/${DATASET}/sub_to_recon.txt
#ses=ses-1


for subj in `cat ${SUBJLIST}`
do

	export sub=${subj:0:7}
	export DATASET=$DATASET
	export ses=${subj:7:5}

	sbatch --job-name=fs_${DATASET} fs_recon.sh         

done
