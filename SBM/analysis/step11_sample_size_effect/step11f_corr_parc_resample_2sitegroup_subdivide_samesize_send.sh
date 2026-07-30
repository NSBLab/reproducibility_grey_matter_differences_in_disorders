#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -z "$CONFIG_FILE" ]; then
    REPO_ROOT=$(cd "$SCRIPT_DIR/../../.." && pwd)
    CONFIG_FILE="$REPO_ROOT/config_hpc.json"
fi
DATA_ROOT=$(jq -r '.data_directories.dataset_root' "$CONFIG_FILE")

export smoothKernel=10
export measure=thickness
export measureShort=thick
export hemis=lh
diagList=(6) #(2 3 4 5 6 7)
export control=1

export covariance1=sex
export covariance2=age

nSubdivide=100
groupsizelist=(10    16  25    40    63   100) #(10    16  25    40    63   100  158  251  398 ) #  adding the max number that each diagnosis can have, corresponding to the diaglist (210, 136, 527, 111, 231, 327)  
#nSample=100

groupList=(1 2)

for diag in ${diagList[@]}
do
	export diag=$diag

    for groupsize in ${groupsizelist[@]}
	do
		export groupsize=$groupsize
		export dividemode=splitsite_samesize_$groupsize

		export outdir=${DATA_ROOT}/derivatives/freesurfer/s${smoothKernel}noCOMBAT/diag${diag}/${hemis}/resample_2sitegroup_${dividemode}
		if [ -d $outdir ];then
		cd $outdir

		arraySubdivide=($(ls -d iSubdivide_*_seed2group_*))

		for iarraySubdivide in ${arraySubdivide[@]}; do
	
			IFS=$'_' read -ra divideparts <<< "$iarraySubdivide"

			export iSubdivide=${divideparts[1]}
			export randomSubdivide=${divideparts[3]}

			echo $iarraySubdivide
	
			if [ -f $outdir/iSubdivide_${iSubdivide}_seed2group_${randomSubdivide}/iSubdivide_${iSubdivide}_seed2group_${randomSubdivide}_group1.txt ] & [ -f $outdir/iSubdivide_${iSubdivide}_seed2group_${randomSubdivide}/iSubdivide_${iSubdivide}_seed2group_${randomSubdivide}_group1_SF_combat/${hemis}.${measure}.fwhm0_glm.fsaverage.mat ] # & [ ! -f $outdir/iSubdivide_${iSubdivide}_seed2group_${randomSubdivide}/corr_furface_SF.mat ]; 
			then 
				echo $iSubdivide
				sbatch --job-name=corr_${diag}_${groupsize}_${iSubdivide} ${SCRIPT_DIR}/corr_map_parc_resample_2sitegroup.sh

				#sh ${script_DIR}/corr_map_parc_resample_2sitegroup.sh
			fi
			 
		done
		fi
	done
done
