#!/bin/env bash

#set paths
PROJ_DIR=/home/cche0120/kg98/Charlie/ABIDEI
BIDS_DIR=$PROJ_DIR/ABIDEI_BIDS
OUT_DIR=$PROJ_DIR/ABIDEI_mriqc
WORK_DIR=$PROJDIR/work
GROUP_DIR=$PROJ_DIR/ABIDEI_mriqc_group

if [ ! -d $GROUP_DIR ]; then mkdir $GROUP_DIR; echo "making group directory"; fi

# Load MRIQC module
module purge
module load mriqc/0.14.2

# Run MRIQC group report
mriqc -v $BIDS_DIR $OUT_DIR group \

# Move group report to the group_output folder
mv $OUT_DIR/group_bold.html $GROUP_DIR

mv $OUT_DIR/group_bold.tsv $GROUP_DIR

mv $OUT_DIR/group_T1w.html $GROUP_DIR

mv $OUT_DIR/group_T1w.tsv $GROUP_DIR

 -----------------------------------------------------------------------------------------END------------------------------------------------------------------------------------------


