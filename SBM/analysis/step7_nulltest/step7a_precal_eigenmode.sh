#!/bin/bash
# Step7a: precompute eigenmodes used by eigentrapping nulltest (step7b).

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ -z "$CONFIG_FILE" ]; then
    REPO_ROOT=$(cd "$SCRIPT_DIR/../../.." && pwd)
    if [ -f "$REPO_ROOT/config_hpc.json" ]; then
        CONFIG_FILE="$REPO_ROOT/config_hpc.json"
    else
        echo "Error: CONFIG_FILE not set and config_hpc.json not found at $REPO_ROOT"
        exit 1
    fi
fi

command -v jq >/dev/null 2>&1 || { echo "Error: jq is required."; exit 1; }

HPC_ENABLED_RAW=$(jq -r '.execution_mode.hpc_enabled // false' "$CONFIG_FILE")
case "$(echo "$HPC_ENABLED_RAW" | tr '[:upper:]' '[:lower:]')" in
    1|true) HPC_ENABLED="1" ;;
    *) HPC_ENABLED="0" ;;
esac

# Default both hemispheres; override with: hemi=lh bash step7a_precal_eigenmode.sh
hemis="${hemi:-lh rh}"

echo "=== STEP7A: PRECAL EIGENMODE ==="
echo "CONFIG_FILE: $CONFIG_FILE"
echo "hemis:       $hemis"
echo "HPC_ENABLED: $HPC_ENABLED"

if [ "$HPC_ENABLED" = "1" ]; then
    module load matlab/r2023b
fi

for h in $hemis; do
    echo "Computing eigenmodes for hemi=$h"
    matlab -nodisplay -r "addpath('$SCRIPT_DIR'); step7a_precal_eigenmode('$CONFIG_FILE', '$h'); quit;"
    if [ $? -ne 0 ]; then
        echo "Error: step7a failed for hemi=$h"
        exit 1
    fi
done

echo "=== STEP7A DONE ==="
