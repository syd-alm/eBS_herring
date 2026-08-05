#!/bin/bash

#SBATCH --partition=bio
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --ntasks=24
#SBATCH --mem=214G
#SBATCH --job-name=align
#SBATCH --output=/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/job_outfiles/align/alignment_pt2_%A-%a.out
#SBATCH --error=/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/job_outfiles/align/alignment_pt2_%A-%a.err
#SBATCH --array=1-140%5

ulimit -s unlimited
ulimit -l unlimited

# load modules 
module purge
module load bzip2/1.0.8 
module load Python/3.10.4 
module load Java/17.0.6
module load GCCcore/11.3.0
module load BWA/0.7.17

# sorted/filtered bam --> add read group (rg) --> mark duplicates --> clip overlap --> depths --> index

# specify where input files are
JOBS_FILE=/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/scripts/pherr_alignARRAY_input_pt2.txt
IDS=$(cat ${JOBS_FILE})

for sample_line in ${IDS}
do
        job_index=$(echo ${sample_line} | awk -F ":" '{print $1}')
        bam=$(echo ${sample_line} | awk -F ":" '{print $2}')
        if [[ ${SLURM_ARRAY_TASK_ID} == ${job_index} ]]; then
                break
        fi
done

sample_id=$(echo $bam | sed 's!^.*/!!')
sample_id=${sample_id%%_*}

# mark duplicates with picard 
java -jar /home/salmgren/applications/picard/build/libs/picard.jar MarkDuplicates \
I=/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/bamtools/${sample_id}_sorted_rg.bam \
O=/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/bamtools/${sample_id}_sorted_dedup_rg.bam \
M=/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/bamtools/${sample_id}_dups_rg.log \
VALIDATION_STRINGENCY=SILENT REMOVE_DUPLICATES=true
rm /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/bamtools/${sample_id}_sorted_rg.bam

# clip overlaps with bamtools 
bam clipOverlap --in /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/bamtools/${sample_id}_sorted_dedup_rg.bam \
--out /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/bamtools/${sample_id}_sorted_dedup_clipped_rg.bam \
--stats
#rm /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/bamtools/${sample_id}_sorted_dedup_rg.bam

# depths
samtools depth -aa /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/bamtools/${sample_id}_sorted_dedup_clipped_rg.bam | cut -f 3 | gzip > /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/bamtools/${sample_id}.depth.gz
        # Flags: -aa = output all positions (including unused reference sequences)

# index final bams
samtools index /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/bamtools/${sample_id}_sorted_dedup_clipped_rg.bam
