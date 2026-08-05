#!/bin/bash

#SBATCH --partition=t1small
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --ntasks=24
#SBATCH --job-name=tg_thetas
#SBATCH --output=/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/job_outfiles/thetas/pherr_thetas_TG_%A.out
#SBATCH --error=/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/job_outfiles/thetas/pherr_thetas_TG_%A.err

module purge
module load bzip2/1.0.8 GCCcore/11.3.0

# saf2theta with with output from previous -doSaf script 
realSFS saf2theta \
	/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/diversity/pherr_TG_wholegenome_polymorphic.saf.idx \
	-fold 1 \
	-sfs /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/diversity/pherr_TG_wholegenome_polymorphic_folded.sfs \
    -outname /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/diversity/pherr_TG_wholegenome_polymorphic_folded

thetaStat do_stat /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/diversity/pherr_TG_wholegenome_polymorphic_folded.thetas.idx

# print to txt file 
#thetaStat print \
#	/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/diversity/pherr_TG_wholegenome_polymorphic_folded.thetas.idx.pestPG > /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/diversity/pherr_TG_wholegenome_polymorphic_folded.thetas.txt
# doesn't work
