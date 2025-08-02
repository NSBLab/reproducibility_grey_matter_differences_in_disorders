#!/bin/bash
sampleSizeList=(16) #(10    16    25    40    63   100) #   158 210) # (10    16    25    40    63   100  158  251 398) # adding the max number that each diagnosis can have, corresponding to the diaglist (210, 136, 527, 111, 231, 327)  

export nMode=200
export diag=6

for sampleSize in ${sampleSizeList[@]}
do
	export sampleSize=$sampleSize

		#sbatch --job-name=corMBM_${sampleSize} corr_MBM_subdivide_2sitegroup_samesize_job.sh
	    sh corr_MBM_subdivide_2sitegroup_samesize_job.sh
				
done


