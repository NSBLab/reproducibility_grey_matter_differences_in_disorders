#!/bin/bash

# Get script directory (same directory as this script file)
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
    echo "Error: jq is required to parse config file in step1a."
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

HPC_ENABLED=$(jq -r '.execution_mode.hpc_enabled' "$CONFIG_FILE")
if [ -z "$HPC_ENABLED" ] || [ "$HPC_ENABLED" = "null" ]; then
    echo "Error: Could not read execution_mode.hpc_enabled from $CONFIG_FILE"
    exit 1
fi

echo "Using HPC_ENABLED from config: $HPC_ENABLED"

echo "Data root: $DATA_ROOT"
echo "Found enabled datasets:"
echo "$ENABLED_DATASETS"
echo "SCRIPT DIR: $SCRIPT_DIR"
echo "HPC_ENABLED: $HPC_ENABLED"

# Export DATA_ROOT so batch jobs can see it
export DATA_ROOT
export HPC_ENABLED

# Process each enabled dataset
while IFS= read -r DATASET; do
    [ -z "$DATASET" ] && continue
    echo "Processing dataset: $DATASET"
    
    # Check if dataset directory exists
    DATASET_DIR="$DATA_ROOT/$DATASET"
    if [ ! -d "$DATASET_DIR" ]; then
        echo "Warning: Dataset directory $DATASET_DIR not found, skipping..."
        continue
    fi
    
    # Resolve subject list for dataset from config, fallback to dataset/subject_use.txt
    SUBJECTS_FILE=$(jq -r --arg ds "$DATASET" '.datasets[$ds].subject_list_file // empty' "$CONFIG_FILE")
    if [ -n "$SUBJECTS_FILE" ]; then
        if [[ "$SUBJECTS_FILE" != /* ]]; then
            SUBJECTS_FILE="$DATASET_DIR/$SUBJECTS_FILE"
        fi
    else
        SUBJECTS_FILE="$DATASET_DIR/subject_use.txt"
    fi
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
        if [ ! -f "$FILENAME" ]; then
            echo "Submitting CAT12 job for subject: $SUBJECT"
            
            # Export variables for the job
            export i="$SUBJECT"
            export DATASET="$DATASET"
            
            # Submit SLURM job
            sbatch --job-name=CAT_${DATASET}_${SUBJECT} $SCRIPT_DIR/CAT12_preprocessing.sh
        else
           echo "CAT12 report already exists for subject $SUBJECT, skipping..."
       fi
        
    done < "$SUBJECTS_FILE"
    
done <<< "$ENABLED_DATASETS"

echo "CAT12 preprocessing job submission completed!"
echo "Datasets were read from config: $CONFIG_FILE"
