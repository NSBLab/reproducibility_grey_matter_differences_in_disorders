#!/bin/bash

export ns=500
#export knn=2000
export pv=70

for knn in $(seq 1000 1000 2000); do
	export knn=${knn}
	sbatch --job-name=vol_dense${ns}_${knn}_${pv} vol_dense_gen_test_job.sh
	#sh vol_dense_gen_test_job.sh
done


