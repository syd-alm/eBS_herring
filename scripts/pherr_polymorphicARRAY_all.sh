pherr_polymorphicARRAY.sh
#!/bin/bash

#SBATCH --partition=bio
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --ntasks=24
#SBATCH --mem=214G
#SBATCH --job-name=glhds_ebs
#SBATCH --output=/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/job_outfiles/genotype_likelihoods/pherr_polymorphic_%A-%a.out
#SBATCH --error=/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/job_outfiles/genotype_likelihoods/pherr_polymorphic_%A-%a.err
#SBATCH --array=1-26%4

module purge
module load bzip2/1.0.8 GCCcore/11.3.0

JOBS_FILE=/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/scripts/pherr_angsdARRAY_input.txt
IDS=$(cat ${JOBS_FILE})

for sample_line in ${IDS}
do
        job_index=$(echo ${sample_line} | awk -F ":" '{print $1}')
        contig=$(echo ${sample_line} | awk -F ":" '{print $2}')
        if [[ ${SLURM_ARRAY_TASK_ID} == ${job_index} ]]; then
                break
        fi
done

angsd -b /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/pherr_filtered_bamslist.txt \
-ref /center1/GLASSLAB/salmgren/atlantic_herring/GCF_900700415.2_Ch_v2.0.2_genomic.fna \
-r ${contig}: -out /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/${contig}_polymorphic \
-nThreads 12 \
-GL 1 \
-doGlf 2 \
-doMaf 1 \
-doMajorMinor 1 \
-trim 0 \
-C 50 \
-minMapQ 15 \
-minQ 15 \
-doCounts 1 \
-setminDepth 180 \
-setmaxDepth 900 \
-minMaf 0.05 \
-SNP_pval 1e-10 \
-doDepth 1 \
-dumpCounts 3 \
-uniqueOnly 1 \
-remove_bads 1 \
-only_proper_pairs 1
