#!/bin/bash
#SBATCH --job-name=freeview_plots
#SBATCH --account=kg98
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=0-01:00:00
#SBATCH --mail-user=<your.email>@monash.edu
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=END
#SBATCH --export=ALL
#SBATCH --mem-per-cpu=8000
#SBATCH --qos=normal
#SBATCH -A kg98

SUBJECT_LIST="/projects/kg98/trangc/VBM/data/${dataset}/sub_with_recon_output.txt"

module purge
module load freesurfer/7.1.0
# paths
fsdir=/projects/kg98/trangc/VBM/data/${dataset}/derivatives/freesurfer # change this
outdir=/projects/kg98/trangc/VBM/data/${dataset}/derivatives/surf_vis # change this
if [ ! -d $outdir ]; then mkdir $outdir; echo "making output directory"; fi

for sub in `cat ${SUBJECT_LIST}`
do

#T1=${fsdir}/mri/T1.mgz # if you don't want to load the freesurfer mgz volume, you can also change this to the path to your anat T1w.nii.gz in your BIDS dataset - see commented code below for example
T1=/projects/kg98/trangc/VBM/data/${dataset}/${sub}/anat/${sub}_T1w.nii
lhpial=${fsdir}/${sub}/surf/lh.pial
rhpial=${fsdir}/${sub}/surf/rh.pial
lhwhite=${fsdir}/${sub}/surf/lh.white
rhwhite=${fsdir}/${sub}/surf/rh.white

# coordinates to visualise - these are just some random coordinates that looked okay
x="35"
y="15"
z="50"

vglrun freeview -v ${T1} -f ${lhpial}:edgecolor=blue ${rhpial}:edgecolor=blue ${lhwhite}:edgecolor=red ${rhwhite}:edgecolor=red -layout 1 -viewport x -ras ${x} ${y} ${z} -ss ${outdir}/${sub}_sag.png
vglrun freeview -v ${T1} -f ${lhpial}:edgecolor=blue ${rhpial}:edgecolor=blue ${lhwhite}:edgecolor=red ${rhwhite}:edgecolor=red -layout 1 -viewport y -ras ${x} ${y} ${z} -ss ${outdir}/${sub}_cor.png
vglrun freeview -v ${T1} -f ${lhpial}:edgecolor=blue ${rhpial}:edgecolor=blue ${lhwhite}:edgecolor=red ${rhwhite}:edgecolor=red -layout 1 -viewport z -ras ${x} ${y} ${z} -ss ${outdir}/${sub}_axi.png

done

# tbh I've never tested this on slurm
# it works as a for loop in a local terminal on massive, but will open and close the freeview window for each sub
# I currently prefer fsleyes but freeview might be more flexible if you want to visualise a sphere, etc (fsleyes might be less of a headache if you have GIFTIs though, so it all depends on your data)

# also this returns separate pngs for each view
