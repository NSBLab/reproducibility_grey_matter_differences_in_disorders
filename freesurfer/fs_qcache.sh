#!/bin/env bash

#------------specify the RESOURSE below ---------
#SBATCH -A kg98                            # which project we belong, oh21 by default.
# SBATCH --ntasks=1
# SBATCH --ntasks-per-node=16
#SBATCH --cpus-per-task=1                 # request one cpu for each job
# SBATCH --mail-user=trang.cao@monash.edu
# SBATCH --mail-type=FAIL
# SBATCH --mail-type=BEGIN
# SBATCH --mail-type=END
#SBATCH --mem-per-cpu=8G                  # request 4G of RAM
#SBATCH -t 0-10:00:00                           # request 30 mins for the wall-time
# SBATCH --qos shortq

#------------specify the software and variable below ----------
module load freesurfer/7.1.0

export SUBJECTS_DIR=/home/trangc/kg98/trangc/VBM/data/$DATASET/freesurfer


#------------actual job below ---------------------

recon-all -s $sub -qcache

