#!/bin/bash

#SBATCH --partition=t1standard
#SBATCH --nodes=3
#SBATCH --ntasks-per-node=24
#SBATCH --job-name=fastqc_trimmed
#SBATCH --output=/center1/GLASSLAB/salmgren/lcwgs/job_outfiles/pherr-trim_fastqc_%A-%a.out
#SBATCH --error=/center1/GLASSLAB/salmgren/lcwgs/job_outfiles/pherr-trim_fastqc_%A-%a.err
#SBATCH --array=1-1200%5


JOBS_FILE=/center1/GLASSLAB/salmgren/lcwgs/scripts/pherr-trim_fqcARRAY_input.txt
IDS=$(cat ${JOBS_FILE})

for sample_line in ${IDS}
do
        job_index=$(echo ${sample_line} | awk -F ":" '{print $1}')
        fq=$(echo ${sample_line} | awk -F ":" '{print $2}')
        if [[ ${SLURM_ARRAY_TASK_ID} == ${job_index} ]]; then
                break
        fi
done

fastqc ${fq} -o /center1/GLASSLAB/salmgren/lcwgs/fastqc/trimmed/
