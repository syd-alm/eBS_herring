#!/bin/bash

#SBATCH --partition=bio
#SBATCH --nodes=1
#SBATCH --mem=214G
#SBATCH --ntasks-per-node=24
#SBATCH --ntasks=24
#SBATCH --job-name=sfs_KZ
#SBATCH --output=/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/job_outfiles/diversity/pherr_sfs_KZ_%A.out
#SBATCH --error=/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/job_outfiles/diversity/pherr_sfs_KZ_%A.err

ulimit -s unlimited
ulimit -l unlimited

module purge
module load bzip2/1.0.8 GCCcore/11.3.0

# kotz saf 
angsd -b /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/pherr_kotzebue_bamslist.txt \
-sites /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/spawning/pherr_wholegenome_spawning_polymorphic.sites \
-ref /center1/GLASSLAB/salmgren/atlantic_herring/GCF_900700415.2_Ch_v2.0.2_genomic.fna \
-anc /center1/GLASSLAB/salmgren/atlantic_herring/GCF_900700415.2_Ch_v2.0.2_genomic.fna \
-out /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/diversity/pherr_KZ_wholegenome_polymorphic \
-nThreads 10 \
-GL 1 \
-doGlf 2 \
-doMaf 1 \
-doMajorMinor 1 \
-trim 0 \
-C 50 \
-minMapQ 15 \
-minQ 15 \
-doCounts 1 \
-doDepth 1 \
-dumpCounts 3 \
-uniqueOnly 1 \
-remove_bads 1 \
-only_proper_pairs 1 \
-setminDepth 19 \
-setmaxDepth 95 \
-doSaf 1 

# convert to SFS
realSFS /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/diversity/pherr_KZ_wholegenome_polymorphic.saf.idx -fold 1 > /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/diversity/pherr_KZ_wholegenome_polymorphic_folded.sfs
