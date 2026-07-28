#!/bin/bash
#SBATCH --job-name=step5b_combat_surface_input
#SBATCH --account=kg98
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --time=6:00:00
#SBATCH --export=ALL
#SBATCH --mem=64000

# Worker: prepares COMBAT surface input for one combat group (invoked by step5b_combat_surface_input.sh)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="${CONFIG_FILE:?Set CONFIG_FILE}"
GROUP="${GROUP:?Set GROUP}"

HPC_ENABLED_RAW="${HPC_ENABLED:-0}"
case "$(echo "$HPC_ENABLED_RAW" | tr '[:upper:]' '[:lower:]')" in 1|true) HPC_ENABLED="1" ;; *) HPC_ENABLED="0" ;; esac

echo "=== STEP5B COMBAT SURFACE INPUT: group=${GROUP} ==="

if [[ "$HPC_ENABLED" == "1" ]]; then

    module load matlab
fi

matlab -nodisplay -r "addpath(genpath('$SCRIPT_DIR')); step5b_sub_combat_surface_input('$CONFIG_FILE', '$GROUP'); quit;"
