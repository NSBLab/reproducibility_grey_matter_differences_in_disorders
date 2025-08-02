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


#export iscombat=COMBAT
export smoothkernel=6

datadir=/fs04/kg98/trangc/VBM/data
DATASET_LIST=$datadir/dataset_list1.txt
for DATASET in `cat ${DATASET_LIST}`
do

ls $datadir/$DATASET/qdec_table_*.dat > $datadir/$DATASET/sitelist.txt

	for sitefile in `cat $datadir/$DATASET/sitelist.txt`
	do

		echo $sitefile
		sitefield=$(echo "$sitefile" | grep -o -P '(?<=table_).*(?=.dat)') #| awk -F_ '{for (i=3; i<=NF-1; i++) printf "%s_", $i}')
		echo $sitefield
		site=${sitefield:0:${#sitefield}-2}
		echo $site
		diag=${sitefile:${#sitefile}-5:1}
		echo $diag
		control=1
		title=${diag}_${site}_${measureShort}_smooth${smoothKernel}_${hemis}_${covariance1}_${covariance2}_${parc}
		echo $title
		outdir=$datadir/$DATASET/derivatives/T1fsleyes
		echo $outdir
		if [ ! -d $outdir ]; then mkdir $outdir; echo "making qdec directory"; fi 
		
		workdir=$outdir/work # change this

		if [ ! -d $workdir ]; then mkdir $workdir; echo "making work directory"; fi

		IFS=$'\n'
		for line in $(tail -n +2 "$sitefile")
		do




			IFS=$'\t' read -ra parts <<< "$line"
    		
			#change list input for MBBP
			#sub=$(echo "${parts[0]}" | sed 's/sub-0*\([1-9][0-9]*\)/sub-\1/')
			sub=${parts[0]}
			




	# you can change a lot of these parameters here if you want a slightly different slice location, etc

	vglrun fsleyes render -of ${workdir}/${site}.png --scene ortho --worldLoc 3.9116094149075877 -18.000080108642578 59.37296095628005 --displaySpace world --xcentre  0.00000  0.00000 --ycentre  0.00000  0.00000 --zcentre  0.00000  0.00000 --xzoom 100.0 --yzoom 100.00698775151713 --zzoom 100.0 --showLocation no --layout horizontal --invertYHorizontal --invertZHorizontal --cursorWidth 1.0 --bgColour 0.0 0.0 0.0 --fgColour 1.0 1.0 1.0 --cursorColour 0.0 1.0 0.0 --colourBarLocation top --colourBarLabelSide top-left --colourBarSize 100.0 --labelSize 12 --performance 3 $datadir/$DATASET/${sub}/anat/${sub}_T1w.nii --name "spmT_0001" --overlayType volume --alpha 100.0 --brightness 49.7500007140387 --contrast 49.900298891567786 --cmap greyscale --negativeCmap greyscale --displayRange -3.922575712203979 4.508436460494995 --clippingRange -3.922575712203979 4.508436460494995 --modulateRange -3.9225757122039795 4.424961090087891 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 60 --blendFactor 0.3 --smoothing 0 --resolution 70 --numInnerSteps 10 --clipMode intersection --volume 0

	#convert ${workdir}/${sub}_sagittal.png  ${workdir}/${sub}_coronal.png  ${workdir}/${sub}_axial.png -caption "${sub}" -append ${outdir}/${sub}_surface.png

	#convert  ${outdir}/${sub}_surface.png -pointsize 60 -fill white -annotate +100+100 "${sub}" ${outdir}/${sub}_surface.png

	done

#rm -r $workdir


cd ${workdir}
#filelist=/projects/kg98/trangc/VBM/data/$dataset/autoQCOutlier.txt
#convert $(sed 's/$/_sagittal.png/' "$filelist") -resize 800x1800 ${outdir}/sagittal_${dataset}_outlier.pdf
#convert $(sed 's/$/_axial.png/' "$filelist") -resize 800x1800 ${outdir}/axial_${dataset}_outlier.pdf
#convert $(sed 's/$/_coronal.png/' "$filelist") -resize 800x1800 ${outdir}/coronal_${dataset}_outlier.pdf

filelist=${workdir}/spmstatmap.txt #sub_to_add_vis.txt
ls ${workdir}>>${filelist}
convert $(cat $filelist) -resize 800x1800 ${spmdir}/spmstatmap.pdf


done
