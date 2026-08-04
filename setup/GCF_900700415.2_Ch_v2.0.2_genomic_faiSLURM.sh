#!/bin/bash

#SBATCH --partition=bio
#SBATCH --mem=214G
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --ntasks=24
#SBATCH --job-name=fai_GCF_900700415.2_Ch_v2.0.2_genomic
#SBATCH --output=/center1/GLASSLAB/salmgren/lcwgs/job_outfiles/fai_GCF_900700415.2_Ch_v2.0.2_genomic.out
#SBATCH --error=/center1/GLASSLAB/salmgren/lcwgs/job_outfiles/fai_GCF_900700415.2_Ch_v2.0.2_genomic.err

module purge
module load bzip2/1.0.8 
module load Python/3.10.4 
module load Java/17.0.6
module load GCCcore/11.3.0
module load BWA/0.7.17

samtools faidx /center1/GLASSLAB/salmgren/atlantic_herring/GCF_900700415.2_Ch_v2.0.2_genomic.fna
