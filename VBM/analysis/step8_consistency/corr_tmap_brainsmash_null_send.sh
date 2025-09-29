#!/bin/bash
export iCOMBAT=1
export smoothKernel=6
nNull=100
for iNull in $(seq 1 $nNull); do
export iNull=$iNull

	
		sbatch --job-name=corr_zmap_brainsmash_null_${iNull} corr_tmap_brainsmash_null_job.sh

		#sh corr_tmap_brainsmash_null_job.sh
	#fi 
done



