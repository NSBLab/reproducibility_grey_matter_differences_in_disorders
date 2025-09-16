#!/bin/bash
#SBATCH --job-name=freeview_plots
#SBATCH --account=kg98
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=1-00:00:00
#SBATCH --mail-user=<your.email>@monash.edu
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=END
#SBATCH --export=ALL
#SBATCH --mem-per-cpu=8000
#SBATCH --qos=normal
#SBATCH -A kg98

module purge
module load fsleyes
#module load imagemagick


DATASETLIST=/projects/kg98/trangc/VBM/data/dataset_list1.txt
#SESSION=1 #having multiple sessions or not# dont' use this as we don't have ses what derive freesurfer


for dataset in `cat ${DATASETLIST}`
do


# paths
# this all assumes BIDS btw
datadir=/projects/kg98/trangc/VBM/data/${dataset} # change this
#fsdir=/home/trangc/kg98_scratch/Toby/WHOLEMBBP/workspace/derivatives/freesurfer
fsdir=/projects/kg98/trangc/VBM/data/${dataset}/derivatives/freesurfer # change this - if your surfaces aren't freesurfer format (e.g., .surf.gii instead of .pial or .white), so long as this path leads to where the GIFTIs are
outdir=/projects/kg98/trangc/VBM/data/${dataset}/derivatives/surf_vis_fsl # change this
workdir=/projects/kg98/trangc/VBM/data/${dataset}/derivatives/surf_vis_fsl/work # change this
thickness=0.5

if [ ! -d $outdir ]; then mkdir $outdir; echo "making output directory"; fi
if [ ! -d $workdir ]; then mkdir $workdir; echo "making work directory"; fi

