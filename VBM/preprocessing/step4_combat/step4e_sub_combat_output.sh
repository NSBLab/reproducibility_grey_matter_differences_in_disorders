#!/bin/bash
#SBATCH --job-name=step4e_combat_output
#SBATCH --account=kg98
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --time=4:00:00
#SBATCH --export=ALL
#SBATCH --mem=64000

# Worker: writes COMBAT-harmonized NIfTIs for one combat group (invoked by step4e_combat_output.sh)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="${CONFIG_FILE:?Set CONFIG_FILE}"
GROUP="${GROUP:?Set GROUP}"

HPC_ENABLED_RAW="${HPC_ENABLED:-0}"
case "$(echo "$HPC_ENABLED_RAW" | tr '[:upper:]' '[:lower:]')" in 1|true) HPC_ENABLED="1" ;; *) HPC_ENABLED="0" ;; esac

echo "=== STEP4E COMBAT OUTPUT: group=${GROUP} ==="

if [[ "$HPC_ENABLED" == "1" ]]; then
    module load matlab
fi

matlab -nodisplay -r "addpath(genpath('$SCRIPT_DIR')); step4e_combat_output('$CONFIG_FILE', '$GROUP'); quit;"
