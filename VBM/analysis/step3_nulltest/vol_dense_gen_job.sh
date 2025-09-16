#!/bin/bash
#SBATCH --time=0-1:00:00
#SBATCH --job-name=vol_gen
#SBATCH --account=kg98
#SBATCH --cpus-per-task=12
#SBATCH --mem=120000
# SBATCH --mail-user=youremail@monash.edu
# SBATCH --mail-type=FAIL
# SBATCH --mail-type=BEGIN
# SBATCH --mail-type=END

module load conda-install
source /scratch2/kg98/trangc/miniconda3/bin/activate
conda activate trangcenv

# Define the conditions you want to pass


	python /projects/kg98/trangc/VBM/code/nulltest/pythonProject/vol_dense_gen.py "${diag}" "${site}" "${ranseed}"


