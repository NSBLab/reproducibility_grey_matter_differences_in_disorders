#!/bin/env bash

DATASET=ABIDEII
SUBJLIST=/projects/kg98/trangc/VBM/data/${DATASET}/sub_without_outlier_marked.txt



while IFS= read -r line
do 

	
 		echo ${cut -d$'\t' -f 6}
		

done < "$SUBJLIST"
