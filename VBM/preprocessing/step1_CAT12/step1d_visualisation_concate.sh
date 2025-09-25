#!/bin/bash

# Read the configuration file to get enabled datasets
# Use CONFIG_FILE environment variable if passed from MATLAB, otherwise use default
if [ -z "$CONFIG_FILE" ]; then
    export SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
    CONFIG_FILE="$SCRIPT_DIR/../../../config.json"
    echo "Using default config file: $CONFIG_FILE"
else
    echo "Using config file passed from MATLAB: $CONFIG_FILE"
fi

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file $CONFIG_FILE not found!"
    exit 1
fi

# Extract data root and enabled datasets from config file using jq (JSON processor)
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
ENABLED_DATASETS_FILE="$DATA_ROOT/dataset_list_step1c.txt"

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

# Export DATA_ROOT so batch jobs can see it
export DATA_ROOT

# load visualisation package
#module purge
module load fsleyes

# Process each enabled dataset
while IFS= read -r DATASET; do
    echo "Processing dataset: $DATASET"
    
    # Check if dataset directory exists
    DATASET_DIR="$DATA_ROOT/$DATASET"
    if [ ! -d "$DATASET_DIR" ]; then
        echo "Warning: Dataset directory $DATASET_DIR not found, skipping..."
        continue
    fi
	OUT_DIR="$DATA_ROOT/$DATASET/derivatives/volume_visualisation" 
	WORK_DIR="$DATA_ROOT/$DATASET/derivatives/volume_visualisation/work"
    if [ ! -d $OUT_DIR ]; then mkdir -p $OUT_DIR; echo "making output directory"; fi
	if [ ! -d $WORK_DIR ]; then mkdir -p $WORK_DIR; echo "making work directory"; fi
    # Get list of subjects in the dataset
    SUBJECTS_FILE="$DATASET_DIR/subject_use.txt"
    if [ ! -f "$SUBJECTS_FILE" ]; then
        echo "Warning: Subject list file $SUBJECTS_FILE not found, skipping dataset $DATASET"
        continue
    fi

	# Prefer re-rendering only subjects that were missing in the previous run
	RENDER_SUBJECTS_FILE="$SUBJECTS_FILE"
	PREV_P0_MISSING_FILE="$OUT_DIR/subjects_missing_p0.txt"
	if [ -s "$PREV_P0_MISSING_FILE" ]; then
		echo "Found non-empty missing list from previous run: $PREV_P0_MISSING_FILE"
		RENDER_SUBJECTS_FILE="$PREV_P0_MISSING_FILE"
	else
		echo "No previous missing-subjects list found or it is empty. Using all subjects."
	fi
    
	cd ${WORK_DIR}

	# Build lists of subjects with existing/missing images in work dir
	P0_EXISTING_SUBS_FILE="${OUT_DIR}/subjects_existing_p0.txt"
	P0_MISSING_SUBS_FILE="${OUT_DIR}/subjects_missing_p0.txt"
	MW_EXISTING_SUBS_FILE="${OUT_DIR}/subjects_existing_mw.txt"
	MW_MISSING_SUBS_FILE="${OUT_DIR}/subjects_missing_mw.txt"

	# Reset lists
	: > "$P0_EXISTING_SUBS_FILE"
	: > "$P0_MISSING_SUBS_FILE"
	: > "$MW_EXISTING_SUBS_FILE"
	: > "$MW_MISSING_SUBS_FILE"

	# Evaluate existence per subject
	while IFS= read -r SUBJECT; do
		[ -z "$SUBJECT" ] && continue
		SAG_P0="${WORK_DIR}/${SUBJECT}_sagittal.png"
		AX_P0="${WORK_DIR}/${SUBJECT}_axial.png"
		COR_P0="${WORK_DIR}/${SUBJECT}_coronal.png"
		if [ -f "$SAG_P0" ] && [ -f "$AX_P0" ] && [ -f "$COR_P0" ]; then
			echo "$SUBJECT" >> "$P0_EXISTING_SUBS_FILE"
		else
			echo "$SUBJECT" >> "$P0_MISSING_SUBS_FILE"
		fi

		SAG_MW="${WORK_DIR}/${SUBJECT}_sagittal_MNI.png"
		AX_MW="${WORK_DIR}/${SUBJECT}_axial_MNI.png"
		COR_MW="${WORK_DIR}/${SUBJECT}_coronal_MNI.png"
		if [ -f "$SAG_MW" ] && [ -f "$AX_MW" ] && [ -f "$COR_MW" ]; then
			echo "$SUBJECT" >> "$MW_EXISTING_SUBS_FILE"
		else
			echo "$SUBJECT" >> "$MW_MISSING_SUBS_FILE"
		fi
	done < "$SUBJECTS_FILE"

	# Combine only existing images into PDFs
	if [ -s "$P0_EXISTING_SUBS_FILE" ]; then
		convert $(sed 's/$/_sagittal.png/' "$P0_EXISTING_SUBS_FILE") -resize 800x1800 ${OUT_DIR}/sagittal_${DATASET}_p0.pdf
		convert $(sed 's/$/_axial.png/' "$P0_EXISTING_SUBS_FILE") -resize 800x1800 ${OUT_DIR}/axial_${DATASET}_p0.pdf
		convert $(sed 's/$/_coronal.png/' "$P0_EXISTING_SUBS_FILE") -resize 800x1800 ${OUT_DIR}/coronal_${DATASET}_p0.pdf
	else
		echo "No existing p0 images found for dataset ${DATASET}; skipping p0 PDF creation."
	fi

	if [ -s "$MW_EXISTING_SUBS_FILE" ]; then
		convert $(sed 's/$/_sagittal_MNI.png/' "$MW_EXISTING_SUBS_FILE") -resize 800x1800 ${OUT_DIR}/sagittal_${DATASET}_mw.pdf
		convert $(sed 's/$/_axial_MNI.png/' "$MW_EXISTING_SUBS_FILE") -resize 800x1800 ${OUT_DIR}/axial_${DATASET}_mw.pdf
		convert $(sed 's/$/_coronal_MNI.png/' "$MW_EXISTING_SUBS_FILE") -resize 800x1800 ${OUT_DIR}/coronal_${DATASET}_mw.pdf
	else
		echo "No existing mw images found for dataset ${DATASET}; skipping mw PDF creation."
	fi
    
done < "$ENABLED_DATASETS_FILE"




