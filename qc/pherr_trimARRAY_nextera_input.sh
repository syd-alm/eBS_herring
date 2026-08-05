#!/bin/bash

#SBATCH --partition=bio
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --ntasks=24
#SBATCH --mem=214G
#SBATCH --job-name=trim
#SBATCH --output=/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/job_outfiles/trim/pherr_trimming_%A-%a.out
#SBATCH --error=/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/job_outfiles/trim/pherr_trimming_%A-%a.err
#SBATCH --array=1-200%10

module purge
module load Java/11.0.16


JOBS_FILE=/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/scripts/pherr_trimARRAY_truseq_input.txt
IDS=$(cat ${JOBS_FILE})

for sample_line in ${IDS}
do
        job_index=$(echo ${sample_line} | awk -F ":" '{print $1}')
        fq_r1=$(echo ${sample_line} | awk -F ":" '{print $2}')
        fq_r2=$(echo ${sample_line} | awk -F ":" '{print $3}')
        if [[ ${SLURM_ARRAY_TASK_ID} == ${job_index} ]]; then
                break
        fi
done

sample_id=$(echo $fq_r1 | sed 's!^.*/!!')
sample_id=${sample_id%%_*}

java -jar /home/salmgren/applications/Trimmomatic-0.39/trimmomatic-0.39.jar PE -threads 4 -phred33 ${fq_r1} ${fq_r2} \
/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/trimmed/${sample_id}_trimmed_R1_paired.fq.gz \
/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/trimmed/${sample_id}_trimmed_R1_unpaired.fq.gz \
/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/trimmed/${sample_id}_trimmed_R2_paired.fq.gz \
/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/trimmed/${sample_id}_trimmed_R2_unpaired.fq.gz \
ILLUMINACLIP:/home/salmgren/applications/Trimmomatic-0.39/adapters/TruSeq3-PE.fa:2:30:10:1:true MINLEN:40
	# 2(mismatches allowed):30(bp overlap required between R1 R2):10(min bp to match before trimming):1(min adapter bp):true(keep both reads)

fastp --trim_poly_g -L -A --cut_right \
-i /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/trimmed/${sample_id}_trimmed_R1_paired.fq.gz \
-o /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/trimmed/${sample_id}_trimmed_clipped_R1_paired.fq.gz \
-I /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/trimmed/${sample_id}_trimmed_R2_paired.fq.gz \
-O /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/trimmed/${sample_id}_trimmed_clipped_R2_paired.fq.gz \
-h /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/trimmed/${sample_id}_trimmed_clipped_paired_report.html
	# -L = disable length filtering
	# -A = disable adapter trimming
	# --cut-right = sliding window (4 bp) from front to tail, if meet one window with mean quality < Q20, drop the bases in the window and the right part, then stop
