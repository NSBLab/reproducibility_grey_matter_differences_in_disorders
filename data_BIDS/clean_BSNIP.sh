IDIR=/scratch/kg98/Data_Trang/BD_SCZ_BSNIP/image03

ODIR=/projects/kg98/trangc/VBM/data/BSNIP

for DIR in `cat /home/trangc/kg98/trangc/VBM/data/BSNIP/sublist_err_convert.txt`
do

#NAMEUNZIP=sub-${DIR:1:7}
NAMEUNZIP=$DIR
if [ ! -f ${ODIR}/${NAMEUNZIP}/anat/${NAMEUNZIP}_T1w.nii ]; then 
echo ${DIR:1:7}
#rm -f *.nii
#gzip -d ${ODIR}/${NAMEUNZIP}/anat/*.nii.gz
#mv  ${ODIR}/${NAMEUNZIP}/anat/anat.nii ${ODIR}/${NAMEUNZIP}/anat/${NAMEUNZIP}_T1w.nii
fi
done
