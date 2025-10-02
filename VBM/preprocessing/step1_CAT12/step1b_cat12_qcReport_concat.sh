#!/bin/bash

# Get script directory (same directory as this script file)
export SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# Use environment variables passed from MATLAB
if [ -z "$DATA_ROOT" ]; then
    echo "Error: DATA_ROOT environment variable not set"
    echo "Please ensure the pipeline sets the DATA_ROOT environment variable."
    exit 1
fi

echo "Using DATA_ROOT from environment: $DATA_ROOT"

# Get enabled datasets file path from environment variable
if [ -z "$ENABLED_DATASETS_FILE" ]; then
    echo "Error: ENABLED_DATASETS_FILE environment variable not set"
    echo "Please ensure the pipeline sets the ENABLED_DATASETS_FILE environment variable."
    exit 1
fi

# Check if the dataset list file exists
if [ ! -f "$ENABLED_DATASETS_FILE" ]; then
    echo "Error: Dataset list file not found: $ENABLED_DATASETS_FILE"
    exit 1
fi

# Check if the file has any content
if [ ! -s "$ENABLED_DATASETS_FILE" ]; then
    echo "Error: Dataset list file is empty: $ENABLED_DATASETS_FILE"
    exit 1
fi

echo "Data root: $DATA_ROOT"
echo "Created persistent dataset list: $ENABLED_DATASETS_FILE"
echo "Found enabled datasets:"
cat "$ENABLED_DATASETS_FILE"

# Process each enabled dataset
while IFS= read -r dataset; do

	echo ${dataset}
	sleep 1
	cd "$DATA_ROOT/$dataset/" || continue
	rm -f "$DATA_ROOT/$dataset/cat12_qcReport_${dataset}.txt"
	rm -f "$DATA_ROOT/$dataset/subjects_cat12_passed.txt"
	rm -f "$DATA_ROOT/$dataset/subjects_cat12_failed.txt"

	# CAT12 IQR threshold (adjust as needed)
	IQR_THRESHOLD=2.8

	for sub in `cat subject_use.txt`; do

		# Auto-detect session directories for this subject (do not rely on external $ses)
		first_ses_dir=$(find "$DATA_ROOT/$dataset/${sub}" -maxdepth 1 -type d -name "ses-*" | sort -V | head -1)
		if [ -n "$first_ses_dir" ]; then
			ses=$(basename "$first_ses_dir")
			
			address=${sub}/${ses}
			echo $address
			filename=${sub}_${ses}
		else
			unset ses
			filename=$sub
			address=${sub}
			echo $address
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
			echo $iqr

			printf "\n${sub}\t${iqr}\t${ses}" >> "$DATA_ROOT/$dataset/cat12_qcReport_${dataset}.txt"
			
			# Check if IQR passes threshold
			if (( $(echo "$iqr <= $IQR_THRESHOLD" | bc -l) )); then
				echo "$sub" >> "$DATA_ROOT/$dataset/subjects_cat12_passed.txt"
			else
				echo "$sub" >> "$DATA_ROOT/$dataset/subjects_cat12_failed.txt"
			fi
		fi
	done

	echo "CAT12 QC completed for $dataset"
	echo "Passed subjects: $(wc -l < "$DATA_ROOT/$dataset/subjects_cat12_passed.txt" 2>/dev/null || echo 0)"
	echo "Failed subjects: $(wc -l < "$DATA_ROOT/$dataset/subjects_cat12_failed.txt" 2>/dev/null || echo 0)"

done < "$ENABLED_DATASETS_FILE"

rm -f temp.txt

