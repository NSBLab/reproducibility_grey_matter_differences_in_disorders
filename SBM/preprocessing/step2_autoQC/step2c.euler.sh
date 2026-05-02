#!/bin/bash
#SBATCH --job-name=euler_number
#SBATCH --account=kg98
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=1-00:00:00
#SBATCH --mail-user=<your.email>@monash.edu
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=END
#SBATCH --export=ALL
#SBATCH --qos=normal
#SBATCH -A kg98
#SBATCH --array=1-1
#IMPORTANT! set the array range above to exactly the number of people in your SubjectIDs.txt file. e.g., if you have 90 subjects then array should be: --array=1-90

DATASET_LIST="/fs04/kg98/trangc/VBM/data/dataset_list1.txt"
#SESSION=1 #having multiple sessions or not#dont use this even with ses as we only use one ses

#SLURM_ARRAY_TASK_ID=1
dataset=$(sed -n "${SLURM_ARRAY_TASK_ID}p" ${DATASET_LIST})
echo -e "\t\t\t --------------------------- "
echo -e "\t\t\t ----- ${SLURM_ARRAY_TASK_ID} ${dataset} ----- "
echo -e "\t\t\t --------------------------- \n"


# clean modules
module purge
module load freesurfer/7.1.0
 
# set paths
SUBJECTS_DIR=/projects/kg98/trangc/VBM/data/${dataset}/derivatives/freesurfer # fill in
#SUBJECTS_DIR=/home/trangc/kg98_scratch/Toby/WHOLEMBBP/workspace/derivatives/freesurfer
outdir=/projects/kg98/trangc/VBM/data/${dataset}/derivatives/euler # fill in
if [ ! -d $outdir ]; then mkdir $outdir; echo "making output directory"; fi
numbers='^[0-9]+$'
f=${outdir}/${dataset}_holes_temp.txt
id=${outdir}/${dataset}_ids.txt
e=${outdir}/${dataset}_holes.csv

if [ -z "$SESSION" ]
then
for i in `cat /projects/kg98/trangc/VBM/data/${dataset}/sub_with_recon_output.txt` ; do # fill in
#sub=$(echo "$i" | sed 's/sub-0*\([1-9][0-9]*\)/sub-\1/')
sub=$i
for h in lh rh ; do

    x=$(mris_euler_number ${SUBJECTS_DIR}/${sub}/surf/${h}.orig.nofix | grep -o -P '(?<=--> ).*(?= holes)')
if [[ $x =~ $numbers ]] ; then
    echo $x >> $f
    echo ${i}_${h} >> ${id}
    fi
done
done

else

for i in `cat /projects/kg98/trangc/VBM/data/${dataset}/ses_sub_with_recon_output.txt` ; do # fill in
ses=${i: -5}
subj=${i:0:${#i}-5}
for h in lh rh ; do
x=$(mris_euler_number ${SUBJECTS_DIR}/${subj}/${ses}/surf/${h}.orig.nofix | grep -o -P '(?<=--> ).*(?= holes)')

    if [[ $x =~ $numbers ]] ; then
    echo $x >> $f
    echo ${subj}_${h} >> ${id}
    fi
  done
done
fi
paste -d "," ${id} ${f} > ${e}
rm ${id}
rm ${f}
####

# technically this only returns the number of holes on the surface but you can calculate euler number as a function of this number with 2 - 2n where n is the number this script returns
