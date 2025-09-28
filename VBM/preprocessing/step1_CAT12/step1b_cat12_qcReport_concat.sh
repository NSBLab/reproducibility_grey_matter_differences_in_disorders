#!/bin/bash

# Read the configuration file to get enabled datasets
# Use CONFIG_FILE environment variable passed from MATLAB
if [ -z "$CONFIG_FILE" ]; then
    echo "Error: CONFIG_FILE environment variable not set"
    echo "Please ensure the pipeline sets the CONFIG_FILE environment variable."
    exit 1
fi
echo "Using config file passed from MATLAB: $CONFIG_FILE"

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file $CONFIG_FILE not found!"
    exit 1
fi

# Extract data root from config file using jq (JSON processor)
# If jq is not available, we'll use a simple grep approach
if command -v jq &> /dev/null; then
    echo "Using jq to parse JSON config..."
    DATA_ROOT=$(jq -r '.data_directories.dataset_root' "$CONFIG_FILE")
else
    echo "jq not available, using grep to parse JSON config..."
    # Extract data root using grep and sed
    DATA_ROOT=$(grep '"dataset_root"' "$CONFIG_FILE" | sed 's/.*"dataset_root": *"\([^\"]*\)".*/\1/')
fi

# Check if we got the data root
if [ -z "$DATA_ROOT" ]; then
    echo "Error: Could not extract data root from configuration!"
    exit 1
fi

# Check if dataset list file exists, if not create it from config
ENABLED_DATASETS_FILE="$DATA_ROOT/dataset_list_step1b.txt"

if [ ! -f "$ENABLED_DATASETS_FILE" ]; then
    echo "Dataset list not found, extracting from config..."
    
    if command -v jq &> /dev/null; then
        echo "Using jq to extract enabled datasets..."
        # Use jq to extract dataset names where enabled == true
        jq -r '.datasets | to_entries[] | select(.value.enabled == true) | .key' "$CONFIG_FILE" > "$ENABLED_DATASETS_FILE"
    else
        echo "jq not available, using grep/sed to extract enabled datasets..."
        # Extract enabled datasets using grep and sed (more complex but works without jq)
        # This approach looks for dataset blocks with "enabled": true
        grep -A 20 '"datasets"' "$CONFIG_FILE" | \
        grep -B 5 -A 15 '"enabled": *true' | \
        grep '"[^"]*":' | \
        sed 's/.*"\([^"]*\)":.*/\1/' | \
        grep -v 'datasets\|enabled' > "$ENABLED_DATASETS_FILE" || true
    fi
    
    # Check if we found any enabled datasets
    if [ ! -s "$ENABLED_DATASETS_FILE" ]; then
        echo "Error: No enabled datasets found in configuration!"
        exit 1
    fi
    
    echo "Created dataset list: $ENABLED_DATASETS_FILE"
else
    echo "Using existing dataset list: $ENABLED_DATASETS_FILE"
fi

echo "Data root: $DATA_ROOT"
echo "Found enabled datasets:"
cat "$ENABLED_DATASETS_FILE"

for dataset in `cat "$ENABLED_DATASETS_FILE"`; do

	echo ${dataset}
	cd "$DATA_ROOT/$dataset/" || continue
	rm -f "$DATA_ROOT/$dataset/cat12_qcReport_${dataset}.txt"
	rm -f "$DATA_ROOT/$dataset/subjects_cat12_passed.txt"
	rm -f "$DATA_ROOT/$dataset/subjects_cat12_failed.txt"

	# CAT12 IQR threshold (adjust as needed)
	IQR_THRESHOLD=2.8

	for sub in `cat subject_use.txt`; do

		# Auto-detect session directories for this subject (do not rely on external $ses)
		first_ses_dir=$(find "$DATA_ROOT/$dataset/${sub}" -maxdepth 1 -type d -name "ses-*" | head -1)
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

			printf "\n${sub}\t${iqr}\t${ses}" >> "$DATA_ROOT/$dataset/cat12_qcReport_$dataset.txt"
			
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

done

rm -f temp.txt

