#!/bin/bash
#SBATCH --time=0-04:00:00
#SBATCH --job-name=perm_SBM
#SBATCH --account=kg98
#SBATCH --cpus-per-task=8
#SBATCH --mem=32000

# Worker: one SBM label-shuffle permutation GLM.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
datadir="${datadir:?Set datadir (DATA_ROOT)}"
DATASET="${DATASET:?Set DATASET}"
diag="${diag:?Set diag}"
site="${site:?Set site}"
ranseed="${ranseed:?Set ranseed}"
smoothKernel="${smoothKernel:?Set smoothKernel}"
harmonize="${harmonize:?Set harmonize}"

measure="${measure:-thickness}"
measureShort="${measureShort:-thick}"
hemis="${hemis:-lh}"
control="${control:-1}"
covariance1="${covariance1:-sex}"
covariance2="${covariance2:-age}"

if [ "${HPC_ENABLED:-0}" = "1" ]; then
    module load freesurfer/7.1.0
    module load matlab/r2023b
fi

if [ "$harmonize" -eq 1 ]; then
    combat_suffix="_combat"
    title=${diag}_${site}_${measureShort}_smooth${smoothKernel}_${hemis}_${covariance1}_${covariance2}_combat_perm_${ranseed}
else
    combat_suffix=""
    title=${diag}_${site}_${measureShort}_smooth${smoothKernel}_${hemis}_${covariance1}_${covariance2}_perm_${ranseed}
fi

echo "Processing permutation: $title"

qdecDir=$datadir/$DATASET/derivatives/freesurfer/qdec
permDir=$datadir/$DATASET/derivatives/freesurfer/permutation_nulltest
sitePermDir=$permDir/${diag}_${site}_${measureShort}_smooth${smoothKernel}_${hemis}_${covariance1}_${covariance2}${combat_suffix}
mkdir -p "$sitePermDir"

originalSiteFile=$datadir/$DATASET/qdec_table_${site}_${diag}.dat
if [ ! -f "$originalSiteFile" ]; then
    echo "Error: Original site file not found: $originalSiteFile"
    exit 1
fi

permutedSiteFile=$sitePermDir/qdec_table_perm_${ranseed}.dat
matlab -nodisplay -r "addpath('$SCRIPT_DIR'); create_permuted_qdec('$originalSiteFile', '$permutedSiteFile', $ranseed); quit;"
if [ $? -ne 0 ]; then
    echo "Error: create_permuted_qdec failed"
    exit 1
fi

qdecfile=$sitePermDir/qdec_perm_${ranseed}.fsgd
inputfile=$sitePermDir/input_perm_${ranseed}.txt
rm -f "$inputfile"

echo "GroupDescriptorFile 1" > "$qdecfile"
echo "Title ${title}" >> "$qdecfile"
echo "MeasurementName ${measure}" >> "$qdecfile"
echo "Class diagnosis${control}" >> "$qdecfile"
echo "Class diagnosis${diag}" >> "$qdecfile"

if [[ "${DATASET}" == "ABIDEI" ]] || [[ "${DATASET}" == "ABIDEII" ]]; then
    echo "Variables ${covariance1}" >> "$qdecfile"
else
    echo "Variables ${covariance1} ${covariance2}" >> "$qdecfile"
fi

IFS=$'\n'
for line in $(tail -n +2 "$permutedSiteFile")
do
    IFS=$'\t' read -ra parts <<< "$line"

    if [[ "${DATASET}" == "ABIDEI" ]] || [[ "${DATASET}" == "ABIDEII" ]]; then
        echo "Input ${parts[0]} diagnosis${parts[1]} ${parts[3]}" >> "$qdecfile"
    else
        echo "Input ${parts[0]} diagnosis${parts[1]} ${parts[2]} ${parts[3]}" >> "$qdecfile"
    fi

    if [ "$DATASET" == "MBBP" ]; then
        sub=$(echo "${parts[0]}" | sed 's/sub-0*\([1-9][0-9]*\)/sub-\1/')
    else
        sub=${parts[0]}
    fi

    if [ "$harmonize" -eq 1 ]; then
        echo "${datadir}/${DATASET}/derivatives/freesurfer/${sub}/surf/${hemis}.${measure}.fwhm${smoothKernel}.fsaverage_combat.mgh" >> "$inputfile"
    else
        echo "${datadir}/${DATASET}/derivatives/freesurfer/${sub}/surf/${hemis}.${measure}.fwhm${smoothKernel}.fsaverage.mgh" >> "$inputfile"
    fi
done
unset IFS

mri_concat --f "$inputfile" --o "$sitePermDir/y_perm_${ranseed}.mgh"

contrastDir=$sitePermDir/contrasts
mkdir -p "$contrastDir"

if [[ "${DATASET}" == "ABIDEI" ]] || [[ "${DATASET}" == "ABIDEII" ]]; then
    echo "1 1 0" > "$contrastDir/${hemis}-Avg-Intercept-${measure}.mat"
    echo "1 -1 0" > "$contrastDir/${hemis}-Diff-${control}-${diag}-Intercept-${measure}.mat"
else
    echo "1 1 0 0" > "$contrastDir/${hemis}-Avg-Intercept-${measure}.mat"
    echo "1 -1 0 0" > "$contrastDir/${hemis}-Diff-${control}-${diag}-Intercept-${measure}.mat"
fi

mri_glmfit \
    --y "$sitePermDir/y_perm_${ranseed}.mgh" \
    --fsgd "$qdecfile" doss \
    --glmdir "$sitePermDir" \
    --surf fsaverage "${hemis}" \
    --label "${datadir}/${DATASET}/derivatives/freesurfer/fsaverage/label/${hemis}.aparc.label" \
    --C "$contrastDir/${hemis}-Avg-Intercept-${measure}.mat" \
    --C "$contrastDir/${hemis}-Diff-${control}-${diag}-Intercept-${measure}.mat" \
    --eres-save

cp "$sitePermDir/glmdir/${hemis}-Diff-${control}-${diag}-Intercept-${measure}/osgm/t.mgh" \
   "$sitePermDir/surrogate_${ranseed}.mgh"

echo "Permutation $ranseed completed for ${diag}_${site}"
