#!/bin/bash

# Directory and file setup
dataDir="/projects/kg98/trangc/VBM/data"
cereInfo="/home/trangc/kg98/trangc/atlases/Human_cerebellum/Buckner-whole_1mm_CAT12MNI.nii.gz"  # not used directly in Bash
nParcList=(100 500 1000)
diagnosisString=("SCZ" "ASD" "MDD" "AD") #"BD" "SCA" "SCZ" 
export nNull=100
smoothKernel=6
export nulldir="/scratch2/kg98/trangc/VBM/data/nulltest/surrogateVBM/s${smoothKernel}COMBAT"
filename="/projects/kg98/trangc/VBM/data/metadataVBM.csv"

# Read header to find column indices
header=$(head -n 1 "$filename")
IFS=',' read -ra cols <<< "$header"

# Get column indices for 'diagnosis_string' and 'site_string'
for i in "${!cols[@]}"; do
  if [[ "${cols[$i]}" == "diagnosis_string" ]]; then diag_col=$((i+1)); fi
  if [[ "${cols[$i]}" == "site_string" ]]; then site_col=$((i+1)); fi
done

# Loop through each diagnosis
for diag in "${diagnosisString[@]}"; do
  echo "Processing diagnosis: $diag"
  export diag=$diag
  # Extract rows matching current diagnosis
  matching_rows=$(awk -F',' -v col="$diag_col" -v value="$diag" '$col == value' "$filename")

  # Extract unique site strings
  siteList=$(echo "$matching_rows" | awk -F',' -v col="$site_col" '{print $col}' | sort | uniq)

  # Loop through each site
  while IFS= read -r site; do
    echo "  - Site: $site"
	export site=$site
    # You can do further processing here
	sbatch --job-name=parc_null_${diag}_${site} parcellate_null_map_batch.sh
  done <<< "$siteList"

done

