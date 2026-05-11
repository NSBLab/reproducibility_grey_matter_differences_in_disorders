#!/usr/bin/env bash
#SBATCH --job-name=euler_number
#SBATCH --account=kg98
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=1-00:00:00
#SBATCH --export=ALL
#SBATCH --mem-per-cpu=8000

# Worker: computes Euler numbers for one dataset (invoked by step2c.euler.sh)
[ -n "${BASH_VERSION:-}" ] || exec bash "$0" "$@"

CONFIG_FILE="${CONFIG_FILE:?Set CONFIG_FILE}"
DATA_ROOT="${DATA_ROOT:?Set DATA_ROOT}"
DATASET="${DATASET:?Set DATASET}"

LONG=$(jq -r --arg ds "$DATASET" '.datasets[$ds].longitudinal // false' "$CONFIG_FILE")
[[ "$LONG" == "true" ]] && LONG=1 || LONG=0

BASE="${DATA_ROOT}/${DATASET}"
SUBJECTS_DIR="${FREESURFER_SUBJECTS_DIR:-${BASE}/derivatives/freesurfer}"
outdir="${BASE}/derivatives/euler"

echo "---------------------------"
echo "----- Euler ${DATASET} -----"
echo "---------------------------"

mkdir -p "$outdir"

if [[ "${HPC_ENABLED:-0}" == "1" ]] || [[ "$(echo "${HPC_ENABLED:-}" | tr '[:upper:]' '[:lower:]')" == "true" ]]; then
    module purge
    module load freesurfer/7.1.0
fi

numbers='^[0-9]+$'
rm -f "${outdir}/${DATASET}_holes_temp.txt" "${outdir}/${DATASET}_ids.txt"
f="${outdir}/${DATASET}_holes_temp.txt"
id="${outdir}/${DATASET}_ids.txt"
e="${outdir}/${DATASET}_holes.csv"

if [[ "$LONG" -eq 0 ]]; then
    while read -r i; do
        i=$(echo "$i" | xargs)
        [[ -z "$i" ]] && continue
        for h in lh rh; do
            x=$(mris_euler_number "${SUBJECTS_DIR}/${i}/surf/${h}.orig.nofix" 2>/dev/null | grep -o -P '(?<=--> ).*(?= holes)')
            if [[ "$x" =~ $numbers ]]; then
                echo "$x" >>"$f"
                echo "${i}_${h}" >>"$id"
            fi
        done
    done <"${BASE}/sub_with_recon_output.txt"
else
    # Longitudinal: entries are sub-XXXses-YY; strip the ses- suffix to get the
    # subject. recon-all outputs to ${SUBJECTS_DIR}/${subj}/ (no session
    # subdirectory) because step1 runs with run_id=$subj.
    while read -r i; do
        i=$(echo "$i" | xargs)
        [[ -z "$i" ]] && continue
        subj="${i%%ses-*}"
        for h in lh rh; do
            x=$(mris_euler_number "${SUBJECTS_DIR}/${subj}/surf/${h}.orig.nofix" 2>/dev/null | grep -o -P '(?<=--> ).*(?= holes)')
            if [[ "$x" =~ $numbers ]]; then
                echo "$x" >>"$f"
                echo "${subj}_${h}" >>"$id"
            fi
        done
    done <"${BASE}/ses_sub_with_recon_output.txt"
fi

if [[ ! -s "$id" ]]; then
    echo "Warning: no Euler values written for ${DATASET}"
    rm -f "$id" "$f"
    exit 0
fi

paste -d "," "$id" "$f" >"$e"
rm -f "$id" "$f"

# Apply 3.29 SD Euler QC threshold and write subjects_pass_Euler_number_check.txt.
# subjects_pass_visualisation.txt is then created from this file by manually
# removing subjects that fail visual surface inspection (step3).
pass_file="${BASE}/subjects_pass_Euler_number_check.txt"
awk -F',' '
{
    name = $1; holes = $2
    en_val = 2 - 2 * holes
    sub = substr(name, 1, length(name) - 3)   # strip _lh or _rh
    hemi_en[NR] = en_val
    sub_sum[sub] += en_val
    sub_cnt[sub]++
    if (!(sub in seen)) { seen[sub] = 1; order[++nSubs] = sub }
}
END {
    n = NR
    sum = 0
    for (i = 1; i <= n; i++) sum += hemi_en[i]
    mean = sum / n
    ss = 0
    for (i = 1; i <= n; i++) ss += (hemi_en[i] - mean)^2
    sd = sqrt(ss / (n - 1))
    thr = mean - 3.29 * sd
    nPass = 0
    for (k = 1; k <= nSubs; k++) {
        sub = order[k]
        if (sub_cnt[sub] == 2 && sub_sum[sub] / 2 > thr) {
            print sub
            nPass++
        }
    }
    printf "Euler QC: %d/%d subjects passed (threshold=%.1f)\n", nPass, nSubs, thr > "/dev/stderr"
}
' "$e" >"$pass_file"
echo "Subjects passing Euler QC: $pass_file"

echo "----- DONE -----"
