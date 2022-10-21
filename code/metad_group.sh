#!/bin/bash
subjects=(`echo {1..265}`)  # Set the subject ID to process here 
BIDS_path="/mnt/scratch/BIDS/"

for sub in ${subjects[@]}; do

    sbatch metad.sh $sub

done