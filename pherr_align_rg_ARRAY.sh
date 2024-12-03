#!/bin/bash

#SBATCH --partition=t1standard
#SBATCH --nodes=3
#SBATCH --ntasks-per-node=24
#SBATCH --ntasks=24
#SBATCH --job-name=align
#SBATCH --output=/center1/GLASSLAB/salmgren/lcwgs/job_outfiles/pherr_alignment_eBS_%A-%a.out
#SBATCH --error=/center1/GLASSLAB/salmgren/lcwgs/job_outfiles/pherr_alignment_eBS_%A-%a.err
#SBATCH --array=1-120%5

module purge
module load bzip2/1.0.8
module load Python/3.10.4
module load Java/17.0.6
module load GCCcore/11.3.0
module load BWA/0.7.17

JOBS_FILE=/center1/GLASSLAB/salmgren/lcwgs/scripts/pherr_alignARRAY_input_eBS.txt
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

# align to reference genome (which is already indexed) and convert to .sam
bwa mem -M -t 8 /center1/GLASSLAB/salmgren/atlantic_herring/GCF_900700415.2_Ch_v2.0.2_genomic.fna \
${fq_r1} ${fq_r2} 2> /center1/GLASSLAB/salmgren/lcwgs/bwa/${sample_id}_bwa-mem.out > /center1/GLASSLAB/salmgren/lcwgs/bamtools/${sample_id}.sam
        # Flags:
                # -M = for picard compatibility (for dedup)
                # -R = add read group (for compatibility)

# use samtools to convert to bam, filter out unmapped reads 
samtools view -bS -F 4 /center1/GLASSLAB/salmgren/lcwgs/bamtools/${sample_id}.sam > /center1/GLASSLAB/salmgren/lcwgs/bamtools/${sample_id}.bam
rm /center1/GLASSLAB/salmgren/lcwgs/bamtools/${sample_id}.sam
        #Flags:
                # -bS = output is bam(b), ignored for compatability with other samtools versions(S)
                # -F = do not output alignments with bitwise flag 4 (4=reads unmapped)

# convert sam to bam and sort
samtools view -h /center1/GLASSLAB/salmgren/lcwgs/bamtools/${sample_id}.bam | samtools view -buS - | samtools sort -o /center1/GLASSLAB/salmgren/lcwgs/bamtools/${sample_id}_sorted.bam
rm /center1/GLASSLAB/salmgren/lcwgs/bamtools/${sample_id}.bam
        # Flags:
                # -h = include header 
                # -bu = uncompressed (u), change to .bam (-b)
                # "-" input is piped into another command, not the final output 

# add read groups for compatibility with picard (https://broadinstitute.github.io/picard/command-line-overview.html#AddOrReplaceReadGroups)
java -jar /home/salmgren/applications/picard/build/libs/picard.jar AddOrReplaceReadGroups \
      -I /center1/GLASSLAB/salmgren/lcwgs/bamtools/${sample_id}_sorted.bam \
      -O /center1/GLASSLAB/salmgren/lcwgs/bamtools/${sample_id}_sorted_rg.bam \
      -RGID 1 \
      -RGLB eBS \
      -RGPL illumina_novaseq_X \
      -RGPU unit1 \
      -RGSM ${sample_id}

# mark duplicates with picard 
java -jar /home/salmgren/applications/picard/build/libs/picard.jar MarkDuplicates \
I=/center1/GLASSLAB/salmgren/lcwgs/bamtools/${sample_id}_sorted.bam \
O=/center1/GLASSLAB/salmgren/lcwgs/bamtools/${sample_id}_sorted_dedup.bam \
M=/center1/GLASSLAB/salmgren/lcwgs/bamtools/${sample_id}_dups.log \
VALIDATION_STRINGENCY=SILENT REMOVE_DUPLICATES=true
#rm /center1/GLASSLAB/salmgren/lcwgs/bamtools/${sample_id}_sorted.bam

# clip overlaps with bamtools 
bam clipOverlap --in /center1/GLASSLAB/salmgren/lcwgs/bamtools/${sample_id}_sorted_dedup.bam \
--out /center1/GLASSLAB/salmgren/lcwgs/bamtools/${sample_id}_sorted_dedup_clipped.bam \
--stats

rm /center1/GLASSLAB/salmgren/lcwgs/bamtools/${sample_id}_sorted_dedup.bam

# depths
samtools depth -aa /center1/GLASSLAB/salmgren/lcwgs/bamtools/${sample_id}_sorted_dedup_clipped.bam | cut -f 3 | gzip > /center1/GLASSLAB/salmgren/lcwgs/bamtools/${sample_id}.depth.gz
        # Flags: -aa = output all positions (including unused reference sequences)

# index final bams
samtools index /center1/GLASSLAB/salmgren/lcwgs/bamtools/${sample_id}_sorted_dedup_clipped.bam
