#!/usr/bin/bash
#
#SBATCH -A p30954
#SBATCH -p normal
#SBATCH -t 12:00:00
#SBATCH --mem=64G
#SBATCH -J bidskit

cd /projects/p30954/reward_lab/bids_thc

bidskit
