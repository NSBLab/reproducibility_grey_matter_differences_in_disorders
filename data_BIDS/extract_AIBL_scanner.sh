#!/bin/bash

ODIR=/projects/kg98/trangc/VBM/data/AIBL

savetofile=/projects/kg98/trangc/VBM/data/AIBL/scanner_model.txt
echo "sub_ID	ses	model	scannerID" > ${savetofile}

for DIR in `cat ${ODIR}/subject_use.txt`
do

ls ${ODIR}/${DIR} > ${ODIR}/temp1.txt #list all the file type

		for ses in `cat ${ODIR}/temp1.txt`
		do
		
			find ${ODIR}/${DIR}/${ses}/anat -type f -name "*.json" > ${ODIR}/temp3.txt #list all the scans

			for scan in `cat ${ODIR}/temp3.txt`
			do

	
				modelLine=$(sed -n '5p' ${scan})	#the scanner model
				model=$(echo "$modelLine" | sed -n 's/.*: "\([^"]*\)",.*/\1/p')

				
				idLine=$(grep "DeviceSerialNumber" ${scan})
				id=$(echo "$idLine" | sed -n 's/.*: "\([^"]*\)",.*/\1/p')	#the scanner ID
		
				echo -e "${DIR}\t${ses}\t${model}\t${id}" >> ${savetofile}
				
				


			done
		done

done