if [ -z "$SESSION" ]
then
SUBJECT_LIST="/projects/kg98/trangc/VBM/data/${dataset}/sub_with_recon_output.txt"  #"/path/to/sublist.txt"

	for sub in `cat ${SUBJECT_LIST}`
	do
		#subject=$(echo "$sub" | sed 's/sub-0*\([1-9][0-9]*\)/sub-\1/')
		subject=$sub
	#T1=${datadir}/${sub}/anat/${sub}_T1w.nii # BIDS format
	T1=${fsdir}/${subject}/mri/T1.mgz
	lhpial=${fsdir}/${subject}/surf/lh.pial # freesurfer output format - if you're not loading in fs files, change this to whatever surface you have (e.g., ${sub}_hemi-left_pial.surf.gii)
	rhpial=${fsdir}/${subject}/surf/rh.pial # freesurfer output format
	lhwhite=${fsdir}/${subject}/surf/lh.white # freesurfer output format
	rhwhite=${fsdir}/${subject}/surf/rh.white # freesurfer output format

	# you can change a lot of these parameters here if you want a slightly different slice location, etc

	vglrun fsleyes render -of ${workdir}/${sub}_sagittal.png  --scene lightbox --worldLoc 3.948837 39.18269348144531 3.329071044921875 --displaySpace world --zaxis 0 --sliceSpacing 0.05 --zrange 0.1 0.9 --ncols 0 --nrows 0 --cursorWidth 1.0 --bgColour 0.0 0.0 0.0 --fgColour 1.0 1.0 1.0 --cursorColour 0.0 1.0 0.0 --colourBarLocation top --colourBarLabelSide top-left --colourBarSize 100.0 --labelSize 12 --performance 3 $T1 --name "T1.mgz_copy" --overlayType volume --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --cmap greyscale --negativeCmap greyscale --displayRange 0.0 225.23 --clippingRange 0.0 225.23 --modulateRange 0.0 223.0 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 60 --blendFactor 0.3 --smoothing 0 --resolution 90 --numInnerSteps 10 --clipMode intersection --volume 0 $lhpial --name "lh.pial" --overlayType mesh --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --refImage $T1 --lut random --cmap greyscale --negativeCmap greyscale --vertexDataIndex 0 --vertexSet $lhpial --colour 0.0 0.0 1.0 --outline --outlineWidth 1.0 --coordSpace torig --unlinkLowRanges --displayRange 0.0 1.01 --clippingRange 0.0 1.01 --modulateRange 0.0 1.0 --gamma 0.0 --cmapResolution 256 --interpolation linear $lhwhite --name "lh.white" --overlayType mesh --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --refImage $T1 --lut random --cmap greyscale --negativeCmap greyscale --vertexDataIndex 0 --vertexSet $lhwhite --colour 1.0 0.0 0.0 --outline --outlineWidth 1.3 --coordSpace torig --unlinkLowRanges --displayRange 0.0 1.01 --clippingRange 0.0 1.01 --modulateRange 0.0 1.0 --gamma 0.0 --cmapResolution 256 --interpolation linear $rhwhite --name "rh.white" --overlayType mesh --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --refImage $T1 --lut random --cmap greyscale --negativeCmap greyscale --vertexDataIndex 0 --vertexSet $rhwhite --colour 1.0 0.0 0.0 --outline --outlineWidth 1.0 --coordSpace torig --unlinkLowRanges --displayRange 0.0 1.01 --clippingRange 0.0 1.01 --modulateRange 0.0 1.0 --gamma 0.0 --cmapResolution 256 --interpolation linear $rhpial --name "rh.pial" --overlayType mesh --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --refImage $T1 --lut random --cmap greyscale --negativeCmap greyscale --vertexDataIndex 0 --vertexSet $rhpial --colour 0.0 0.0 1.0 --outline --outlineWidth 1.0 --coordSpace torig --unlinkLowRanges --displayRange 0.0 1.01 --clippingRange 0.0 1.01 --modulateRange 0.0 1.0 --gamma 0.0 --cmapResolution 256 --interpolation linear

	vglrun fsleyes render -of ${workdir}/${sub}_axial.png  --scene lightbox --worldLoc 3.948837 39.18269348144531 3.329071044921875 --displaySpace world --zaxis 2 --sliceSpacing 0.05 --zrange 0.1 0.9 --ncols 0 --nrows 0 --cursorWidth 1.0 --bgColour 0.0 0.0 0.0 --fgColour 1.0 1.0 1.0 --cursorColour 0.0 1.0 0.0 --colourBarLocation top --colourBarLabelSide top-left --colourBarSize 100.0 --labelSize 12 --performance 3 $T1 --name "T1.mgz_copy" --overlayType volume --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --cmap greyscale --negativeCmap greyscale --displayRange 0.0 225.23 --clippingRange 0.0 225.23 --modulateRange 0.0 223.0 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 60 --blendFactor 0.3 --smoothing 0 --resolution 90 --numInnerSteps 10 --clipMode intersection --volume 0 $lhpial --name "lh.pial" --overlayType mesh --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --refImage $T1 --lut random --cmap greyscale --negativeCmap greyscale --vertexDataIndex 0 --vertexSet $lhpial --colour 0.0 0.0 1.0 --outline --outlineWidth 1.0 --coordSpace torig --unlinkLowRanges --displayRange 0.0 1.01 --clippingRange 0.0 1.01 --modulateRange 0.0 1.0 --gamma 0.0 --cmapResolution 256 --interpolation linear $lhwhite --name "lh.white" --overlayType mesh --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --refImage $T1 --lut random --cmap greyscale --negativeCmap greyscale --vertexDataIndex 0 --vertexSet $lhwhite --colour 1.0 0.0 0.0 --outline --outlineWidth 1.3 --coordSpace torig --unlinkLowRanges --displayRange 0.0 1.01 --clippingRange 0.0 1.01 --modulateRange 0.0 1.0 --gamma 0.0 --cmapResolution 256 --interpolation linear $rhwhite --name "rh.white" --overlayType mesh --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --refImage $T1 --lut random --cmap greyscale --negativeCmap greyscale --vertexDataIndex 0 --vertexSet $rhwhite --colour 1.0 0.0 0.0 --outline --outlineWidth 1.0 --coordSpace torig --unlinkLowRanges --displayRange 0.0 1.01 --clippingRange 0.0 1.01 --modulateRange 0.0 1.0 --gamma 0.0 --cmapResolution 256 --interpolation linear $rhpial --name "rh.pial" --overlayType mesh --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --refImage $T1 --lut random --cmap greyscale --negativeCmap greyscale --vertexDataIndex 0 --vertexSet $rhpial --colour 0.0 0.0 1.0 --outline --outlineWidth 1.0 --coordSpace torig --unlinkLowRanges --displayRange 0.0 1.01 --clippingRange 0.0 1.01 --modulateRange 0.0 1.0 --gamma 0.0 --cmapResolution 256 --interpolation linear


	vglrun fsleyes render -of ${workdir}/${sub}_coronal.png  --scene lightbox --worldLoc 3.948837 39.18269348144531 3.329071044921875 --displaySpace world --zaxis 1 --sliceSpacing 0.05 --zrange 0.1 0.9 --ncols 0 --nrows 0 --cursorWidth 1.0 --bgColour 0.0 0.0 0.0 --fgColour 1.0 1.0 1.0 --cursorColour 0.0 1.0 0.0 --colourBarLocation top --colourBarLabelSide top-left --colourBarSize 100.0 --labelSize 12 --performance 3 $T1 --name "T1.mgz_copy" --overlayType volume --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --cmap greyscale --negativeCmap greyscale --displayRange 0.0 225.23 --clippingRange 0.0 225.23 --modulateRange 0.0 223.0 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 60 --blendFactor 0.3 --smoothing 0 --resolution 90 --numInnerSteps 10 --clipMode intersection --volume 0 $lhpial --name "lh.pial" --overlayType mesh --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --refImage $T1 --lut random --cmap greyscale --negativeCmap greyscale --vertexDataIndex 0 --vertexSet $lhpial --colour 0.0 0.0 1.0 --outline --outlineWidth 1.0 --coordSpace torig --unlinkLowRanges --displayRange 0.0 1.01 --clippingRange 0.0 1.01 --modulateRange 0.0 1.0 --gamma 0.0 --cmapResolution 256 --interpolation linear $lhwhite --name "lh.white" --overlayType mesh --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --refImage $T1 --lut random --cmap greyscale --negativeCmap greyscale --vertexDataIndex 0 --vertexSet $lhwhite --colour 1.0 0.0 0.0 --outline --outlineWidth 1.3 --coordSpace torig --unlinkLowRanges --displayRange 0.0 1.01 --clippingRange 0.0 1.01 --modulateRange 0.0 1.0 --gamma 0.0 --cmapResolution 256 --interpolation linear $rhwhite --name "rh.white" --overlayType mesh --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --refImage $T1 --lut random --cmap greyscale --negativeCmap greyscale --vertexDataIndex 0 --vertexSet $rhwhite --colour 1.0 0.0 0.0 --outline --outlineWidth 1.0 --coordSpace torig --unlinkLowRanges --displayRange 0.0 1.01 --clippingRange 0.0 1.01 --modulateRange 0.0 1.0 --gamma 0.0 --cmapResolution 256 --interpolation linear $rhpial --name "rh.pial" --overlayType mesh --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --refImage $T1 --lut random --cmap greyscale --negativeCmap greyscale --vertexDataIndex 0 --vertexSet $rhpial --colour 0.0 0.0 1.0 --outline --outlineWidth 1.0 --coordSpace torig --unlinkLowRanges --displayRange 0.0 1.01 --clippingRange 0.0 1.01 --modulateRange 0.0 1.0 --gamma 0.0 --cmapResolution 256 --interpolation linear

	#convert ${workdir}/${sub}_sagittal.png  ${workdir}/${sub}_coronal.png  ${workdir}/${sub}_axial.png -caption "${sub}" -append ${outdir}/${sub}_surface.png

	#convert  ${outdir}/${sub}_surface.png -pointsize 60 -fill white -annotate +100+100 "${sub}" ${outdir}/${sub}_surface.png

	done

