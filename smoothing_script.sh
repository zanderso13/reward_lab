#!/bin/bash

#SBATCH -A p30954
#SBATCH -p short
#SBATCH -t 00:20:00
#SBATCH --mem=30G

matlab -nodisplay -nosplash -nodesktop -r "addpath(genpath('~/repo')); ica_single_smooth_rewlab('RiDE123','placebo',1,0); quit"

