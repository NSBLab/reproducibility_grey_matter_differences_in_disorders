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


export iscombat=COMBAT
export smoothkernel=6

diaglist=(BD SCA SCZ ASD MDD AD)
for diag in "${diaglist[@]}"
do

spmdir=/projects/kg98/trangc/VBM/data/derivatives/s$smoothkernel${iscombat}/$diag # change this 
outdir=$spmdir # change this
workdir=$spmdir/work # change this


if [ ! -d $outdir ]; then mkdir $outdir; echo "making output directory"; fi
if [ ! -d $workdir ]; then mkdir $workdir; echo "making work directory"; fi

ls ${spmdir}>>${outdir}/sitelist.txt

for site in `cat ${outdir}/sitelist.txt`
do


	# you can change a lot of these parameters here if you want a slightly different slice location, etc

	vglrun fsleyes render -of ${workdir}/${site}.png --scene ortho --worldLoc 3.9116094149075877 -18.000080108642578 59.37296095628005 --displaySpace world --xcentre  0.00000  0.00000 --ycentre  0.00000  0.00000 --zcentre  0.00000  0.00000 --xzoom 100.0 --yzoom 100.00698775151713 --zzoom 100.0 --showLocation no --layout horizontal --invertYHorizontal --invertZHorizontal --cursorWidth 1.0 --bgColour 0.0 0.0 0.0 --fgColour 1.0 1.0 1.0 --cursorColour 0.0 1.0 0.0 --colourBarLocation top --colourBarLabelSide top-left --colourBarSize 100.0 --labelSize 12 --performance 3 ${spmdir}/${site}/spmT_0001.nii --name "spmT_0001" --overlayType volume --alpha 100.0 --brightness 49.7500007140387 --contrast 49.900298891567786 --cmap greyscale --negativeCmap greyscale --displayRange -3.922575712203979 4.508436460494995 --clippingRange -3.922575712203979 4.508436460494995 --modulateRange -3.9225757122039795 4.424961090087891 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 60 --blendFactor 0.3 --smoothing 0 --resolution 70 --numInnerSteps 10 --clipMode intersection --volume 0

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
