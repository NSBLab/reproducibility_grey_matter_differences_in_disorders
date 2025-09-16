diagList=(2 3 4 5 6 7)
groupsizelist=(10    16    25    40    63   100   158   251   398   631)

for diag in ${diagList[@]}
do
	export diag=$diag

	for groupsize in ${groupsizelist[@]}
	do
	export groupsize=$groupsize
	export dividemode=splitsite_samesize_$groupsize
 
	sbatch --job-name=corr_${diag}_${dividemode} corr_map_subdivide_aparc_batch.sh
	#sh corr_map_subdivide_aparc_batch.sh
		
	done
done
