#!/bin/bash

export nResample=100
export iCOMBAT=1
export hemi=lh
export smoothKernel=10
export nTrap=10
for inJob in $(seq 1 $nResample); do
		export inJob=${inJob}
		sbatch --job-name=nulltest_${inJob} nulltest_job.sh
		#sh nulltest_job.sh


done


