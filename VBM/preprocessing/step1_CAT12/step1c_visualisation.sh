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
				FILENAME="${SUBJECT}_${SES}_T1w"
				FILENAMEP="p0${SUBJECT}_${SES}_T1w"
				FILENAMEMW="mwp1${SUBJECT}_${SES}_T1w"
				FILEDIR="$DATASET_DIR/$SUBJECT/$SES/anat/${FILENAME}.nii"
				FILENAMEPDIR="$DATASET_DIR/$SUBJECT/$SES/anat/${FILENAMEP}.nii"
				FILENAMEMWDIR="$DATASET_DIR/$SUBJECT/$SES/anat/${FILENAMEMW}.nii"
            else
                # Single session or no session structure
                unset ses
                FILENAME="${SUBJECT}_T1w"
				FILENAMEP="p0${SUBJECT}_T1w"
				FILENAMEMW="mwp1${SUBJECT}_T1w"
				FILEDIR="$DATASET_DIR/$SUBJECT/anat/${FILENAME}.nii"
				FILENAMEPDIR="$DATASET_DIR/$SUBJECT/anat/${FILENAMEP}.nii"
				FILENAMEMWDIR="$DATASET_DIR/$SUBJECT/anat/${FILENAMEMW}.nii"
            fi
        else
            echo "Warning: Subject directory $SUBJECT_DIR not found, skipping subject $SUBJECT"
            continue
        fi
      
		vglrun fsleyes render -of ${WORK_DIR}/${SUBJECT}_sagittal.png --scene lightbox --worldLoc -37.618811046128485 97.54446978672274 -111.61453709510579 --displaySpace world --zaxis 0 --sliceSpacing 0.15905198273677998 --zrange 0.19439549614028262 0.9896554098241824 --ncols 0 --nrows 0 --cursorWidth 1.0 --bgColour 1.0 1.0 1.0 --fgColour 0.0 0.0 0.0 --cursorColour 0.0 1.0 0.0 --colourBarLocation top --colourBarLabelSide top-left --colourBarSize 100.0 --labelSize 12 --performance 3 $FILEDIR --name $FILENAME --overlayType volume --alpha 64.66666666433836 --brightness 53.333333333333336 --contrast 49.90029860765409 --cmap greyscale --negativeCmap greyscale --displayRange -293.47499999999945 3842.4749999999995 --clippingRange -293.47499999999945 4135.95 --modulateRange 0.0 4095.0 --gamma 0.0 --channel R --cmapResolution 256 --interpolation none --numSteps 60 --blendFactor 0.3 --smoothing 0 --resolution 70 --numInnerSteps 10 --clipMode intersection --volume 0 $FILENAMEPDIR --name $FILENAMEP --overlayType label --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --lut random --outline --outlineWidth 1 --volume 0

		vglrun fsleyes render -of ${WORK_DIR}/${SUBJECT}_axial.png --scene lightbox --worldLoc -37.618811046128485 97.54446978672274 -111.61453709510579 --displaySpace world --zaxis 2 --sliceSpacing 0.10338317216073334 --zrange 0.19439549614028262 0.9896554098241824 --ncols 0 --nrows 0 --cursorWidth 1.0 --bgColour 1.0 1.0 1.0 --fgColour 0.0 0.0 0.0 --cursorColour 0.0 1.0 0.0 --colourBarLocation top --colourBarLabelSide top-left --colourBarSize 100.0 --labelSize 12 --performance 3 $FILEDIR --name $FILENAME --overlayType volume --alpha 64.66666666433836 --brightness 53.333333333333336 --contrast 49.90029860765409 --cmap greyscale --negativeCmap greyscale --displayRange -293.47499999999945 3842.4749999999995 --clippingRange -293.47499999999945 4135.95 --modulateRange 0.0 4095.0 --gamma 0.0 --channel R --cmapResolution 256 --interpolation none --numSteps 60 --blendFactor 0.3 --smoothing 0 --resolution 70 --numInnerSteps 10 --clipMode intersection --volume 0 $FILENAMEPDIR --name $FILENAMEP --overlayType label --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --lut random --outline --outlineWidth 1 --volume 0

		vglrun fsleyes render -of ${WORK_DIR}/${SUBJECT}_coronal.png --scene lightbox --worldLoc -37.618811046128485 97.54446978672274 -111.61453709510579 --displaySpace world --zaxis 1 --sliceSpacing 0.11027538574145222 --zrange 0.19439549614028262 0.9896554098241824 --ncols 0 --nrows 0 --cursorWidth 1.0 --bgColour 1.0 1.0 1.0 --fgColour 0.0 0.0 0.0 --cursorColour 0.0 1.0 0.0 --colourBarLocation top --colourBarLabelSide top-left --colourBarSize 100.0 --labelSize 12 --performance 3 $FILEDIR --name $FILENAME --overlayType volume --alpha 64.66666666433836 --brightness 53.333333333333336 --contrast 49.90029860765409 --cmap greyscale --negativeCmap greyscale --displayRange -293.47499999999945 3842.4749999999995 --clippingRange -293.47499999999945 4135.95 --modulateRange 0.0 4095.0 --gamma 0.0 --channel R --cmapResolution 256 --interpolation none --numSteps 60 --blendFactor 0.3 --smoothing 0 --resolution 70 --numInnerSteps 10 --clipMode intersection --volume 0 $FILENAMEPDIR --name $FILENAMEP --overlayType label --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --lut random --outline --outlineWidth 1 --volume 0

		#vglrun fsleyes render -of ${WORK_DIR}/${SUBJECT}_axial_MNI.png --scene lightbox --worldLoc -13.815606917778084 51.749865511037996 24.37217752776877 --displaySpace /usr/local/spm12/matlab2021a.r7771-v1/toolbox/cat12/templates_MNI152NLin2009cAsym/Template_0_GS.nii --zaxis 2 --sliceSpacing 0.10276155719456802 --zrange 0.29934306572835545 0.8393430656585062 --ncols 0 --nrows 0 --cursorWidth 1.0 --bgColour 0.0 0.0 0.0 --fgColour 1.0 1.0 1.0 --cursorColour 0.0 1.0 0.0 --colourBarLocation top --colourBarLabelSide top-left --colourBarSize 100.0 --labelSize 12 --performance 3 /usr/local/spm12/matlab2021a.r7771-v1/toolbox/cat12/templates_MNI152NLin2009cAsym/Template_0_GS.nii --name "Template_0_GS" --overlayType volume --alpha 100.0 --brightness 49.74999999999999 --contrast 49.90029860765409 --cmap greyscale --negativeCmap greyscale --displayRange 0.0 1.009984588623047 --clippingRange 0.0 1.009984588623047 --modulateRange 0.0 0.9999847412109375 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 60 --blendFactor 0.3 --smoothing 0 --resolution 70 --numInnerSteps 10 --clipMode intersection --volume 0 ${FILENAMEMWDIR} --name ${FILENAMEMW} --overlayType volume --alpha 100.0 --cmap red-yellow --negativeCmap greyscale --useNegativeCmap --displayRange 0.1 1.0 --clippingRange 0.1 1.4580326879024506 --modulateRange 0.0 1.4435967206954956 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 60 --blendFactor 0.3 --smoothing 0 --resolution 70 --numInnerSteps 10 --clipMode intersection --volume 0

		#vglrun fsleyes render -of ${WORK_DIR}/${SUBJECT}_sagittal_MNI.png --scene lightbox --worldLoc -13.815606917778084 51.749865511037996 24.37217752776877 --displaySpace /usr/local/spm12/matlab2021a.r7771-v1/toolbox/cat12/templates_MNI152NLin2009cAsym/Template_0_GS.nii --zaxis 0 --sliceSpacing 0.10276155719456802 --zrange 0.29934306572835545 0.8393430656585062 --ncols 0 --nrows 0 --cursorWidth 1.0 --bgColour 0.0 0.0 0.0 --fgColour 1.0 1.0 1.0 --cursorColour 0.0 1.0 0.0 --colourBarLocation top --colourBarLabelSide top-left --colourBarSize 100.0 --labelSize 12 --performance 3 /usr/local/spm12/matlab2021a.r7771-v1/toolbox/cat12/templates_MNI152NLin2009cAsym/Template_0_GS.nii --name "Template_0_GS" --overlayType volume --alpha 100.0 --brightness 49.74999999999999 --contrast 49.90029860765409 --cmap greyscale --negativeCmap greyscale --displayRange 0.0 1.009984588623047 --clippingRange 0.0 1.009984588623047 --modulateRange 0.0 0.9999847412109375 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 60 --blendFactor 0.3 --smoothing 0 --resolution 70 --numInnerSteps 10 --clipMode intersection --volume 0 ${FILENAMEMWDIR} --name ${FILENAMEMW} --overlayType volume --alpha 100.0 --cmap red-yellow --negativeCmap greyscale --useNegativeCmap --displayRange 0.1 1.0 --clippingRange 0.1 1.4580326879024506 --modulateRange 0.0 1.4435967206954956 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 60 --blendFactor 0.3 --smoothing 0 --resolution 70 --numInnerSteps 10 --clipMode intersection --volume 0

		#vglrun fsleyes render -of ${WORK_DIR}/${SUBJECT}_coronal_MNI.png --scene lightbox --worldLoc -13.815606917778084 51.749865511037996 24.37217752776877 --displaySpace /usr/local/spm12/matlab2021a.r7771-v1/toolbox/cat12/templates_MNI152NLin2009cAsym/Template_0_GS.nii --zaxis 1 --sliceSpacing 0.08475952426401523 --zrange 0.29934306572835545 0.8393430656585062 --ncols 0 --nrows 0 --cursorWidth 1.0 --bgColour 0.0 0.0 0.0 --fgColour 1.0 1.0 1.0 --cursorColour 0.0 1.0 0.0 --colourBarLocation top --colourBarLabelSide top-left --colourBarSize 100.0 --labelSize 12 --performance 3 /usr/local/spm12/matlab2021a.r7771-v1/toolbox/cat12/templates_MNI152NLin2009cAsym/Template_0_GS.nii --name "Template_0_GS" --overlayType volume --alpha 100.0 --brightness 49.74999999999999 --contrast 49.90029860765409 --cmap greyscale --negativeCmap greyscale --displayRange 0.0 1.009984588623047 --clippingRange 0.0 1.009984588623047 --modulateRange 0.0 0.9999847412109375 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 60 --blendFactor 0.3 --smoothing 0 --resolution 70 --numInnerSteps 10 --clipMode intersection --volume 0 ${FILENAMEMWDIR} --name ${FILENAMEMW} --overlayType volume --alpha 100.0 --cmap red-yellow --negativeCmap greyscale --useNegativeCmap --displayRange 0.1 1.0 --clippingRange 0.1 1.4580326879024506 --modulateRange 0.0 1.4435967206954956 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 60 --blendFactor 0.3 --smoothing 0 --resolution 70 --numInnerSteps 10 --clipMode intersection --volume 0
        
    done < "$SUBJECTS_FILE"

	echo "Extract brain maps for visualisation completed!"


	cd ${WORK_DIR}

	convert $(sed 's/$/_sagittal.png/' "$SUBJECTS_FILE") -resize 800x1800 ${OUT_DIR}/sagittal_${DATASET}_p0.pdf
	convert $(sed 's/$/_axial.png/' "$SUBJECTS_FILE") -resize 800x1800 ${OUT_DIR}/axial_${DATASET}_p0.pdf
	convert $(sed 's/$/_coronal.png/' "$SUBJECTS_FILE") -resize 800x1800 ${OUT_DIR}/coronal_${DATASET}_p0.pdf
	convert $(sed 's/$/_sagittal_MNI.png/' "$SUBJECTS_FILE") -resize 800x1800 ${OUT_DIR}/sagittal_${DATASET}_mw.pdf
	convert $(sed 's/$/_axial_MNI.png/' "$SUBJECTS_FILE") -resize 800x1800 ${OUT_DIR}/axial_${DATASET}_mw.pdf
	convert $(sed 's/$/_coronal_MNI.png/' "$SUBJECTS_FILE") -resize 800x1800 ${OUT_DIR}/coronal_${DATASET}_mw.pdf
    
done < "$ENABLED_DATASETS_FILE"




