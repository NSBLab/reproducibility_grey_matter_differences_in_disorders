#!/bin/env bash


# load modules
module load freesurfer/7.1.0
module load connectome

datadir=/projects/kg98/trangc/VBM/data

DATASET_LIST=$datadir/dataset_list_noses1.txt

hemi=lh
hemi2=L

for DATASET in `cat ${DATASET_LIST}`
do
	echo $DATASET

	for sitefile in `cat $datadir/$DATASET/sitelist.txt`
	do	
		echo $sitefile
		while IFS= read -r subline; do

			IFS=$'\t' read -ra parts <<< "$subline"

			line=${parts[0]}

			if [ ! -f ${datadir}/${DATASET}/derivatives/freesurfer/${line}/surf/lh.thickness.fsaverage5_10k.func.gii ] ; then
		

		input_sub_dir=${datadir}/${DATASET}/derivatives/freesurfer/${line}/surf
		fsaverage_dir=/usr/local/freesurfer/7.1.0/subjects/fsaverage5/surf

		# this folder contains the transformations needed between surfaces
		standard_mesh_atlases=/projects/kg98/trangc/atlases/standard_mesh_atlases/resample_fsaverage

		# change this output directory according to your preference just so you don't overwrite the original data folder
		output_sub_dir=${datadir}/${DATASET}/derivatives/freesurfer/${line}/surf

    		#mkdir -p ${output_sub_dir}

		# convert metric file (thickness or surface area) to gifti format
		mris_convert -c ${input_sub_dir}/${hemi}.thickness ${input_sub_dir}/${hemi}.white ${output_sub_dir}/${hemi}.thickness.native.func.gii

		# wb_shortcuts -freesurfer-resample-prep <fs-white> <fs-pial> <current-freesurfer-sphere> <newsphere> <midthickness-current-out> <midthickness-new-out> <current-gifti-sphere-out>
		wb_shortcuts -freesurfer-resample-prep ${input_sub_dir}/${hemi}.white ${input_sub_dir}/${hemi}.pial ${input_sub_dir}/${hemi}.sphere.reg ${standard_mesh_atlases}/fsaverage5_std_sphere.${hemi2}.10k_fsavg_${hemi2}.surf.gii  ${output_sub_dir}/${hemi2}.midthickness.native.surf.gii   ${output_sub_dir}/${hemi2}.midthickness.fsaverage5_10k.surf.gii   ${output_sub_dir}/${hemi}.sphere.reg.surf.gii


		# wb_command -metric-resample <metric-in> <current-sphere> <new-sphere> ADAP_BARY_AREA <metric-out> -area-surfs <current-area> <new-area>
		wb_command -metric-resample ${output_sub_dir}/${hemi}.thickness.native.func.gii \
							${output_sub_dir}/${hemi}.sphere.reg.surf.gii \
							${standard_mesh_atlases}/fsaverage5_std_sphere.${hemi2}.10k_fsavg_${hemi2}.surf.gii \
							ADAP_BARY_AREA \
							${output_sub_dir}/${hemi}.thickness.fsaverage5_10k.func.gii \
							-area-surfs \
							${output_sub_dir}/${hemi2}.midthickness.native.surf.gii \
			 				${output_sub_dir}/${hemi2}.midthickness.fsaverage5_10k.surf.gii

# remove unnecessary files generated during the process
#rm -rf ${output_sub_dir}/${hemi}.sphere.reg.surf.gii
#rm -rf ${output_sub_dir}/${hemi2}.midthickness.native.surf.gii
#rm -rf ${output_sub_dir}/${hemi2}.midthickness.fsLR_32k.surf.gii

			fi
		done < $sitefile
	done
done
# Repeat for thickness and surface area, hemispheres (change hemi and hemi2), all subjects
