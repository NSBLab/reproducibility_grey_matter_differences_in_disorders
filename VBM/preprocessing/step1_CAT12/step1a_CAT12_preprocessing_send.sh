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

if [ -z "$HPC_ENABLED" ]; then
    echo "Error: HPC_ENABLED environment variable not set"
    echo "Please ensure the pipeline sets the HPC_ENABLED environment variable."
    exit 1
fi

echo "Using HPC_ENABLED from environment: $HPC_ENABLED"

echo "Data root: $DATA_ROOT"
echo "Created persistent dataset list: $ENABLED_DATASETS_FILE"
echo "Found enabled datasets:"
cat "$ENABLED_DATASETS_FILE"
echo "SCRIPT DIR: $SCRIPT_DIR"
echo "HPC_ENABLED: $HPC_ENABLED"

# Export DATA_ROOT so batch jobs can see it
export $DATA_ROOT
export $HPC_ENABLED

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
    
done < "$ENABLED_DATASETS_FILE"

echo "CAT12 preprocessing job submission completed!"
echo "Dataset list saved to: $ENABLED_DATASETS_FILE"
