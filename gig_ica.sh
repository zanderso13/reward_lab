#!/usr/bin/bash

#SBATCH -A p30954
#SBATCH -p short
#SBATCH -t 4:00:00
#SBATCH --nodes=1
#SBATCH --mem=128G

matlab -nodisplay -nosplash -nodesktop -r "addpath(genpath('~/repo')); icatb_batch_file_run('/home/zaz3744/repo/reward_lab/Input_spatial_ica_RiDE_with_spatial.m'); quit"

