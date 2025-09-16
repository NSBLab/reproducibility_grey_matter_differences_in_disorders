#!/bin/bash


SUBJLIST=/home/trangc/kg98/trangc/VBM/data/dataset_list_noses2.txt

datadir=/fs04/kg98/trangc/VBM/data
export datadir=$datadir

export smoothKernel=10
export measure=thickness
export measureShort=thick
export hemis=lh
export control=1
export iNullMin=1
export iNullMax=300
export covariance1=sex
export covariance2=age

# run for each dataset
for DATASET in `cat ${SUBJLIST}`
do

	export DATASET=$DATASET
	export randomNumber=$RANDOM

	export script_DIR=/projects/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step4_qdec
	export nullDir=/scratch/kg98/trangc/VBM/data/derivatives/freesurfer/s10COMBAT/null

	module load  matlab/r2023b

	ls $datadir/$DATASET/qdec_table_*.dat > $datadir/$DATASET/sitelist.txt
# run for each site in the dataset
	for sitefileori in $(tail -n +1 "$datadir/$DATASET/sitelist.txt") #`cat $datadir/$DATASET/sitelist.txt` #
	do

		export sitefileori=$sitefileori
		export sitefield=$(echo "$sitefileori" | grep -o -P '(?<=table_).*(?=.dat)') #| awk -F_ '{for (i=3; i<=NF-1; i++) printf "%s_", $i}')
		echo $sitefield
		export site=${sitefield:0:${#sitefield}-2}
		echo $site
		export diag=${sitefileori:${#sitefileori}-5:1}
		echo $diag

	
	# create null .dat files
		matlab -nodisplay -r "addpath('$script_DIR');  run_null_func($randomNumber,'$DATASET', '$nullDir','$sitefileori',$iNullMin,$iNullMax); quit"

		 
			sbatch --job-name=GLM_null_${DATASET} make_input_run_mri_glmfit_null.sh
		#sh make_input_run_mri_glmfit_parcel_null.sh
	
	done
	
done


