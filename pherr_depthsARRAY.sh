#!/bin/bash

#SBATCH --partition=bio
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --ntasks=24
#SBATCH --mem=214G
#SBATCH --job-name=depth
#SBATCH --output=/center1/GLASSLAB/salmgren/lcwgs/job_outfiles/pherr_depths_%A-%a.out
#SBATCH --error=/center1/GLASSLAB/salmgren/lcwgs/job_outfiles/pherr_depths_%A-%a.err
#SBATCH --array=1-120%5

JOBS_FILE=/center1/GLASSLAB/salmgren/lcwgs/scripts/pherr_depthsARRAY_input.txt
IDS=$(cat ${JOBS_FILE})

for sample_line in ${IDS}
do
        job_index=$(echo ${sample_line} | awk -F ":" '{print $1}')
        depth_file=$(echo ${sample_line} | awk -F ":" '{print $2}')
        if [[ ${SLURM_ARRAY_TASK_ID} == ${job_index} ]]; then
                break
        fi
done

touch /center1/GLASSLAB/salmgren/lcwgs/bamtools/pherr_depths.csv
/center1/GLASSLAB/salmgren/lcwgs/scripts/mean_cov_ind.py -i ${depth_file} -o /center1/GLASSLAB/salmgren/lcwgs/bamtools/pherr_depths.csv
  # need mean_cov_ind.py script from Laura 
