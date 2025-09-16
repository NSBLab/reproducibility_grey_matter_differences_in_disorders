#!/bin/env bash

DATASETLIST=/projects/kg98/trangc/VBM/data/dataset_list_notVBM_FS.txt
#SESSION=1 #having multiple sessions or not

for DATASET in `cat ${DATASETLIST}`
do

			if [ ! -f /projects/kg98/trangc/VBM/data/${DATASET}/sub_without_outlier.txt ]
        		then 
        			echo "${DATASET}"
        	
        		fi  

			if [ ! -f /projects/kg98/trangc/VBM/data/${DATASET}/autoQCOutlier.txt ]
        		then 
        			echo "${DATASET}_outlier"
        	
        		fi 
done
