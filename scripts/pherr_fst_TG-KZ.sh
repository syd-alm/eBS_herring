#!/bin/bash

#SBATCH --partition=t1standard
#SBATCH --nodes=3
#SBATCH --ntasks-per-node=24
#SBATCH --ntasks=24
#SBATCH --job-name=fst_TG-KZ
#SBATCH --output=/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/job_outfiles/fst/pherr_fst_TG-KZ_%A.out
#SBATCH --error=/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/job_outfiles/fst/pherr_fst_TG-KZ_%A.err

ulimit -s unlimited
ulimit -l unlimited

module purge
module load bzip2/1.0.8 GCCcore/11.3.0

realSFS /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/diversity/pherr_TG_wholegenome_polymorphic.saf.idx /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/diversity/pherr_KZ_wholegenome_polymorphic.saf.idx \
-P 10 -maxIter 30 > /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/diversity/pherr_TG-KZ_wholegenome_polymorphic_unfolded.ml

realSFS fst index /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/diversity/pherr_TG_wholegenome_polymorphic.saf.idx /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/diversity/pherr_KZ_wholegenome_polymorphic.saf.idx \
-sfs /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/diversity/pherr_TG-KZ_wholegenome_polymorphic_unfolded.ml -fstout /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/fst/pherr_TG-KZ_unfolded

realSFS fst stats /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/fst/pherr_TG-KZ_unfolded.fst.idx > /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/fst/pherr_TG-KZ_unfolded.global.fst
