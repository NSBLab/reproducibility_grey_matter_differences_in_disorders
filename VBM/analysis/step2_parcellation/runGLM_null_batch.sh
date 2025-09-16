#!/bin/bash
#SBATCH --time=0-9:00:00
#SBATCH --job-name=ABIDEII_Preprocessing
#SBATCH --account=kg98
#SBATCH --cpus-per-task=1
#SBATCH --mem=60000
# SBATCH --mail-user=youremail@monash.edu
# SBATCH --mail-type=FAIL
# SBATCH --mail-type=BEGIN
# SBATCH --mail-type=END



export script_DIR=/home/trangc/kg98/trangc/VBM/code/roi

module load  spm12/matlab2021a.r7771-v1
#module load  matlab/r2023b
for iNull in $(seq 1 300)
do
	export randomNumber=$(($RANDOM + $randomNumber))
	echo $randomNumber
	export iNull=$iNull
	
	matlab -nodisplay -r "cd ('$script_DIR');  runGLM_nosex_null_func('$dataset',$isses, $iNull,$randomNumber,$nParc)"
done
