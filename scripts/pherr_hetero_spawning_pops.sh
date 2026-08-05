#!/bin/bash

#SBATCH --partition=bio
#SBATCH --nodes=1
#SBATCH --mem=214G
#SBATCH --ntasks-per-node=24
#SBATCH --ntasks=24
#SBATCH --job-name=hetero
#SBATCH --output=/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/job_outfiles/diversity/pherr_het_spawning_pops_%A.out
#SBATCH --error=/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/job_outfiles/diversity/pherr_het_spawning_pops_%A.err

ulimit -s unlimited
ulimit -l unlimited

module purge
module load bzip2/1.0.8 GCCcore/11.3.0

realSFS /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/diversity/pherr_UA_wholegenome_polymorphic.saf.idx > pherr_UA_wholegenome_polymorphic_het.ml
realSFS /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/diversity/pherr_KZ_wholegenome_polymorphic.saf.idx > pherr_KZ_wholegenome_polymorphic_het.ml
realSFS /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/diversity/pherr_TG_wholegenome_polymorphic.saf.idx > pherr_TG_wholegenome_polymorphic_het.ml
realSFS /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/diversity/pherr_GB_wholegenome_polymorphic.saf.idx > pherr_GB_wholegenome_polymorphic_het.ml
realSFS /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/diversity/pherr_NI_wholegenome_polymorphic.saf.idx > pherr_NI_wholegenome_polymorphic_het.ml
realSFS /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/diversity/pherr_NS_wholegenome_polymorphic.saf.idx > pherr_NS_wholegenome_polymorphic_het.ml
realSFS /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/diversity/pherr_PM_wholegenome_polymorphic.saf.idx > pherr_PM_wholegenome_polymorphic_het.ml

