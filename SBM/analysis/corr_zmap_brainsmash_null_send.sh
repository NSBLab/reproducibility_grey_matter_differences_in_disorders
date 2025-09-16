#!/bin/bash
export iCOMBAT=1
export smoothKernel=10
nNull=1000
hemi=lh
for iNull in $(seq 414 $nNull); do
export iNull=$iNull

	
		sbatch --job-name=corr_zmap_null_${iNull} corr_zmap_brainsmash_null_job.sh

		#sh corr_zmap_null_job.sh
	#fi 
done



