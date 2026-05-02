#!/bin/bash
# Renders volumes for manual QC (needs display). After review, copy subjects_cat12_passed.txt to
# subjects_pass_visualisation.txt in each dataset folder and remove excluded IDs before step 2 extract.

export SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

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

# Load visualization modules conditionally
if [ "$HPC_ENABLED" = "true" ]; then
    echo "Loading fsleyes modules (HPC mode enabled)..."
    module load fsleyes
else
    echo "Skipping module loading (HPC mode disabled)..."
fi


# Process each enabled dataset
for DATASET in $ENABLED_DATASETS; do
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

	# Only render subjects that don't already have p0 images
	echo "Checking for existing p0 images to avoid re-rendering..."
	TEMP_MISSING_P0_FILE="$OUT_DIR/temp_subjects_missing_p0.txt"
	: > "$TEMP_MISSING_P0_FILE"  # Clear the temp file
	
	# Check each CAT12 passed subject for existing p0 images
	while IFS= read -r SUBJECT; do
		[ -z "$SUBJECT" ] && continue
		
		# Check if p0 images already exist for this subject
		SAG_P0="${WORK_DIR}/${SUBJECT}_sagittal.png"
		AX_P0="${WORK_DIR}/${SUBJECT}_axial.png"
		COR_P0="${WORK_DIR}/${SUBJECT}_coronal.png"
		
		if [ -f "$SAG_P0" ] && [ -f "$AX_P0" ] && [ -f "$COR_P0" ]; then
			echo "Subject $SUBJECT already has p0 images, skipping..."
		else
			echo "Subject $SUBJECT missing p0 images, will render..."
			echo "$SUBJECT" >> "$TEMP_MISSING_P0_FILE"
		fi
	done < "$CAT12_PASSED_FILE"
	
	# Use the list of subjects missing p0 images
	if [ -s "$TEMP_MISSING_P0_FILE" ]; then
		echo "Found $(wc -l < "$TEMP_MISSING_P0_FILE") subjects missing p0 images"
		RENDER_SUBJECTS_FILE="$TEMP_MISSING_P0_FILE"
	else
		echo "All CAT12 passed subjects already have p0 images. Nothing to render."
		# Still need to generate the summary files, so continue with empty processing
		RENDER_SUBJECTS_FILE="$TEMP_MISSING_P0_FILE"
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
            SESSION_DIRS=$(find "$SUBJECT_DIR" -maxdepth 1 -type d -name "ses-*" | sort -V | head -1)
            
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
	#rm -f "$TEMP_MISSING_P0_FILE"
    
done




