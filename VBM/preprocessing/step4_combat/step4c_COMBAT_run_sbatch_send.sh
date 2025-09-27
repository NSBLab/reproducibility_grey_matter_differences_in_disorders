#!/bin/bash

export smoothKernel=0
export maskDiag='AD' # psy or AD or SCZ
export hemi='rh' # 'lh' or 'rh'
export surface='1' # 1 or 0
script_dir=/home/trangc/kg98/trangc/VBM/code
#export diag=BD
sbatch ${script_dir}/COMBAT_run_sbatch.sh $i
#sh ${script_dir}/COMBAT_run_sbatch.sh $i

