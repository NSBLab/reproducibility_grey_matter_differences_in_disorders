#!/bin/bash

# Concatenates CAT12 QC; writes subjects_cat12_passed.txt per dataset. After step1c, copy that file to
# subjects_pass_visualisation.txt and delete excluded IDs before VBM step 2 extract.
export SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# Resolve CONFIG_FILE from env or sensible defaults
if [ -z "$CONFIG_FILE" ]; then
    REPO_ROOT=$(cd "$SCRIPT_DIR/../../.." && pwd)
    if [ -f "$REPO_ROOT/config_hpc.json" ]; then
        CONFIG_FILE="$REPO_ROOT/config_hpc.json"
    elif [ -f "$REPO_ROOT/config.json" ]; then
        CONFIG_FILE="$REPO_ROOT/config.json"
    elif [ -f "config_hpc.json" ]; then
        CONFIG_FILE="config_hpc.json"
    elif [ -f "config.json" ]; then
        CONFIG_FILE="config.json"
    else
        echo "Error: CONFIG_FILE not set and no default config found."
        echo "Checked: $REPO_ROOT/config_hpc.json, $REPO_ROOT/config.json, ./config_hpc.json, ./config.json"
        exit 1
    fi
fi

echo "Using CONFIG_FILE: $CONFIG_FILE"

if ! command -v jq >/dev/null 2>&1; then
    echo "Error: jq is required to parse config file in step1b."
    exit 1
fi

DATA_ROOT=$(jq -r '.data_directories.dataset_root' "$CONFIG_FILE")
if [ -z "$DATA_ROOT" ] || [ "$DATA_ROOT" = "null" ]; then
    echo "Error: Could not read data_directories.dataset_root from $CONFIG_FILE"
    exit 1
fi

ENABLED_DATASETS=$(jq -r '.datasets | to_entries[] | select(.value.enabled == true) | .key' "$CONFIG_FILE")
if [ -z "$ENABLED_DATASETS" ]; then
    echo "Error: No enabled datasets found in $CONFIG_FILE"
    exit 1
fi

echo "Data root: $DATA_ROOT"
echo "Found enabled datasets:"
echo "$ENABLED_DATASETS"

# Process each enabled dataset
while IFS= read -r dataset; do
    [ -z "$dataset" ] && continue

	echo ${dataset}
	sleep 1
	cd "$DATA_ROOT/$dataset/" || continue
	rm -f "$DATA_ROOT/$dataset/cat12_qcReport_${dataset}.txt"
	rm -f "$DATA_ROOT/$dataset/subjects_cat12_passed.txt"
	rm -f "$DATA_ROOT/$dataset/subjects_cat12_failed.txt"

	# CAT12 IQR threshold (adjust as needed)
	IQR_THRESHOLD=2.8

	SUBJECTS_FILE=$(jq -r --arg ds "$dataset" '.datasets[$ds].subject_list_file // empty' "$CONFIG_FILE")
	if [ -n "$SUBJECTS_FILE" ]; then
		if [[ "$SUBJECTS_FILE" != /* ]]; then
			SUBJECTS_FILE="$DATA_ROOT/$dataset/$SUBJECTS_FILE"
		fi
	else
		SUBJECTS_FILE="$DATA_ROOT/$dataset/subject_use.txt"
	fi

	if [ ! -f "$SUBJECTS_FILE" ]; then
		echo "Warning: Subject list file $SUBJECTS_FILE not found, skipping dataset $dataset"
		continue
	fi

	for sub in $(cat "$SUBJECTS_FILE"); do

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

done <<< "$ENABLED_DATASETS"

rm -f temp.txt

