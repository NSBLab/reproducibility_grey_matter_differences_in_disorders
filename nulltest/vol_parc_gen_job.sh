#!/bin/bash
#SBATCH --time=0-5:00:00
#SBATCH --job-name=vol_gen
#SBATCH --account=kg98
#SBATCH --cpus-per-task=13
#SBATCH --mem=240000
# SBATCH --mail-user=youremail@monash.edu
# SBATCH --mail-type=FAIL
# SBATCH --mail-type=BEGIN
# SBATCH --mail-type=END

module load conda-install
source /scratch/kg98/trangc/miniconda/bin/activate

# Define the conditions you want to pass


	python /projects/kg98/trangc/VBM/code/nulltest/pythonProject/vol_parc_thres_gen.py "${diag}" "${dataset}" "${nParc}"


