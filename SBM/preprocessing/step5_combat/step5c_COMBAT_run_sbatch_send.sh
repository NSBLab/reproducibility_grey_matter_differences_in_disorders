#!/bin/bash
# Dispatcher: reads combat groups from config, submits COMBAT_run_sbatch.sh
# per group and hemisphere.

export SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BATCH_SCRIPT="${SCRIPT_DIR}/COMBAT_run_sbatch.sh"

if [ -z "$CONFIG_FILE" ]; then
    REPO_ROOT=$(cd "$SCRIPT_DIR/../../.." && pwd)
    if [ -f "$REPO_ROOT/config_hpc.json" ]; then
        CONFIG_FILE="$REPO_ROOT/config_hpc.json"
    else
        echo "Error: CONFIG_FILE not set and config_hpc.json not found."
        echo "Checked: $REPO_ROOT/config_hpc.json"
        exit 1
    fi
fi

command -v jq >/dev/null || { echo "Need jq"; exit 1; }
[[ -f "$BATCH_SCRIPT" ]] || { echo "Error: Missing $BATCH_SCRIPT"; exit 1; }

HPC_ENABLED_RAW=$(jq -r '.execution_mode.hpc_enabled // false' "$CONFIG_FILE")
case "$(echo "$HPC_ENABLED_RAW" | tr '[:upper:]' '[:lower:]')" in 1|true) HPC_ENABLED="1" ;; *) HPC_ENABLED="0" ;; esac

COMBAT_GROUPS=$(jq -r '[.datasets | to_entries[] | select(.value.enabled == true) | .value.combat_group] | unique[]' "$CONFIG_FILE")
[[ -z "$COMBAT_GROUPS" ]] && { echo "No combat groups found in enabled datasets."; exit 1; }

echo "Using CONFIG_FILE: $CONFIG_FILE"
echo "Combat groups: $COMBAT_GROUPS"

for GROUP in $COMBAT_GROUPS; do
    for HEMI in lh rh; do
        echo "=== ${GROUP} ${HEMI} ==="
        export CONFIG_FILE GROUP HEMI

        if [[ "$HPC_ENABLED" == "1" ]]; then
            sbatch --job-name="combat_${GROUP}_${HEMI}" "$BATCH_SCRIPT"
        else
            bash "$BATCH_SCRIPT"
        fi
    done
done
