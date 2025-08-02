#!/bin/bash

datadir=/fs04/kg98/trangc/VBM/data
DATASET_LIST="${datadir}/dataset_list_surface.txt"

sumfile="${datadir}/summary_surface_data.txt"
echo "subID diagnosis sex age site dataset" >> $sumfile

for DATASET in `cat ${DATASET_LIST}`
do

ls $datadir/$DATASET/qdec_table_*.dat > $datadir/$DATASET/sitelist.txt

	for sitefile in `cat $datadir/$DATASET/sitelist.txt`
	do

		echo $sitefile
		sitefield=$(echo "$sitefile" | grep -o -P '(?<=table_).*(?=.dat)') #| awk -F_ '{for (i=3; i<=NF-1; i++) printf "%s_", $i}')
		echo $sitefield
		site=${sitefield:0:${#sitefield}-2}
		echo $site
		diag=${sitefile:${#sitefile}-5:1}
		echo $diag	

		IFS=$'\n'
		for line in $(tail -n +2 "$sitefile")
		do

			IFS=$'\t' read -ra parts <<< "$line"
			#print to summary file
    			echo "${parts[0]} ${parts[1]} ${parts[2]} ${parts[3]} $site $DATASET" >> $sumfile
			
		done
		unset IFS
	done
done


