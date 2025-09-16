#!/bin/bash

if [ -z "$DATA_ROOT" ]; then echo "Error: DATA_ROOT not set"; exit 1; fi

for dataset in `cat "$DATA_ROOT/dataset_list_VBM.txt"`; do

	#dataset=Specificity
	echo ${dataset}
	cd "$DATA_ROOT/$dataset/" || continue

	for sub in `cat subject_use.txt`; do

		if [ -z "$ses" ]
		then
			filename=$sub
			address=${sub}
		else
			ls "$DATA_ROOT/$dataset/${sub}" > temp.txt #list all the sessions
			ses=$(sed '1q;d' temp.txt) #choose the first session
			address=${sub}/${ses}
			echo $address
			filename=${sub}_${ses}
		fi

		cd "$DATA_ROOT/$dataset/${address}/anat/" || continue
		if [ -f "$DATA_ROOT/$dataset/${address}/anat/mwp1${filename}_T1w.nii" ]; then
			echo ${i}

			file=$(sed -n '21p' cat_${filename}_T1w.xml)
			search="_"
			prefix=${file%%$search*}
			file=${file:12:${#prefix}-12}

			iqr=$(grep -n "<IQR>" cat_${filename}_T1w.xml )
			iqr=${iqr:15:7}

			printf "\n${sub}\t${iqr}\t${ses}" >> "$DATA_ROOT/$dataset/cat12_qcReport_$dataset.txt"
		fi
	done

done

rm -f temp.txt

