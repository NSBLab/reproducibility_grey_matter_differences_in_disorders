#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -z "$CONFIG_FILE" ]; then
    REPO_ROOT=$(cd "$SCRIPT_DIR/../../.." && pwd)
    CONFIG_FILE="$REPO_ROOT/config_hpc.json"
fi
export CONFIG_FILE

export iCOMBAT=1
export smoothKernel=6
nNull=100
for iNull in $(seq 1 $nNull); do
export iNull=$iNull

	
		sbatch --job-name=corr_zmap_brainsmash_null_${iNull} "$SCRIPT_DIR/corr_tmap_brainsmash_null_job.sh"

		#sh "$SCRIPT_DIR/corr_tmap_brainsmash_null_job.sh"
	#fi 
done



