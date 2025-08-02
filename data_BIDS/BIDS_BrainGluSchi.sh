module load fsl
module load mricrogl


IDIR=/scratch/kg98/Data_Trang/SCZ_BrainGluSchi/dicom/triotim/jbustillo/braingluschi_20542

ODIR=/projects/kg98/trangc/VBM/data/BrainGluSchi

for DIR in `cat /home/trangc/kg98/trangc/VBM/data/BrainGluSchi/sublist.txt`
do

#NAMEUNZIP=sub-${DIR:0:9}
#mkdir -p ${ODIR}/${NAMEUNZIP}
#unzip ${IDIR}/${DIR} -d ${ODIR}/${NAMEUNZIP}/anat/
#cp -R ${IDIR}/${DIR} ${ODIR}/${NAMEUNZIP}/anat

#rm -f ${ODIR}/${NAMEUNZIP}/anat/*.nii

#dcm2niix -o ${ODIR}/${NAMEUNZIP}/anat/ -f %f ${ODIR}/${NAMEUNZIP}/anat/

#gzip -d  ${ODIR}/${NAMEUNZIP}/anat/*.nii.gz
#mv ${ODIR}/${NAMEUNZIP}/anat/anat_e1.nii ${ODIR}/${NAMEUNZIP}/anat/${NAMEUNZIP}_T1w.nii

if [ ! -f ${ODIR}/${DIR}/anat/${DIR}_T1w.nii ]; then
echo ${DIR}
mv ${ODIR}/${DIR}/anat/anat_e1.nii ${ODIR}/${DIR}/anat/${DIR}_T1w.nii
fi

#mv ${ODIR}/${DIR}/anat/anat_e2.nii ${ODIR}/${DIR}/anat/${DIR}_T1w.nii

done
