#!/bin/bash

IDIR=/scratch/kg98/Data_Trang/OASIS
ODIR=/projects/kg98/trangc/VBM/data/OASIS3

dayses=${ODIR}/day_ses.txt
echo "folder sub ses" > $dayses

for SUB in `cat ${ODIR}/subject.txt`
do
	ls -d $IDIR/${SUB}_MR_* > $IDIR/temp.txt


	SES=0
	for folder in `cat $IDIR/temp.txt`
	do
		SES=$(($SES+1))
		echo "${folder} ${SUB} ${SES}" >> $dayses
		

	done
				

done
