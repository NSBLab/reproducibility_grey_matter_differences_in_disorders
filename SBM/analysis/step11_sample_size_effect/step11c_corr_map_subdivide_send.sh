#!/bin/bash

diagList=(3) #(2 3 4 5 6)
export smoothKernel=10


groupsizelist=(25    40    63   100  136) #(10    16    25    40    63   100   158  251 398) # adding the max number that each diagnosis can have, corresponding to the diaglist (210, 136, 527, 111, 231, 327)  

for diag in ${diagList[@]}
do
	export diag=$diag

	for groupsize in ${groupsizelist[@]}
	do
	export groupsize=$groupsize
	export dividemode=splitsite_samesize_$groupsize
 
	#sbatch --job-name=corr_${diag}_${groupsize} corr_map_subdivide_batch.sh
		sh corr_map_subdivide_batch.sh
	done
done
