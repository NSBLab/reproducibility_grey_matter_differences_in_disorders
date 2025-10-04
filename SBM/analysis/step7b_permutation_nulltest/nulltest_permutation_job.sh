#!/bin/bash
#SBATCH --time=0-04:00:00
#SBATCH --job-name=perm_SBM
#SBATCH --account=kg98
#SBATCH --cpus-per-task=8
#SBATCH --mem=32000
# SBATCH --mail-user=youremail@monash.edu
# SBATCH --mail-type=FAIL
# SBATCH --mail-type=BEGIN
# SBATCH --mail-type=END

module load freesurfer/7.1.0

# Get script directory (same directory as this script file)
export SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# Set parameters
export measure=thickness
export measureShort=thick
export hemis=rh
export control=1
export covariance1=sex
export covariance2=age
export harmonize=1
export smoothKernel=10

# Create title for this permutation
if [ "$harmonize" -eq 1 ]; then 
	title=${diag}_${site}_${measureShort}_smooth${smoothKernel}_${hemis}_${covariance1}_${covariance2}_combat_perm_${ranseed}
else
	title=${diag}_${site}_${measureShort}_smooth${smoothKernel}_${hemis}_${covariance1}_${covariance2}_perm_${ranseed}
fi

echo "Processing permutation: $title"

# Set up paths
qdecDir=$datadir/$DATASET/derivatives/freesurfer/qdec
permDir=$datadir/$DATASET/derivatives/freesurfer/permutation_nulltest
sitePermDir=$permDir/${diag}_${site}_${measureShort}_smooth${smoothKernel}_${hemis}_${covariance1}_${covariance2}_combat

# Create permutation directories
if [ ! -d "$sitePermDir" ]; then mkdir -p "$sitePermDir"; echo "making permutation directory"; fi 

# Read the original site file to get subjects
originalSiteFile=$datadir/$DATASET/qdec_table_${diag}_${site}.dat
if [ ! -f "$originalSiteFile" ]; then
	echo "Error: Original site file not found: $originalSiteFile"
	exit 1
fi

# Create permuted metadata by shuffling diagnosis labels using MATLAB
permutedSiteFile=$sitePermDir/qdec_table_perm_${ranseed}.dat

# Load MATLAB and run the permutation script
module load matlab/r2023b

matlab -nodisplay -r "cd ('$SCRIPT_DIR'); create_permuted_qdec('$originalSiteFile', '$permutedSiteFile', $ranseed); quit"

# Create FSGD file for permutation
qdecfile=$sitePermDir/qdec_perm_${ranseed}.fsgd
inputfile=$sitePermDir/input_perm_${ranseed}.txt
rm -f $inputfile

# Make FSGD file
echo "GroupDescriptorFile 1" > $qdecfile
echo "Title ${title}" >> $qdecfile
echo "MeasurementName ${measure}" >> $qdecfile
echo "Class diagnosis${control}" >> $qdecfile
echo "Class diagnosis${diag}" >> $qdecfile

if [[ "${DATASET}" == "ABIDEI" ]] || [[ "${DATASET}" == "ABIDEII" ]]; then
	echo "Variables ${covariance1}" >> $qdecfile
else
	echo "Variables ${covariance1} ${covariance2}" >> $qdecfile
fi

# Process permuted data
IFS=$'\n'
for line in $(tail -n +2 "$permutedSiteFile")
do
	IFS=$'\t' read -ra parts <<< "$line"
	
	if [[ "${DATASET}" == "ABIDEI" ]] || [[ "${DATASET}" == "ABIDEII" ]]; then
		echo "Input ${parts[0]} diagnosis${parts[1]} ${parts[3]}" >> $qdecfile
	else
		echo "Input ${parts[0]} diagnosis${parts[1]} ${parts[2]} ${parts[3]}" >> $qdecfile	
	fi

	# Make list input
	if [ "$DATASET" == "MBBP" ]; then 
		sub=$(echo "${parts[0]}" | sed 's/sub-0*\([1-9][0-9]*\)/sub-\1/')
	else
		sub=${parts[0]}
	fi 
	
	if [ "$harmonize" -eq 1 ]; then 
		echo "${datadir}/${DATASET}/derivatives/freesurfer/${sub}/surf/${hemis}.${measure}.fwhm${smoothKernel}.fsaverage_combat.mgh" >> $inputfile
	else
		echo "${datadir}/${DATASET}/derivatives/freesurfer/${sub}/surf/${hemis}.${measure}.fwhm${smoothKernel}.fsaverage.mgh" >> $inputfile
	fi
done
unset IFS

# Concatenate subject data from input list
mri_concat --f $inputfile --o $sitePermDir/y_perm_${ranseed}.mgh

# Make contrast
contrastDir=$sitePermDir/contrasts
if [ ! -d "$contrastDir" ]; then mkdir $contrastDir; echo "making contrast directory"; fi 

if [[ "${DATASET}" == "ABIDEI" ]] || [[ "${DATASET}" == "ABIDEII" ]]; then
	echo "1 1 0" > $contrastDir/${hemis}-Avg-Intercept-${measure}.mat
	echo "1 -1 0" > $contrastDir/${hemis}-Diff-${control}-${diag}-Intercept-${measure}.mat
else
	echo "1 1 0 0" > $contrastDir/${hemis}-Avg-Intercept-${measure}.mat
	echo "1 -1 0 0" > $contrastDir/${hemis}-Diff-${control}-${diag}-Intercept-${measure}.mat
fi

# Run mri_glmfit for permutation
mri_glmfit --y $sitePermDir/y_perm_${ranseed}.mgh --fsgd $qdecfile doss --glmdir $sitePermDir --surf fsaverage ${hemis} --label ${datadir}/${DATASET}/derivatives/freesurfer/fsaverage/label/${hemis}.aparc.label --C $contrastDir/${hemis}-Avg-Intercept-${measure}.mat --C $contrastDir/${hemis}-Diff-${control}-${diag}-Intercept-${measure}.mat --eres-save

# Extract the t-statistic map for this permutation
cp $sitePermDir/glmdir/${hemis}-Diff-${control}-${diag}-Intercept-${measure}/osgm/t.mgh $sitePermDir/surrogate_${ranseed}.mgh

echo "Permutation $ranseed completed for ${diag}_${site}"
