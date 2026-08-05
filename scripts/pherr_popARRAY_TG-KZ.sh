#!/bin/bash

#SBATCH --partition=t1standard
#SBATCH --nodes=3
#SBATCH --ntasks-per-node=24
#SBATCH --ntasks=24
#SBATCH --job-name=fst_scan_TG-KZ
#SBATCH --output=/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/job_outfiles/fst/pherr_fst_scan_TG-KZ_%A-%a.out
#SBATCH --error=/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/job_outfiles/fst/pherr_fst_scan_TG-KZ_%A-%a.err
#SBATCH --array=1-26%5


ulimit -s unlimited
ulimit -l unlimited

module purge
module load bzip2/1.0.8 GCCcore/11.3.0

JOBS_FILE=/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/scripts/pherr_angsdARRAY_input.txt
IDS=$(cat ${JOBS_FILE})

for sample_line in ${IDS}
do
        job_index=$(echo ${sample_line} | awk -F ":" '{print $1}')
        chrom=$(echo ${sample_line} | awk -F ":" '{print $2}')
        if [[ ${SLURM_ARRAY_TASK_ID} == ${job_index} ]]; then
                break
        fi
done

# calculate SAF for Togiak
angsd -b /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/pherr_togiak_bamslist.txt \
-r ${chrom}: -sites /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/spawning/pherr_wholegenome_spawning_polymorphic.sites \
-ref /center1/GLASSLAB/salmgren/atlantic_herring/GCF_900700415.2_Ch_v2.0.2_genomic.fna \
-anc /center1/GLASSLAB/salmgren/atlantic_herring/GCF_900700415.2_Ch_v2.0.2_genomic.fna \
-out /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/diversity/pherr_TG_${chrom}_polymorphic_folded \
-nThreads 5 \
-GL 1 \
-doGlf 3 \
-doMaf 1 \
-doMajorMinor 1 \
-trim 0 \
-C 50 \
-minMapQ 15 \
-minQ 15 \
-doCounts 1 \
-setminDepth 20 \
-setmaxDepth 100 \
-remove_bads 1 \
-uniqueOnly 1 \
-only_proper_pairs 1 \
-doSaf 1

# calculate SAF for Kotzebue 
angsd -b /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/pherr_kotzebue_bamslist.txt \
-r ${chrom}: -sites /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/spawning/pherr_wholegenome_spawning_polymorphic.sites \
-ref /center1/GLASSLAB/salmgren/atlantic_herring/GCF_900700415.2_Ch_v2.0.2_genomic.fna \
-anc /center1/GLASSLAB/salmgren/atlantic_herring/GCF_900700415.2_Ch_v2.0.2_genomic.fna \
-out /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/diversity/pherr_KZ_${chrom}_polymorphic_folded \
-nThreads 5 \
-GL 1 \
-doGlf 3 \
-doMaf 1 \
-doMajorMinor 1 \
-trim 0 \
-C 50 \
-minMapQ 15 \
-minQ 15 \
-doCounts 1 \
-setminDepth 19 \
-setmaxDepth 95 \
-remove_bads 1 \
-uniqueOnly 1 \
-only_proper_pairs 1 \
-doSaf 1
    # p-value and minMAF not included, since they distort the SAF 

# estimate SFS from SAF for both pops and fold together
realSFS /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/diversity/pherr_TG_${chrom}_polymorphic_folded.saf.idx \
-fold 1 /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/diversity/pherr_KZ_${chrom}_polymorphic_folded.saf.idx \
-fold 1 > /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/diversity/pherr_TG-KZ_${chrom}_polymorphic_folded.sfs

# calculate per-site Fst values for folded pops
realSFS fst index /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/diversity/pherr_TG_${chrom}_polymorphic_folded.saf.idx \
-fold 1 /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/diversity/pherr_KZ_${chrom}_polymorphic_folded.saf.idx \
-fold 1 -sfs /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/diversity/pherr_TG-KZ_${chrom}_polymorphic_folded.sfs \
-fstout /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/fst/pherr_TG-KZ_${chrom}_polymorphic_folded.sfs.pbs \
-whichFst 1 # which Fst estimator 


realSFS fst stats2 /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/fst/pherr_TG-KZ_${chrom}_polymorphic_folded.sfs.pbs.fst.idx \
-win 1 -step 1 > /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/fst/pherr_TG-KZ_${chrom}_polymorphic_folded.sfs.pbs.fst.txt
    # -win & -step are for sliding windows (-1 and -1 are for every site)
