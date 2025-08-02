#!/bin/env bash

# smooth metric data in gifti format

# only for massive
# workbench_dir='/usr/local/connectome/1.4.2/bin_rh_linux64/'
module load freesurfer
module load connectome

#subjectfile=/home/trangc/kg98/trangc/HCP339independent/subID1.txt
hemi=lh
hemi2=L
dataset=oasis3_hc_ad_last
fwhm_list=(10 20 30)
#(6 10 20)
# this folder (James') contains the transformations needed between surfaces
standard_mesh_atlases=/fs02/kg98/trangc/atlases/standard_mesh_atlases/resample_fsaverage

filename=$1
while read SUBJECTID; do
#for SUBJECTID in `cat ${subjectfile}` ; do
	if [ ! -f /home/trangc/kg98/trangc/${dataset}/${SUBJECTID}/surf/lh.thickness_fwhm_10mm.32k_fs_LR.shape.gii ] ; then
	echo ${SUBJECTID}

	input_dir=/home/trangc/kg98/trangc/oasis3_hc_ad_last/${SUBJECTID}/surf
	output_dir=$input_dir

#	if [ ! -d ${output_dir} ]; then
#       mkdir -p ${output_dir}
#fi

	input_file=${output_dir}/${hemi}.thickness.fsLR_32k.func.gii

	sphere=/fs02/kg98/trangc/atlases/standard_mesh_atlases/resample_fsaverage/fs_LR-deformed_to-fsaverage.L.sphere.32k_fs_LR.surf.gii
	

	for fwhm in "${fwhm_list[@]}"; do
		echo "Performing smoothing on ${SUBJECTID} map using fwhm = ${fwhm} mm"

		output_file=${output_dir}/${hemi}.thickness_fwhm_${fwhm}mm.32k_fs_LR.shape.gii
		

		# for local computers with connectome workbench versions at least 1.5.0
		# wb_command -metric-smoothing ${sphere_L} \
		# 							 ${input_file_L} \
		# 							 ${fwhm} \
		# 							 ${output_file_L} \
		# 							 -fix-zeros

		# wb_command -metric-smoothing ${sphere_R} \
		# 							 ${input_file_R} \
		# 							 ${fwhm} \
		# 							 ${output_file_R} \
		# 							 -fix-zeros


		# only for MASSIVE with connectome workbench version of 1.2.3
		# convert fwhm to sigma
		sigma=$(echo "scale=5;${fwhm}/sqrt(8*l(2))" | bc -l);

		wb_command -metric-smoothing ${sphere} \
									 ${input_file} \
									 ${sigma} \
									 ${output_file} \
									 -fix-zeros

	
	done
	fi
done < $filename
