#!/bin/bash

savetofile= /projects/kg98/trangc/VBM/data/ADNI/scanner_model.txt

filename=$1 	#input file contains long subject ID

while read line; do

	echo $line >> ${savetofile} 	#save long subject ID to file

	#subid=$(echo $line | cut -c1-8)		#get the short subject ID, check the letter indices that you want to extract
	#sesid=$(echo $line | cut -c13-17)	#get session ID

	ls /projects/kg98/trangc/VBM/ADNI/sub-${line}/${line} > test.txt	#list all scans
	
	anat=$(sed '2q;d' test.txt) #test.txt has the list of all folders in the dir, e.g., BIDS, anat2, anat4. We want to get one of the anats (different sessions)
	echo ${anat}

	jp -f /fs02/kg98/trangc/oasis3_hc_ad_last/OASIS3_json/${subid}/${line}/${anat}/BIDS/sub-${subid}_ses-${sesid}*_T1w.json ManufacturersModelName >> ${savetofile}	#save the scanner model to file
	jp -f /fs02/kg98/trangc/oasis3_hc_ad_last/OASIS3_json/${subid}/${line}/${anat}/BIDS/sub-${subid}_ses-${sesid}*_T1w.json DeviceSerialNumber>> ${savetofile}	#save the scanner ID to file

done < $filename	
