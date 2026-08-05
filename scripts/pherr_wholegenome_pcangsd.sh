#!/bin/bash

#SBATCH --partition=bio
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --ntasks=24
#SBATCH --mem=214G
#SBATCH --job-name=wg_pca
#SBATCH --output=/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/job_outfiles/pca/pherr_wholegenome_pca_%A.out
#SBATCH --error=/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/job_outfiles/pca/pherr_wholegenome_pca_%A.err

module purge
module load bzip2/1.0.8 GCCcore/11.3.0

pcangsd --threads 10 \
--beagle /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/pherr_wholegenome_polymorphic.beagle.gz \
-o /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/pca/pherr_wholegenome_pca_polymorphic \
--sites_save \
--pcadapt \
--iter 500
