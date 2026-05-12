#!/bin/bash
#SBATCH --job-name=step6_glmfit
#SBATCH --account=kg98
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --time=0-12:00:00
#SBATCH --export=ALL
#SBATCH --mem=60000

# Worker: runs mri_glmfit for one dataset (invoked by step6_glmfit.sh)

CONFIG_FILE="${CONFIG_FILE:?Set CONFIG_FILE}"
DATA_ROOT="${DATA_ROOT:?Set DATA_ROOT}"
DATASET="${DATASET:?Set DATASET}"
HARMONIZE="${HARMONIZE:-1}"

HPC_ENABLED_RAW="${HPC_ENABLED:-0}"
case "$(echo "$HPC_ENABLED_RAW" | tr '[:upper:]' '[:lower:]')" in 1|true) HPC_ENABLED="1" ;; *) HPC_ENABLED="0" ;; esac

if [[ "$HPC_ENABLED" == "1" ]]; then
    module load freesurfer/7.1.0
fi

datadir="$DATA_ROOT"
reconOutDir="${datadir}/${DATASET}/derivatives/freesurfer"

echo "=== STEP6 GLM: dataset=${DATASET} harmonize=${HARMONIZE} ==="

sitelist="${datadir}/${DATASET}/sitelist.txt"
if [[ ! -s "$sitelist" ]]; then
    echo "Error: sitelist.txt not found or empty at ${sitelist}"
    echo "Run extract_sub_surface_${DATASET} first to generate qdec tables and sitelist.txt"
    exit 1
fi

for hemi in $hemis; do
for sitefile in $(cat "$sitelist"); do

    echo "Site file: $sitefile  hemi: $hemi"
    sitefield=$(echo "$sitefile" | grep -o -P '(?<=table_).*(?=.dat)')
    site=${sitefield:0:${#sitefield}-2}
    diag=${sitefile:${#sitefile}-5:1}

    if [[ "$HARMONIZE" -eq 1 ]]; then
        title=${diag}_${site}_${measureShort}_smooth${smoothKernel}_${hemi}_${covariance1}_${covariance2}_combat
    else
        title=${diag}_${site}_${measureShort}_smooth${smoothKernel}_${hemi}_${covariance1}_${covariance2}
    fi

    qdecDir="${datadir}/${DATASET}/derivatives/freesurfer/qdec"
    mkdir -p "${qdecDir}/${title}"

    qdecfile="${qdecDir}/${title}/qdec.fsgd"
    inputfile="${qdecDir}/${title}/input.txt"
    rm -f "$inputfile"

    # make fsgd file
    echo "GroupDescriptorFile 1"                    > "$qdecfile"
    echo "Title ${title}"                           >> "$qdecfile"
    echo "MeasurementName ${measure}"               >> "$qdecfile"
    echo "Class diagnosis${control}"                >> "$qdecfile"
    echo "Class diagnosis${diag}"                   >> "$qdecfile"

    if [[ "$DATASET" == "ABIDEI" ]] || [[ "$DATASET" == "ABIDEII" ]]; then
        echo "Variables ${covariance1}"             >> "$qdecfile"
    else
        echo "Variables ${covariance1} ${covariance2}" >> "$qdecfile"
    fi

    IFS=$'\n'
    for line in $(tail -n +2 "$sitefile"); do
        IFS=$'\t' read -ra parts <<< "$line"
        sub="${parts[0]}"

        if [[ "$DATASET" == "ABIDEI" ]] || [[ "$DATASET" == "ABIDEII" ]]; then
            echo "Input ${sub} diagnosis${parts[1]} ${parts[3]}" >> "$qdecfile"
        else
            echo "Input ${sub} diagnosis${parts[1]} ${parts[2]} ${parts[3]}" >> "$qdecfile"
        fi

        if [[ "$HARMONIZE" -eq 1 ]]; then
            echo "${datadir}/${DATASET}/derivatives/freesurfer/${sub}/surf/${hemi}.${measure}.fwhm${smoothKernel}.fsaverage_combat.mgh" >> "$inputfile"
        else
            echo "${reconOutDir}/${sub}/surf/${hemi}.${measure}.fwhm${smoothKernel}.fsaverage.mgh" >> "$inputfile"
        fi
    done
    unset IFS

    # concat subject data
    mri_concat --f "$inputfile" --o "${qdecDir}/${title}/y.mgh"

    # make contrasts
    contrastDir="${qdecDir}/${title}/contrasts"
    mkdir -p "$contrastDir"

    if [[ "$DATASET" == "ABIDEI" ]] || [[ "$DATASET" == "ABIDEII" ]]; then
        echo "1 1 0"   > "${contrastDir}/${hemi}-Avg-Intercept-${measure}.mat"
        echo "1 -1 0"  > "${contrastDir}/${hemi}-Diff-${control}-${diag}-Intercept-${measure}.mat"
    else
        echo "1 1 0 0"  > "${contrastDir}/${hemi}-Avg-Intercept-${measure}.mat"
        echo "1 -1 0 0" > "${contrastDir}/${hemi}-Diff-${control}-${diag}-Intercept-${measure}.mat"
    fi

    # run mri_glmfit
    mri_glmfit \
        --y "${qdecDir}/${title}/y.mgh" \
        --fsgd "${qdecDir}/${title}/qdec.fsgd" doss \
        --glmdir "${qdecDir}/${title}" \
        --surf fsaverage "$hemi" \
        --label "${reconOutDir}/fsaverage/label/${hemi}.aparc.label" \
        --C "${contrastDir}/${hemi}-Avg-Intercept-${measure}.mat" \
        --C "${contrastDir}/${hemi}-Diff-${control}-${diag}-Intercept-${measure}.mat" \
        --eres-save

    # run permutation for thresholded maps
    mri_glmfit-sim \
        --glmdir "${qdecDir}/${title}" \
        --perm 1000 1.3 abs \
        --cwp 0.05 --2spaces --bg 24 --overwrite

done
done
