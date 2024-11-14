#!/bin/bash

#SBATCH --partition=t1standard
#SBATCH --nodes=3
#SBATCH --ntasks-per-node=24
#SBATCH --job-name=fqc_array_cd
#SBATCH --output=/center1/GLASSLAB/salmgren/lcwgs/job_outfiles/pherr-raw_fastqc_CD_%A-%a.out
#SBATCH --error=/center1/GLASSLAB/salmgren/lcwgs/job_outfiles/pherr-raw_fastqc_CD_%A-%a.err
#SBATCH --array=1-40%5

module purge
module load Java/11.0.16

JOBS_FILE=/center1/GLASSLAB/salmgren/lcwgs/scripts/pherr-raw_fqcARRAY_input_CD.txt
IDS=$(cat ${JOBS_FILE})

for sample_line in ${IDS}
do
        job_index=$(echo ${sample_line} | awk -F ":" '{print $1}')
        fq=$(echo ${sample_line} | awk -F ":" '{print $2}')
        if [[ ${SLURM_ARRAY_TASK_ID} == ${job_index} ]]; then
                break
        fi
done

fastqc ${fq} -o /center1/GLASSLAB/salmgren/lcwgs/fastqc/raw/
