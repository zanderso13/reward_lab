#!/usr/bin/bash

#SBATCH -A p30954
#SBATCH -p normal
#SBATCH -t 24:00:00
#SBATCH --mem=64G
#SBATCH -J fmriprep_single_sub

module purge
module load singularity/latest
echo "modules loaded" 
cd /projects/b1108
pwd
echo "beginning preprocessing"

singularity run --cleanenv -B /projects/b1108:/projects/b1108 -B /projects/p30954/reward_lab /projects/b1108/software/singularity_images/fmriprep-23.2.1.simg /projects/p30954/reward_lab/bids_missing /projects/p30954/reward_lab/fmriprep participant --participant-label ${1} --fs-license-file /projects/b1108/software/freesurfer_license/license.txt --fs-no-reconall -w /projects/p30954/reward_lab/work --skip_bids_validation
