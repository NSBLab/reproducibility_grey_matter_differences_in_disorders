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

# Extract data root and enabled datasets from config file using jq (JSON processor)
# If jq is not available, we'll use a simple grep approach
if command -v jq &> /dev/null; then
    echo "Using jq to parse JSON config..."
    DATA_ROOT=$(jq -r '.data_directories.dataset_root' "$CONFIG_FILE")
    HPC_ENABLED=$(jq -r '.execution_mode.hpc_enabled' "$CONFIG_FILE")
else
    echo "jq not available, using grep to parse JSON config..."
    # Extract data root using grep and sed
    DATA_ROOT=$(grep '"dataset_root"' "$CONFIG_FILE" | sed 's/.*"dataset_root": *"\([^\"]*\)".*/\1/')
    HPC_ENABLED=$(jq -r '.execution_mode.hpc_enabled' "$CONFIG_FILE")
fi

# Check if we got the data root
if [ -z "$DATA_ROOT" ]; then
    echo "Error: Could not extract data root from configuration!"
    exit 1
fi

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

echo "Using dataset list: $ENABLED_DATASETS_FILE"

echo "Data root: $DATA_ROOT"
echo "Found enabled datasets:"
cat "$ENABLED_DATASETS_FILE"

# Load visualization modules conditionally
if [ "$HPC_ENABLED" = "true" ]; then
    echo "Loading fsleyes modules (HPC mode enabled)..."
    module load fsleyes
else
    echo "Skipping module loading (HPC mode disabled)..."
