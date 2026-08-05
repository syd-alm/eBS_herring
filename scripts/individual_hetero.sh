individual_heterozygosity.sh
#!/bin/bash

#SBATCH --partition=bio
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --ntasks=24
#SBATCH --mem=214G
#SBATCH --job-name=hetero
#SBATCH --output=/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/job_outfiles/heterozygosity/individual_hetero_%A-%a.out
#SBATCH --error=/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/job_outfiles/heterozygosity/individual_hetero_%A-%a.err
#SBATCH --array=1-140%12

ulimit -s unlimited
ulimit -l unlimited

module purge
module load GCCcore/11.3.0 bzip2/1.0.8

JOBS_FILE=/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/scripts/individual_heterozygosity_input.txt
IDS=$(cat ${JOBS_FILE})

for sample_line in ${IDS}
do
	job_index=$(echo ${sample_line} | awk -F ":" '{print $1}')
	alignment=$(echo ${sample_line} | awk -F ":" '{print $2}')
	if [[ ${SLURM_ARRAY_TASK_ID} == ${job_index} ]]; then
		break
	fi
done

sample_id=$(basename "$alignment" | cut -d'_' -f1)

#individual saf
angsd \
	-i ${alignment} \
	-sites /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/spawning/pherr_wholegenome_spawning_polymorphic.sites \
	-ref /center1/GLASSLAB/salmgren/atlantic_herring/GCF_900700415.2_Ch_v2.0.2_genomic.fna \
	-anc /center1/GLASSLAB/salmgren/atlantic_herring/GCF_900700415.2_Ch_v2.0.2_genomic.fna \
	-out /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/diversity/heterozygosity/${sample_id} \
	-dosaf 1 \
	-C 50 \
	-minQ 15 \
	-minmapq 15 \
	-gl 1

#individual het
realSFS /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/diversity/heterozygosity/${sample_id}.saf.idx -fold 1 > /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/diversity/heterozygosity/${sample_id}.ml
