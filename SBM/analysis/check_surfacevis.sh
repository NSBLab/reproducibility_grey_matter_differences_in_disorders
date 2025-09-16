#!/bin/env bash

DATASETLIST=/projects/kg98/trangc/VBM/data/dataset_list_ses.txt
#SESSION=1 #having multiple sessions or not

for DATASET in `cat ${DATASETLIST}`
do

			if [ ! -f /projects/kg98/trangc/VBM/data/${DATASET}/derivatives/surf_vis_fsl/coronal_${DATASET}_without_outlier.pdf ]
        		then 
        			echo "${DATASET}"
        	
        		fi  

			if [ ! -f /projects/kg98/trangc/VBM/data/${DATASET}/derivatives/surf_vis_fsl/coronal_${DATASET}_outlier.pdf ]
        		then 
        			echo "${DATASET}_outlier"
        	
        		fi 
done