fi


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
    # Get list of subjects that passed CAT12 QC
    CAT12_PASSED_FILE="$DATASET_DIR/subjects_cat12_passed.txt"
    if [ ! -f "$CAT12_PASSED_FILE" ]; then
        echo "Warning: CAT12 passed subjects file $CAT12_PASSED_FILE not found, skipping dataset $DATASET"
        echo "Please run step1b first to generate CAT12 QC results."
        continue
    fi

	# Prefer re-rendering only subjects that were missing in the previous run
	RENDER_SUBJECTS_FILE="$CAT12_PASSED_FILE"
	PREV_P0_MISSING_FILE="$OUT_DIR/subjects_missing_p0.txt"

	if [ -f "$PREV_P0_MISSING_FILE" ]; then
		echo "Found previous missing list: $PREV_P0_MISSING_FILE"

		TEMP_MISSING_FILE="$OUT_DIR/temp_missing_cat12_passed.txt"
		comm -12 <(sort "$PREV_P0_MISSING_FILE") <(sort "$CAT12_PASSED_FILE") > "$TEMP_MISSING_FILE"

	    RENDER_SUBJECTS_FILE="$TEMP_MISSING_FILE"

	
	else
		echo "No previous missing-subjects list found. Using all CAT12 passed subjects."
		RENDER_SUBJECTS_FILE="$CAT12_PASSED_FILE"
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

		vglrun fsleyes render -of ${WORK_DIR}/${SUBJECT}_axial_MNI.png --scene lightbox --worldLoc -13.815606917778084 51.749865511037996 24.37217752776877 --displaySpace /usr/local/spm12/matlab2021a.r7771-v1/toolbox/cat12/templates_MNI152NLin2009cAsym/Template_0_GS.nii --zaxis 2 --sliceSpacing 0.10276155719456802 --zrange 0.29934306572835545 0.8393430656585062 --ncols 0 --nrows 0 --cursorWidth 1.0 --bgColour 0.0 0.0 0.0 --fgColour 1.0 1.0 1.0 --cursorColour 0.0 1.0 0.0 --colourBarLocation top --colourBarLabelSide top-left --colourBarSize 100.0 --labelSize 12 --performance 3 /usr/local/spm12/matlab2021a.r7771-v1/toolbox/cat12/templates_MNI152NLin2009cAsym/Template_0_GS.nii --name "Template_0_GS" --overlayType volume --alpha 100.0 --brightness 49.74999999999999 --contrast 49.90029860765409 --cmap greyscale --negativeCmap greyscale --displayRange 0.0 1.009984588623047 --clippingRange 0.0 1.009984588623047 --modulateRange 0.0 0.9999847412109375 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 60 --blendFactor 0.3 --smoothing 0 --resolution 70 --numInnerSteps 10 --clipMode intersection --volume 0 ${FILENAMEMWDIR} --name ${FILENAMEMW} --overlayType volume --alpha 100.0 --cmap red-yellow --negativeCmap greyscale --useNegativeCmap --displayRange 0.1 1.0 --clippingRange 0.1 1.4580326879024506 --modulateRange 0.0 1.4435967206954956 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 60 --blendFactor 0.3 --smoothing 0 --resolution 70 --numInnerSteps 10 --clipMode intersection --volume 0

		vglrun fsleyes render -of ${WORK_DIR}/${SUBJECT}_sagittal_MNI.png --scene lightbox --worldLoc -13.815606917778084 51.749865511037996 24.37217752776877 --displaySpace /usr/local/spm12/matlab2021a.r7771-v1/toolbox/cat12/templates_MNI152NLin2009cAsym/Template_0_GS.nii --zaxis 0 --sliceSpacing 0.10276155719456802 --zrange 0.29934306572835545 0.8393430656585062 --ncols 0 --nrows 0 --cursorWidth 1.0 --bgColour 0.0 0.0 0.0 --fgColour 1.0 1.0 1.0 --cursorColour 0.0 1.0 0.0 --colourBarLocation top --colourBarLabelSide top-left --colourBarSize 100.0 --labelSize 12 --performance 3 /usr/local/spm12/matlab2021a.r7771-v1/toolbox/cat12/templates_MNI152NLin2009cAsym/Template_0_GS.nii --name "Template_0_GS" --overlayType volume --alpha 100.0 --brightness 49.74999999999999 --contrast 49.90029860765409 --cmap greyscale --negativeCmap greyscale --displayRange 0.0 1.009984588623047 --clippingRange 0.0 1.009984588623047 --modulateRange 0.0 0.9999847412109375 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 60 --blendFactor 0.3 --smoothing 0 --resolution 70 --numInnerSteps 10 --clipMode intersection --volume 0 ${FILENAMEMWDIR} --name ${FILENAMEMW} --overlayType volume --alpha 100.0 --cmap red-yellow --negativeCmap greyscale --useNegativeCmap --displayRange 0.1 1.0 --clippingRange 0.1 1.4580326879024506 --modulateRange 0.0 1.4435967206954956 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 60 --blendFactor 0.3 --smoothing 0 --resolution 70 --numInnerSteps 10 --clipMode intersection --volume 0

		vglrun fsleyes render -of ${WORK_DIR}/${SUBJECT}_coronal_MNI.png --scene lightbox --worldLoc -13.815606917778084 51.749865511037996 24.37217752776877 --displaySpace /usr/local/spm12/matlab2021a.r7771-v1/toolbox/cat12/templates_MNI152NLin2009cAsym/Template_0_GS.nii --zaxis 1 --sliceSpacing 0.08475952426401523 --zrange 0.29934306572835545 0.8393430656585062 --ncols 0 --nrows 0 --cursorWidth 1.0 --bgColour 0.0 0.0 0.0 --fgColour 1.0 1.0 1.0 --cursorColour 0.0 1.0 0.0 --colourBarLocation top --colourBarLabelSide top-left --colourBarSize 100.0 --labelSize 12 --performance 3 /usr/local/spm12/matlab2021a.r7771-v1/toolbox/cat12/templates_MNI152NLin2009cAsym/Template_0_GS.nii --name "Template_0_GS" --overlayType volume --alpha 100.0 --brightness 49.74999999999999 --contrast 49.90029860765409 --cmap greyscale --negativeCmap greyscale --displayRange 0.0 1.009984588623047 --clippingRange 0.0 1.009984588623047 --modulateRange 0.0 0.9999847412109375 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 60 --blendFactor 0.3 --smoothing 0 --resolution 70 --numInnerSteps 10 --clipMode intersection --volume 0 ${FILENAMEMWDIR} --name ${FILENAMEMW} --overlayType volume --alpha 100.0 --cmap red-yellow --negativeCmap greyscale --useNegativeCmap --displayRange 0.1 1.0 --clippingRange 0.1 1.4580326879024506 --modulateRange 0.0 1.4435967206954956 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 60 --blendFactor 0.3 --smoothing 0 --resolution 70 --numInnerSteps 10 --clipMode intersection --volume 0
        
	    done < "$RENDER_SUBJECTS_FILE"

	echo "Extract brain maps for visualisation completed!"


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

	# Evaluate existence per subject (only for CAT12 passed subjects)
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
	done < "$CAT12_PASSED_FILE"

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

	# Clean up temporary files
	#rm -f "$OUT_DIR/temp_missing_cat12_passed.txt"
    
done < "$ENABLED_DATASETS_FILE"




