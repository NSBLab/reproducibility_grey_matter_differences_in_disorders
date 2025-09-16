#!/bin/bash

#ses=ses-1

#if [ -z "$ses" ]
#then
#	datalist=dataset_list1
#else
#	datalist=dataset_list_ses
#fi
#
for dataset in `cat /projects/kg98/trangc/VBM/data/dataset_list1.txt`; do

	#dataset=Specificity
	echo ${dataset}
	cd /projects/kg98/trangc/VBM/data/$dataset/

	for sub in `cat subject_use.txt`; do

		if [ -z "$ses" ]
		then
			filename=$sub
			address=${sub}
		else

			ls /projects/kg98/trangc/VBM/data/$dataset/${sub} > temp.txt #list all the sessions
			ses=$(sed '1q;d' temp.txt) #choose the first session
			
			
			address=${sub}/${ses}
			echo $address
			filename=${sub}_${ses}
		fi

		cd /projects/kg98/trangc/VBM/data/$dataset/${address}/anat/
		if [ -f /projects/kg98/trangc/VBM/data/$dataset/${address}/anat/mwp1${filename}_T1w.nii ]; then
			echo ${i}

			file=$(sed -n '21p' cat_${filename}_T1w.xml) 
			search="_"
			prefix=${file%%$search*}
			file=${file:12:${#prefix}-12}

			iqr=$(grep -n "<IQR>" cat_${filename}_T1w.xml )
			iqr=${iqr:15:7}

			#cd /home/asegal/kg98_scratch/Ashlea/datadir/$dataset/derivatives/
			#printf "\n$i\t$iqr" >> /scratch/kg98/Ashlea/datadir/$dataset/derivatives/cat12_qcReport_$dataset.txt 
			printf "\n${sub}\t${iqr}\t${ses}" >> /projects/kg98/trangc/VBM/data/$dataset/cat12_qcReport_$dataset.txt 
		fi
	done

done

