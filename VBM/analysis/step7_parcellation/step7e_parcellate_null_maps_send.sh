#!/bin/bash
# Dispatcher: parcellate VBM surrogate null maps per diagnosis x site.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SUB_SCRIPT="${SCRIPT_DIR}/parcellate_null_map_batch.sh"

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
[[ -f "$SUB_SCRIPT" ]] || { echo "Error: missing worker script $SUB_SCRIPT"; exit 1; }

DATA_ROOT=$(jq -r '.data_directories.dataset_root' "$CONFIG_FILE")
SMOOTH_KERNEL=$(jq -r '.analysis_settings.vbm_smoothing_kernel // 6' "$CONFIG_FILE")
HARMONIZE=$(jq -r '.analysis_settings.harmonize // 1' "$CONFIG_FILE")
N_NULL=$(jq -r '.analysis_settings.num_permutations // 10' "$CONFIG_FILE")
MASK_DIAG=$(jq -r '.analysis_settings.mask_diagnostic_group // "psy"' "$CONFIG_FILE")

HPC_ENABLED_RAW=$(jq -r '.execution_mode.hpc_enabled // false' "$CONFIG_FILE")
case "$(echo "$HPC_ENABLED_RAW" | tr '[:upper:]' '[:lower:]')" in
    1|true) HPC_ENABLED="1" ;;
    *) HPC_ENABLED="0" ;;
esac

MAX_PARALLEL=$(jq -r '.execution_mode.local_settings.max_parallel_jobs // 4' "$CONFIG_FILE")
[[ "$MAX_PARALLEL" =~ ^[0-9]+$ ]] || MAX_PARALLEL=4

if [[ "$HARMONIZE" == "1" ]]; then
    NULLDIR="${DATA_ROOT}/nulltest/surrogateVBM/s${SMOOTH_KERNEL}COMBAT"
else
    NULLDIR="${DATA_ROOT}/nulltest/surrogateVBM/s${SMOOTH_KERNEL}"
fi

# Prefer group-specific metadata, else combined
META_GROUP="${DATA_ROOT}/metadataVBM_${MASK_DIAG}.csv"
META_ALL="${DATA_ROOT}/metadataVBM.csv"
if [ -f "$META_GROUP" ]; then
    filename="$META_GROUP"
elif [ -f "$META_ALL" ]; then
    filename="$META_ALL"
else
    echo "Error: metadata not found ($META_GROUP or $META_ALL)"
    exit 1
fi

header=$(head -n 1 "$filename")
IFS=',' read -ra cols <<< "$header"
for i in "${!cols[@]}"; do
    col_clean=$(echo "${cols[$i]}" | tr -d '\r' | tr -d '"')
    if [[ "$col_clean" == "diagnosis_string" ]]; then diag_col=$((i+1)); fi
    if [[ "$col_clean" == "site_string" ]]; then site_col=$((i+1)); fi
done

if [ -z "${diag_col:-}" ] || [ -z "${site_col:-}" ]; then
    echo "Error: diagnosis_string / site_string columns not found in $filename"
    exit 1
fi

# Unique non-HC diagnosis labels
diagnosisList=$(awk -F',' -v col="$diag_col" 'NR>1 {
    gsub(/\r/,"",$col); gsub(/"/,"",$col);
    if ($col != "" && $col != "HC" && $col != "Control" && $col != "control") print $col
}' "$filename" | sort | uniq)

echo "=== STEP7E: PARCELLATE NULL MAPS ==="
echo "CONFIG_FILE: $CONFIG_FILE"
echo "NULLDIR:     $NULLDIR"
echo "metadata:    $filename"
echo "nNull:       $N_NULL"
echo "HPC_ENABLED: $HPC_ENABLED"

export CONFIG_FILE DATA_ROOT SCRIPT_DIR HPC_ENABLED NULLDIR
export nNull="$N_NULL"

pids=()
while IFS= read -r diag; do
    [[ -z "$diag" ]] && continue
    export diag
    matching_rows=$(awk -F',' -v col="$diag_col" -v value="$diag" 'BEGIN{IGNORECASE=0} {
        gsub(/\r/,"",$col); gsub(/"/,"",$col);
        if ($col == value) print
    }' "$filename")
    siteList=$(echo "$matching_rows" | awk -F',' -v col="$site_col" '{
        gsub(/\r/,"",$col); gsub(/"/,"",$col); print $col
    }' | sort | uniq)

    while IFS= read -r site; do
        [[ -z "$site" ]] && continue
        export site
        echo "diag=$diag  site=$site"

        if [[ "$HPC_ENABLED" == "1" ]]; then
            sbatch --job-name="parc_null_${diag}_${site}" "$SUB_SCRIPT"
        else
            bash "$SUB_SCRIPT" &
            pids+=($!)
            if [[ "${#pids[@]}" -ge "$MAX_PARALLEL" ]]; then
                wait "${pids[0]}"
                pids=("${pids[@]:1}")
            fi
        fi
    done <<< "$siteList"
done <<< "$diagnosisList"

if [[ "$HPC_ENABLED" != "1" ]]; then
    wait
fi

echo "=== STEP7E SUBMISSION DONE ==="
