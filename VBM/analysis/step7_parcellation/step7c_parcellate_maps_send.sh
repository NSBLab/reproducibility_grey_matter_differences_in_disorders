#!/bin/bash

# Use environment variable for dataset list
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

export isses=1

echo "Processing datasets from file: $ENABLED_DATASETS_FILE"
echo "Found datasets:"
cat "$ENABLED_DATASETS_FILE"

for dataset in `cat ${ENABLED_DATASETS_FILE}`
do

export dataset=$dataset
	
		#sbatch --job-name=parc_${dataset} parcellate_maps.sh
		sh parcellate_maps.sh
	#fi 
done


