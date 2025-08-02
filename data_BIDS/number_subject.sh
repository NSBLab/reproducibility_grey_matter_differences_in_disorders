#!/bin/bash

datalist=/projects/kg98/trangc/VBM/data/dataset_list_surfaceAll.txt

for dataset in `cat ${datalist}`
do

	export dataset=$dataset
	num=$(($(wc -l < /projects/kg98/trangc/VBM/data/${dataset}/subject_use.txt) - 1))
	printf "\n${dataset} ${num}" >> /projects/kg98/trangc/VBM/data/number_subject.txt

done
