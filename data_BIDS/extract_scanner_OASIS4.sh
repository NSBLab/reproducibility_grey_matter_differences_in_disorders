#!/bin/bash

#module load json-c
DIR=/projects/kg98/trangc/VBM/data/OASIS4
savetofile=${DIR}/scanner_model.txt

echo ID > ${savetofile}

for line in `cat ${DIR}/subject_copy.txt`
do


	echo $line >> ${savetofile} 	#save long subject ID to file

	jq '.ManufacturersModelName' ${DIR}/${line}/ses-1/anat/*.json >> ${savetofile}	#save the scanner model to file
	#jq '.DeviceSerialNumber' ${DIR}/${line}/ses-1/anat/*.json >> ${savetofile}	#save the scanner ID to file

done	
