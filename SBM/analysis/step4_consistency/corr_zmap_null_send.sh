#!/bin/bash
export iCOMBAT=1
export hemi=lh
export smoothKernel=10

nNull=1000
for iNull in $(seq 1000 $nNull); do
export iNull=$iNull
echo $iNull
	
		sbatch --job-name=corr_zmap_null_${iNull} corr_zmap_null_job.sh

		#sh corr_zmap_null_job.sh
	#fi 
done



