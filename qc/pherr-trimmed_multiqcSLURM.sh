#!/bin/bash

#SBATCH --partition=bio
#SBATCH --mem=214G
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --job-name=multiQC_trimmed
#SBATCH --output=/center1/GLASSLAB/salmgren/lcwgs/job_outfiles/pherr-trimmed_multiQC.out
#SBATCH --error=/center1/GLASSLAB/salmgren/lcwgs/job_outfiles/pherr-trimmed_multiQC.err

mamba activate multiqc-1.17
multiqc /center1/GLASSLAB/salmgren/lcwgs/fastqc/trimmed/
