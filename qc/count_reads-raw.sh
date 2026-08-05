#!/bin/bash
#SBATCH --partition=bio
#SBATCH --mem=214G
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --job-name=count_reads
#SBATCH --output=/center1/GLASSLAB/salmgren/lcwgs/fastq_files/bering_sea/raw_read_counts_out/read_counts_raw_togiak-%A-%a.out
#SBATCH --error=/center1/GLASSLAB/salmgren/lcwgs/fastq_files/bering_sea/raw_read_counts_out/read_counts_raw_togiak-%A-%a.err
#SBATCH --array=1-80%5

module purge
module load bzip2/1.0.8
module load Java/17.0.6
module load GCCcore/11.3.0
module load BWA/0.7.17

# Directory containing the .fastq.gz files
FASTQ_DIR=/center1/GLASSLAB/salmgren/lcwgs/fastq_files/bering_sea/togiak
OUTPUT_FILE="raw_read_counts_togiak.csv"

# Get the list of .fastq.gz files
FILES=($FASTQ_DIR/*.fastq.gz)

# Get the file for this array task
FILE=${FILES[$SLURM_ARRAY_TASK_ID-1]}

# Get the file name without the directory path
FILE_NAME=$(basename $FILE)

# Count the reads
READ_COUNT=$(echo $(zcat $FILE | wc -l) | bc)

# Output the file name and read count to the output file
echo "$FILE_NAME, $READ_COUNT" >> $OUTPUT_FILE
