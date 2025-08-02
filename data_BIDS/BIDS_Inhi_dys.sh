#!/bin/env bash

dataset=Inhi_dys
filename=$1
while read SUBJECTID; do
	#if [ ! -f /home/trangc/kg98/trangc/MultiSites/ASD_BD_MDD_SCZ_SRPBS_1600/data/${SUBJECTID}/t1/defaced_mprage.nii ] ; then
	#	echo ${SUBJECTID}
	#else
		#mkdir -p /home/trangc/kg98/trangc/VBM/data/${dataset}/sub-${SUBJECTID:1:3}/ses-${SUBJECTID:6:1}/anat
		#cp /home/trangc/kg98/trangc/MultiSites/ASD_Inhibitory_Dysfunction/image03/${SUBJECTID} /home/trangc/kg98/trangc/VBM/data/${dataset}/sub-${SUBJECTID:1:3}/ses-${SUBJECTID:6:1}/anat
		dcm2niix /home/trangc/kg98/trangc/VBM/data/${dataset}/sub-${SUBJECTID:1:3}/ses-${SUBJECTID:6:1}/anat/${SUBJECTID}
		mv /home/trangc/kg98/trangc/VBM/data/${dataset}/sub-${SUBJECTID:1:3}/ses-${SUBJECTID:6:1}/anat/*.nii /home/trangc/kg98/trangc/VBM/data/${dataset}/sub-${SUBJECTID:1:3}/ses-${SUBJECTID:6:1}/anat/sub-${SUBJECTID:1:3}_ses-${SUBJECTID:6:1}_T1w.nii
		#gzip -d /home/trangc/kg98/trangc/VBM/data/${dataset}/sub-${SUBJECTID:1:4}/anat/*_T1.nii.gz
		#ls /home/trangc/kg98/trangc/VBM/data/${dataset}/${SUBJECTID}/anat > temp.txt
		#anat=$(sed '1q;d' temp.txt)
		#mv /home/trangc/kg98/trangc/VBM/data/${dataset}/${SUBJECTID}/anat/sub-${SUBJECTID}_T1w.nii /home/trangc/kg98/trangc/VBM/data/${dataset}/${SUBJECTID}/anat/${SUBJECTID}_T1w.nii

#mv /home/trangc/kg98/trangc/VBM/data/Modul_vent/${SUBJECTID} /home/trangc/kg98/trangc/VBM/data/Modul_vent/${SUBJECTID:0:9}/ses-${SUBJECTID:11:1}
#mv /home/trangc/kg98/trangc/VBM/data/Modul_vent/${SUBJECTID:0:9}/ses-${SUBJECTID:11:1}/${SUBJECTID}/anat /home/trangc/kg98/trangc/VBM/data/Modul_vent/${SUBJECTID:0:9}/ses-${SUBJECTID:11:1}/anat
#rmdir /home/trangc/kg98/trangc/VBM/data/Modul_vent/${SUBJECTID:0:9}/ses-${SUBJECTID:11:1}/${SUBJECTID}
#mv /home/trangc/kg98/trangc/VBM/data/Modul_vent/${SUBJECTID:0:9}/ses-${SUBJECTID:11:1}/anat/${SUBJECTID}_T1w.nii /home/trangc/kg98/trangc/VBM/data/Modul_vent/${SUBJECTID:0:9}/ses-${SUBJECTID:11:1}/anat/${SUBJECTID:0:9}_ses-${SUBJECTID:11:1}_T1w.nii
#mv /home/trangc/kg98/trangc/VBM/data/Modul_vent/${SUBJECTID}/anat/${SUBJECTID}_T1w.nii /home/trangc/kg98/trangc/VBM/data/Modul_vent/${SUBJECTID}/anat/sub-${SUBJECTID:16:8}_T1w.nii

#fi
done < $filename
