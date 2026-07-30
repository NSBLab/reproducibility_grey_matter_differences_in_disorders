#!/bin/bash
#SBATCH --time=1-1:00:00
#SBATCH --job-name=resample
#SBATCH --account=kg98
#SBATCH --cpus-per-task=1
#SBATCH --mem=60000

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -z "$CONFIG_FILE" ]; then
    REPO_ROOT=$(cd "$SCRIPT_DIR/../../.." && pwd)
    CONFIG_FILE="$REPO_ROOT/config_hpc.json"
fi
DATA_ROOT=$(jq -r '.data_directories.dataset_root' "$CONFIG_FILE")

export smoothKernel=10
export measure=thickness
export measureShort=thick
export hemis=lh
diagList=(6) #(2 3 4 5 6 7)
export control=1

nSubdivide=100
groupsizelist=(10    16    25    40    63   100   158  231) # 251   398   527) 
# adding the max number that each diagnosis can have, corresponding to the diaglist (210, 136, 527, 111, 231, 327) 
#nSample=100

groupList=(1 2)

module load matlab/r2023b
export outdir="$DATA_ROOT/derivatives/freesurfer"
for diag in ${diagList[@]}
do
	export diag=$diag

    for groupsize in ${groupsizelist[@]}
	do
	export groupsize=$groupsize
	export dividemode=splitsite_samesize_$groupsize


		for iSubdivide in $(seq 1 $nSubdivide); do
			export iSubdivide=$iSubdivide
			export randomSubdivide=$RANDOM
			echo $groupsize
			matlab -nodisplay -r "addpath('$SCRIPT_DIR'); run_divide_2sitegroup_splitsite_samesize_func('$CONFIG_FILE',$diag,$smoothKernel,'$hemis',$groupsize,$iSubdivide,$randomSubdivide); quit"
			
			 
		done
	done
done
