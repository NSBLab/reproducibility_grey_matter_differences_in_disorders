#!/bin/bash

datadir=/fs04/kg98/trangc/VBM/data

DATASET_LIST=$datadir/dataset_list_surfaceAll.txt

for DATASET in `cat ${DATASET_LIST}`
do

	ls $datadir/$DATASET/qdec_table_*.dat > $datadir/$DATASET/sitelist.txt

	for sitefile in `cat $datadir/$DATASET/sitelist.txt`
	do

		cp $sitefile ${datadir}/temp
	done
done
