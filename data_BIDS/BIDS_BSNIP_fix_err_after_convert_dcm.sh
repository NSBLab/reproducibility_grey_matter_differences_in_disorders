

ODIR=/projects/kg98/trangc/VBM/data/BSNIP

for DIR in `cat /projects/kg98/trangc/VBM/data/BSNIP/sublist_err_convert.txt`	#get subject ID
do

	ls /projects/kg98/trangc/VBM/data/BSNIP/${DIR}/anat/*.nii > temp.txt #list all the nifti

	cmp --silent $(sed '1q;d' temp.txt) $(sed '2q;d' temp.txt) || echo ${DIR} #compare the nifti listed in tempt.txt



#echo $filename
#echo $sub
#NAMEUNZIP=sub-${DIR:1:7}
#mkdir -p ${ODIR}/${NAMEUNZIP}/anat/
#unzip ${IDIR}/${DIR} -d ${ODIR}/${NAMEUNZIP}/anat/

#dcm2niix -o ${ODIR}/${NAMEUNZIP}/anat/ -f %f ${ODIR}/${NAMEUNZIP}/anat/
#mv ${ODIR}/${NAMEUNZIP}/anat/*.nii ${ODIR}/${NAMEUNZIP}/anat/${NAMEUNZIP}_T1w.nii
done
