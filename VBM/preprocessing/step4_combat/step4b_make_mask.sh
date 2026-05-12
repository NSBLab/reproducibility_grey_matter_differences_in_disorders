#!/bin/bash
# Dispatcher: reads combat groups from config, submits step4b_sub_make_mask.sh per group

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SUB_SCRIPT="${SCRIPT_DIR}/step4b_sub_make_mask.sh"

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
[[ -f "$SUB_SCRIPT" ]] || { echo "Error: Missing $SUB_SCRIPT"; exit 1; }

HPC_ENABLED_RAW=$(jq -r '.execution_mode.hpc_enabled // false' "$CONFIG_FILE")
case "$(echo "$HPC_ENABLED_RAW" | tr '[:upper:]' '[:lower:]')" in 1|true) HPC_ENABLED="1" ;; *) HPC_ENABLED="0" ;; esac

COMBAT_GROUPS=$(jq -r '[.datasets | to_entries[] | select(.value.enabled == true) | .value.combat_group] | unique[]' "$CONFIG_FILE")
[[ -z "$COMBAT_GROUPS" ]] && { echo "No combat groups found in enabled datasets."; exit 1; }

echo "Using CONFIG_FILE: $CONFIG_FILE"
echo "Combat groups: $COMBAT_GROUPS"

for GROUP in $COMBAT_GROUPS; do
    echo "=== Submitting step4b for group: $GROUP ==="
    export CONFIG_FILE GROUP HPC_ENABLED

    if [[ "$HPC_ENABLED" == "1" ]]; then
        sbatch --job-name="step4b_${GROUP}" "$SUB_SCRIPT"
    else
        bash "$SUB_SCRIPT"
    fi
done
