#!/usr/bin/bash

#SBATCH -A p30954
#SBATCH -p normal
#SBATCH -t 48:00:00
#SBATCH --nodes=2
#SBATCH --mem=128G

matlab -nodisplay -nosplash -nodesktop -r "addpath(genpath('~/repo')); gica_cmd --data /projects/p30954/reward_lab/thc_gift.txt --o /projects/p30954/reward_lab/gift_out/thc; quit"

