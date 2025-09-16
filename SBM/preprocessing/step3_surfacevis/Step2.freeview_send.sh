#!/bin/bash

DATASETLIST=/projects/kg98/trangc/VBM/data/dataset_list_notVBM_FS.txt

for dataset in `cat ${DATASETLIST}`
do
		export dataset=${dataset}

		sbatch --job-name=freeview_${dataset} Step2.freeview_job.sh
done
