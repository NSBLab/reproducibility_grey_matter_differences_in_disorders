#!/bin/bash
#SBATCH --time=0-2:00:00
#SBATCH --job-name=GLM_VBM_${dataset}
#SBATCH --account=kg98
#SBATCH --cpus-per-task=1
#SBATCH --mem=80000
# SBATCH --mail-user=youremail@monash.edu
# SBATCH --mail-type=FAIL
# SBATCH --mail-type=BEGIN
# SBATCH --mail-type=END

# Check if environment variables are set
if [ -z "$DATA_ROOT" ] || [ -z "$smoothKernel" ] || [ -z "$SCRIPT_DIR" ] || [ -z "$dataset" ]; then
    echo "Error: Required environment variables not set"
    echo "DATA_ROOT: $DATA_ROOT"
    echo "smoothKernel: $smoothKernel"
    echo "SCRIPT_DIR: $SCRIPT_DIR"
    echo "dataset: $dataset"
    exit 1
fi

# Load required modules
echo "Loading required modules..."
module unload matlab 
module load spm12/matlab2021a.r7771-v1
#module load matlab/r2023b



# Run the MATLAB script using the new step5a function
echo "Running statistical analysis for dataset: $dataset"
echo "Harmonization: $harmonize"
echo "Smoothing kernel: $smoothKernel"
echo "Mask diagnostic group: $maskDiag"
echo "Sessions: $isses"
echo "Data Root: $DATA_ROOT"

matlab -nodisplay -r "cd ('$SCRIPT_DIR'); step5a_statistical_analysis('$DATA_ROOT', '$dataset', $isses, $smoothKernel, '$maskDiag', $harmonize); quit;"

# Check exit status
if [ $? -eq 0 ]; then
    echo "Statistical analysis completed successfully for dataset: $dataset"
else
    echo "Error: Statistical analysis failed for dataset: $dataset"
    exit 1
fi
