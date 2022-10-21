#!/bin/bash
#SBATCH --nodes=1					                            # Requires a single node
#SBATCH --ntasks=1					                            # Run a single serial task
#SBATCH --cpus-per-task=1
#SBATCH --mem=16gb
#SBATCH --time=01:00:00				                            # Time limit hh:mm:ss
#SBATCH -e /mnt/scratch/jobs/error_metad-%A.log	    # Log error
#SBATCH -o /mnt/scratch/jobs/output_metad-%A.log	# Lg output
#SBATCH --job-name=metad     			            # Descriptive job name
##### END OF JOB DEFINITION  #####

# First arg : subject number
/opt/anaconda3/bin/python metad.py ${1}
