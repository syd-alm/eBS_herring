#!/bin/bash
#SBATCH --partition=bio
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --ntasks=24
#SBATCH --mem=214G
#SBATCH --job-name=pca_chroms_spawning
#SBATCH --output=/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/job_outfiles/pca/pherr_pcangsd_by_chrom_spawning_%A-%a.out
#SBATCH --error=/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/job_outfiles/pca/pherr_pcangsd_by_chrom_spawning_%A-%a.err
#SBATCH --array=1-26%4

module purge
module load bzip2/1.0.8 GCCcore/11.3.0

JOBS_FILE=/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/scripts/pherr_pcangsdARRAY_input.txt
IDS=$(cat ${JOBS_FILE})

for sample_line in ${IDS}
do
        job_index=$(echo ${sample_line} | awk -F ":" '{print $1}')
        beagle_file=$(echo ${sample_line} | awk -F ":" '{print $2}')
        if [[ ${SLURM_ARRAY_TASK_ID} == ${job_index} ]]; then
                break
        fi
done

chrom=$(echo $beagle_file | sed 's!^.*/!!')
chrom=${chrom%.beagle.gz}

pcangsd --threads 8 \
--beagle ${beagle_file} \
--out /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/pca/by_chrom_spawning/${chrom} \
--sites_save \
--pcadapt \
--iter 500
