#!/bin/bash

#SBATCH --partition=bio
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --ntasks=24
#SBATCH --mem=214G
#SBATCH --job-name=trim
#SBATCH --output=/center1/GLASSLAB/salmgren/lcwgs/job_outfiles/pherr_trim_%A-%a.out
#SBATCH --error=/center1/GLASSLAB/salmgren/lcwgs/job_outfiles/pherr_trim_%A-%a.err
#SBATCH --array=1-120%5

ulimit -s unlimited
ulimit -l unlimited

module purge
module load Java/11.0.16

JOBS_FILE=/center1/GLASSLAB/salmgren/lcwgs/scripts/pherr_trimARRAY_input_PM_CB.txt
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

# use trimmomatic for quality + adapter trimming 
java -jar ${TRIMMOMATIC} PE -threads 4 -phred33 ${fq_r1} ${fq_r2} \
/center1/GLASSLAB/salmgren/lcwgs/trimmed/${sample_id}_trimmed_R1_paired.fastq.gz \
/center1/GLASSLAB/salmgren/lcwgs/trimmed/${sample_id}_trimmed_R1_unpaired.fastq.gz \
/center1/GLASSLAB/salmgren/lcwgs/trimmed/${sample_id}_trimmed_R2_paired.fastq.gz \
/center1/GLASSLAB/salmgren/lcwgs/trimmed/${sample_id}_trimmed_R2_unpaired.fastq.gz \
ILLUMINACLIP:/home/salmgren/applications/Trimmomatic-0.39/adapters/NexteraPE-PE.fa:2:30:10:1:true MINLEN:40
        # 2(mismatches allowed):30(bp overlap required between R1 R2):10(min bp to match before trimming):1(min adapter bp):true(keep both reads)
        # Togiak & Cordova samples = TruSeq3 adapters 
        # all other samples = NexteraPE adapters
# use fastp for quality + polyG tail trimming 
fastp --trim_poly_g -L -A --cut_right \
-i /center1/GLASSLAB/salmgren/lcwgs/trimmed/${sample_id}_trimmed_R1_paired.fastq.gz \
-o /center1/GLASSLAB/salmgren/lcwgs/trimmed/${sample_id}_trimmed_clipped_R1_paired.fastq.gz \
-I /center1/GLASSLAB/salmgren/lcwgs/trimmed/${sample_id}_trimmed_R2_paired.fastq.gz \
-O /center1/GLASSLAB/salmgren/lcwgs/trimmed/${sample_id}_trimmed_clipped_R2_paired.fastq.gz \
-h /center1/GLASSLAB/salmgren/lcwgs/trimmed/${sample_id}_trimmed_clipped_paired_report.html
        # -L = disable length filtering
        # -A = disable adapter trimming
        # --cut-right = sliding window (4 bp) from front to tail, if meet one window with mean quality < Q20, drop the bases in the window and the right part, then stop