else
	SUBJECT_LIST="/projects/kg98/trangc/VBM/data/${dataset}/ses_sub_with_recon_output.txt"  #"/path/to/sublist.txt"


	for subject in `cat ${SUBJECT_LIST}`
	do

	ses=${subject: -5}
	sub=${subject:0:${#subject}-5}

	#T1=${datadir}/${sub}/anat/${sub}_T1w.nii # BIDS format
	T1=${fsdir}/${sub}/${ses}/mri/T1.mgz
	lhpial=${fsdir}/${sub}/${ses}/surf/lh.pial # freesurfer output format - if you're not loading in fs files, change this to whatever surface you have (e.g., ${sub}_hemi-left_pial.surf.gii)
	rhpial=${fsdir}/${sub}/${ses}/surf/rh.pial # freesurfer output format
	lhwhite=${fsdir}/${sub}/${ses}/surf/lh.white # freesurfer output format
	rhwhite=${fsdir}/${sub}/${ses}/surf/rh.white # freesurfer output format

	# you can change a lot of these parameters here if you want a slightly different slice location, etc

	vglrun fsleyes render -of ${workdir}/${sub}_sagittal.png  --scene lightbox --worldLoc 3.948837 39.18269348144531 3.329071044921875 --displaySpace world --zaxis 0 --sliceSpacing 0.05 --zrange 0.1 0.9 --ncols 0 --nrows 0 --cursorWidth 1.0 --bgColour 0.0 0.0 0.0 --fgColour 1.0 1.0 1.0 --cursorColour 0.0 1.0 0.0 --colourBarLocation top --colourBarLabelSide top-left --colourBarSize 100.0 --labelSize 12 --performance 3 $T1 --name "T1.mgz_copy" --overlayType volume --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --cmap greyscale --negativeCmap greyscale --displayRange 0.0 225.23 --clippingRange 0.0 225.23 --modulateRange 0.0 223.0 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 60 --blendFactor 0.3 --smoothing 0 --resolution 90 --numInnerSteps 10 --clipMode intersection --volume 0 $lhpial --name "lh.pial" --overlayType mesh --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --refImage $T1 --lut random --cmap greyscale --negativeCmap greyscale --vertexDataIndex 0 --vertexSet $lhpial --colour 0.0 0.0 1.0 --outline --outlineWidth 1.0 --coordSpace torig --unlinkLowRanges --displayRange 0.0 1.01 --clippingRange 0.0 1.01 --modulateRange 0.0 1.0 --gamma 0.0 --cmapResolution 256 --interpolation linear $lhwhite --name "lh.white" --overlayType mesh --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --refImage $T1 --lut random --cmap greyscale --negativeCmap greyscale --vertexDataIndex 0 --vertexSet $lhwhite --colour 1.0 0.0 0.0 --outline --outlineWidth 1.3 --coordSpace torig --unlinkLowRanges --displayRange 0.0 1.01 --clippingRange 0.0 1.01 --modulateRange 0.0 1.0 --gamma 0.0 --cmapResolution 256 --interpolation linear $rhwhite --name "rh.white" --overlayType mesh --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --refImage $T1 --lut random --cmap greyscale --negativeCmap greyscale --vertexDataIndex 0 --vertexSet $rhwhite --colour 1.0 0.0 0.0 --outline --outlineWidth 1.0 --coordSpace torig --unlinkLowRanges --displayRange 0.0 1.01 --clippingRange 0.0 1.01 --modulateRange 0.0 1.0 --gamma 0.0 --cmapResolution 256 --interpolation linear $rhpial --name "rh.pial" --overlayType mesh --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --refImage $T1 --lut random --cmap greyscale --negativeCmap greyscale --vertexDataIndex 0 --vertexSet $rhpial --colour 0.0 0.0 1.0 --outline --outlineWidth 1.0 --coordSpace torig --unlinkLowRanges --displayRange 0.0 1.01 --clippingRange 0.0 1.01 --modulateRange 0.0 1.0 --gamma 0.0 --cmapResolution 256 --interpolation linear


	vglrun fsleyes render -of ${workdir}/${sub}_axial.png  --scene lightbox --worldLoc 3.948837 39.18269348144531 3.329071044921875 --displaySpace world --zaxis 2 --sliceSpacing 0.05 --zrange 0.1 0.9 --ncols 0 --nrows 0 --cursorWidth 1.0 --bgColour 0.0 0.0 0.0 --fgColour 1.0 1.0 1.0 --cursorColour 0.0 1.0 0.0 --colourBarLocation top --colourBarLabelSide top-left --colourBarSize 100.0 --labelSize 12 --performance 3 $T1 --name "T1.mgz_copy" --overlayType volume --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --cmap greyscale --negativeCmap greyscale --displayRange 0.0 225.23 --clippingRange 0.0 225.23 --modulateRange 0.0 223.0 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 60 --blendFactor 0.3 --smoothing 0 --resolution 90 --numInnerSteps 10 --clipMode intersection --volume 0 $lhpial --name "lh.pial" --overlayType mesh --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --refImage $T1 --lut random --cmap greyscale --negativeCmap greyscale --vertexDataIndex 0 --vertexSet $lhpial --colour 0.0 0.0 1.0 --outline --outlineWidth 1.0 --coordSpace torig --unlinkLowRanges --displayRange 0.0 1.01 --clippingRange 0.0 1.01 --modulateRange 0.0 1.0 --gamma 0.0 --cmapResolution 256 --interpolation linear $lhwhite --name "lh.white" --overlayType mesh --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --refImage $T1 --lut random --cmap greyscale --negativeCmap greyscale --vertexDataIndex 0 --vertexSet $lhwhite --colour 1.0 0.0 0.0 --outline --outlineWidth 1.3 --coordSpace torig --unlinkLowRanges --displayRange 0.0 1.01 --clippingRange 0.0 1.01 --modulateRange 0.0 1.0 --gamma 0.0 --cmapResolution 256 --interpolation linear $rhwhite --name "rh.white" --overlayType mesh --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --refImage $T1 --lut random --cmap greyscale --negativeCmap greyscale --vertexDataIndex 0 --vertexSet $rhwhite --colour 1.0 0.0 0.0 --outline --outlineWidth 1.0 --coordSpace torig --unlinkLowRanges --displayRange 0.0 1.01 --clippingRange 0.0 1.01 --modulateRange 0.0 1.0 --gamma 0.0 --cmapResolution 256 --interpolation linear $rhpial --name "rh.pial" --overlayType mesh --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --refImage $T1 --lut random --cmap greyscale --negativeCmap greyscale --vertexDataIndex 0 --vertexSet $rhpial --colour 0.0 0.0 1.0 --outline --outlineWidth 1.0 --coordSpace torig --unlinkLowRanges --displayRange 0.0 1.01 --clippingRange 0.0 1.01 --modulateRange 0.0 1.0 --gamma 0.0 --cmapResolution 256 --interpolation linear


	vglrun fsleyes render -of ${workdir}/${sub}_coronal.png  --scene lightbox --worldLoc 3.948837 39.18269348144531 3.329071044921875 --displaySpace world --zaxis 1 --sliceSpacing 0.05 --zrange 0.1 0.9 --ncols 0 --nrows 0 --cursorWidth 1.0 --bgColour 0.0 0.0 0.0 --fgColour 1.0 1.0 1.0 --cursorColour 0.0 1.0 0.0 --colourBarLocation top --colourBarLabelSide top-left --colourBarSize 100.0 --labelSize 12 --performance 3 $T1 --name "T1.mgz_copy" --overlayType volume --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --cmap greyscale --negativeCmap greyscale --displayRange 0.0 225.23 --clippingRange 0.0 225.23 --modulateRange 0.0 223.0 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 60 --blendFactor 0.3 --smoothing 0 --resolution 90 --numInnerSteps 10 --clipMode intersection --volume 0 $lhpial --name "lh.pial" --overlayType mesh --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --refImage $T1 --lut random --cmap greyscale --negativeCmap greyscale --vertexDataIndex 0 --vertexSet $lhpial --colour 0.0 0.0 1.0 --outline --outlineWidth 1.0 --coordSpace torig --unlinkLowRanges --displayRange 0.0 1.01 --clippingRange 0.0 1.01 --modulateRange 0.0 1.0 --gamma 0.0 --cmapResolution 256 --interpolation linear $lhwhite --name "lh.white" --overlayType mesh --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --refImage $T1 --lut random --cmap greyscale --negativeCmap greyscale --vertexDataIndex 0 --vertexSet $lhwhite --colour 1.0 0.0 0.0 --outline --outlineWidth 1.3 --coordSpace torig --unlinkLowRanges --displayRange 0.0 1.01 --clippingRange 0.0 1.01 --modulateRange 0.0 1.0 --gamma 0.0 --cmapResolution 256 --interpolation linear $rhwhite --name "rh.white" --overlayType mesh --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --refImage $T1 --lut random --cmap greyscale --negativeCmap greyscale --vertexDataIndex 0 --vertexSet $rhwhite --colour 1.0 0.0 0.0 --outline --outlineWidth 1.0 --coordSpace torig --unlinkLowRanges --displayRange 0.0 1.01 --clippingRange 0.0 1.01 --modulateRange 0.0 1.0 --gamma 0.0 --cmapResolution 256 --interpolation linear $rhpial --name "rh.pial" --overlayType mesh --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --refImage $T1 --lut random --cmap greyscale --negativeCmap greyscale --vertexDataIndex 0 --vertexSet $rhpial --colour 0.0 0.0 1.0 --outline --outlineWidth 1.0 --coordSpace torig --unlinkLowRanges --displayRange 0.0 1.01 --clippingRange 0.0 1.01 --modulateRange 0.0 1.0 --gamma 0.0 --cmapResolution 256 --interpolation linear

	#convert ${workdir}/${sub}_sagittal.png  ${workdir}/${sub}_coronal.png  ${workdir}/${sub}_axial.png -caption "${sub}" -append ${outdir}/${sub}_surface.png

	#convert  ${outdir}/${sub}_surface.png -pointsize 60 -fill white -annotate +100+100 "${sub}" ${outdir}/${sub}_surface.png

	done
fi
#rm -r $workdir


cd ${workdir}
#filelist=/projects/kg98/trangc/VBM/data/$dataset/autoQCOutlier.txt
#convert $(sed 's/$/_sagittal.png/' "$filelist") -resize 800x1800 ${outdir}/sagittal_${dataset}_outlier.pdf
#convert $(sed 's/$/_axial.png/' "$filelist") -resize 800x1800 ${outdir}/axial_${dataset}_outlier.pdf
#convert $(sed 's/$/_coronal.png/' "$filelist") -resize 800x1800 ${outdir}/coronal_${dataset}_outlier.pdf

filelist=/projects/kg98/trangc/VBM/data/$dataset/sub_with_recon_output.txt #sub_to_add_vis.txt
convert $(sed 's/$/_sagittal.png/' "$filelist") -resize 800x1800 ${outdir}/sagittal_${dataset}_without_outlier.pdf
convert $(sed 's/$/_axial.png/' "$filelist") -resize 800x1800 ${outdir}/axial_${dataset}_without_outlier.pdf
convert $(sed 's/$/_coronal.png/' "$filelist") -resize 800x1800 ${outdir}/coronal_${dataset}_without_outlier.pdf

done
