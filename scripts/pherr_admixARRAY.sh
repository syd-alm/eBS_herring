#!/bin/bash
#SBATCH --partition=bio
#SBATCH --nodes=1
#SBATCH --mem=214G
#SBATCH --ntasks-per-node=24
#SBATCH --job-name=pherr_wgp-admix
#SBATCH --output=/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/job_outfiles/admix/pherr_wholegenome_spawning_admix_%A-%a.out
#SBATCH --error=/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/job_outfiles/admix/pherr_wholegenome_spawning_admix_%A-%a.err
#SBATCH --array=1-10%4

for k_val in {1..10}
do
        if [[ ${SLURM_ARRAY_TASK_ID} == ${k_val} ]]; then
                break
        fi
done

NGSadmix -likes /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/spawning/pherr_wholegenome_spawning_polymorphic.beagle.gz -K ${k_val} -outfiles /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/admixture/pherr_wholegenome-polymorphic_k${k_val}-0 -P 10 -minMaf 0
NGSadmix -likes /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/spawning/pherr_wholegenome_spawning_polymorphic.beagle.gz -K ${k_val} -outfiles /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/admixture/pherr_wholegenome-polymorphic_k${k_val}-1 -P 10 -minMaf 0
NGSadmix -likes /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/spawning/pherr_wholegenome_spawning_polymorphic.beagle.gz -K ${k_val} -outfiles /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/admixture/pherr_wholegenome-polymorphic_k${k_val}-2 -P 10 -minMaf 0
