#!/bin/bash

export smoothKernel=10
export measure=thickness
export measureShort=thick
export hemis=lh
diagList=(2) #(2 3 4 5 6 7)
export control=1

export covariance1=sex
export covariance2=age

nSubdivide=100
groupsizelist=(10    16    25) #    40    63   100) #(10    16    25    40    63   100  158  251 398) # adding the max number that each diagnosis can have, corresponding to the diaglist (210, 136, 527, 111, 231, 327)  
#nSample=100

groupList=(1 2)

export script_DIR=/projects/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step4_qdec

for diag in ${diagList[@]}
do
	export diag=$diag

    for groupsize in ${groupsizelist[@]}
	do
		export groupsize=$groupsize
		export dividemode=splitsite_samesize_$groupsize

		export  outdir=/scratch/kg98/trangc/VBM/data/derivatives/freesurfer/s10noCOMBAT/diag${diag}/${hemis}/resample_2sitegroup_${dividemode}
		cd $outdir

		arraySubdivide=($(ls -d iSubdivide_*_seed2group_*))

		for iarraySubdivide in ${arraySubdivide[@]}; do
	
			IFS=$'_' read -ra divideparts <<< "$iarraySubdivide"

			export iSubdivide=${divideparts[1]}
			export randomSubdivide=${divideparts[3]}

			#echo $iarraySubdivide
	
			if [ -f $outdir/iSubdivide_${iSubdivide}_seed2group_${randomSubdivide}/iSubdivide_${iSubdivide}_seed2group_${randomSubdivide}_group1.txt ] & [ -f $outdir/iSubdivide_${iSubdivide}_seed2group_${randomSubdivide}/iSubdivide_${iSubdivide}_seed2group_${randomSubdivide}_group2.txt ] & [ ! -f $outdir/iSubdivide_${iSubdivide}_seed2group_${randomSubdivide}/iSubdivide_${iSubdivide}_seed2group_${randomSubdivide}_group1_sm${smoothKernel}/lh-Diff-1-${diag}-Intercept-thickness/perm.th13.abs.sig.cluster.mgh ] & [ ! -f $outdir/iSubdivide_${iSubdivide}_seed2group_${randomSubdivide}/iSubdivide_${iSubdivide}_seed2group_${randomSubdivide}_group2_sm${smoothKernel}/lh-Diff-1-${diag}-Intercept-thickness/perm.th13.abs.sig.cluster.mgh ] 
			then 
				echo $iSubdivide
				sbatch --job-name=GLM_${diag}_${groupsize}_${iSubdivide} ${script_DIR}/make_input_run_mri_glmfit_subdivide_2sitegroup.sh

				#sh ${script_DIR}/make_input_run_mri_glmfit_subdivide_2sitegroup.sh
			fi
			 
		done
	done
done
