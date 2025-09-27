#!/bin/bash

# Read the configuration file to get enabled datasets
# Use CONFIG_FILE environment variable if passed from MATLAB, otherwise use default
if [ -z "$CONFIG_FILE" ]; then
    export SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
    CONFIG_FILE="$SCRIPT_DIR/../../../config_hpc.json"
    echo "Using default config file: $CONFIG_FILE"
else
    echo "Using config file passed from MATLAB: $CONFIG_FILE"
fi

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

# Extract enabled datasets from config file and create persistent list
echo "Extracting enabled datasets from config..."

# Create persistent file for enabled datasets in data root
ENABLED_DATASETS_FILE="$DATA_ROOT/dataset_list_step1a.txt"

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

echo "Data root: $DATA_ROOT"
echo "Created persistent dataset list: $ENABLED_DATASETS_FILE"
echo "Found enabled datasets:"
cat "$ENABLED_DATASETS_FILE"

# Export DATA_ROOT so batch jobs can see it
export DATA_ROOT

# Process each enabled dataset
while IFS= read -r DATASET; do
    echo "Processing dataset: $DATASET"
    
    # Check if dataset directory exists
    DATASET_DIR="$DATA_ROOT/$DATASET"
    if [ ! -d "$DATASET_DIR" ]; then
        echo "Warning: Dataset directory $DATASET_DIR not found, skipping..."
        continue
    fi
    
    # Get list of subjects in the dataset
    SUBJECTS_FILE="$DATASET_DIR/subject_use.txt"
    if [ ! -f "$SUBJECTS_FILE" ]; then
        echo "Warning: Subject list file $SUBJECTS_FILE not found, skipping dataset $DATASET"
        continue
    fi
    
    # Process each subject
    while IFS= read -r SUBJECT; do
        # Skip empty lines
        if [ -z "$SUBJECT" ]; then
            continue
        fi
        
        echo "Processing subject: $SUBJECT"
        
        # Check if subject has multiple sessions
        SUBJECT_DIR="$DATASET_DIR/$SUBJECT"
        if [ -d "$SUBJECT_DIR" ]; then
            # Check if there are subdirectories (sessions)
            SESSION_DIRS=$(find "$SUBJECT_DIR" -maxdepth 1 -type d -name "ses-*" | head -1)
            
            if [ -n "$SESSION_DIRS" ]; then
                # Multiple sessions - use first session
                SES=$(basename "$SESSION_DIRS")
                export ses="$SES"
                FILENAME="$DATASET_DIR/$SUBJECT/$SES/anat/catreport_${SUBJECT}_${SES}_T1w.pdf"
            else
                # Single session or no session structure
                unset ses
                FILENAME="$DATASET_DIR/$SUBJECT/anat/catreport_${SUBJECT}_T1w.pdf"
            fi
        else
            echo "Warning: Subject directory $SUBJECT_DIR not found, skipping subject $SUBJECT"
            continue
        fi
        
        # Check if CAT12 report already exists
        #if [ ! -f "$FILENAME" ]; then
            echo "Submitting CAT12 job for subject: $SUBJECT"
            
            # Export variables for the job
            export i="$SUBJECT"
            export DATASET="$DATASET"
            
            # Submit SLURM job
            sbatch --job-name=CAT_${DATASET}_${SUBJECT} $SCRIPT_DIR/CAT12_preprocessing.sh
        #else
           # echo "CAT12 report already exists for subject $SUBJECT, skipping..."
       # fi
        
    done < "$SUBJECTS_FILE"
    
done < "$ENABLED_DATASETS_FILE"

echo "CAT12 preprocessing job submission completed!"
echo "Dataset list saved to: $ENABLED_DATASETS_FILE"
