#!/bin/bash

module load freesurfer/7.1.0

datadir=/fs04/kg98/trangc/VBM/data

DATASET_LIST=$datadir/dataset_list_noses2.txt

measure=thickness
measureShort=thick
smoothKernel=10

aparcstats2table 
   --subjectsfile 001 002 003  
   --hemi lh 
   --meas thickness  
   --parc aparc
   --tablefile  aparc_lh_thickness_table.txt

