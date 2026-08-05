#!/bin/bash

#SBATCH --partition=t1small
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=24
#SBATCH --ntasks=24
#SBATCH --job-name=cat_mafs
#SBATCH --output=/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/job_outfiles/genotype_likelihoods/pherr_concatenate-mafs_%A.out
#SBATCH --error=/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/job_outfiles/genotype_likelihoods/pherr_concatenate-mafs_%A.err

for i in /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/NC_045152.1_polymorphic.mafs.gz /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/NC_045153.1_polymorphic.mafs.gz /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/NC_045154.1_polymorphic.mafs.gz /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/NC_045155.1_polymorphic.mafs.gz /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/NC_045156.1_polymorphic.mafs.gz /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/NC_045157.1_polymorphic.mafs.gz /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/NC_045158.1_polymorphic.mafs.gz /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/NC_045159.1_polymorphic.mafs.gz /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/NC_045160.1_polymorphic.mafs.gz /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/NC_045161.1_polymorphic.mafs.gz /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/NC_045162.1_polymorphic.mafs.gz /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/NC_045163.1_polymorphic.mafs.gz /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/NC_045164.1_polymorphic.mafs.gz /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/NC_045165.1_polymorphic.mafs.gz /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/NC_045166.1_polymorphic.mafs.gz /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/NC_045167.1_polymorphic.mafs.gz /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/NC_045168.1_polymorphic.mafs.gz /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/NC_045169.1_polymorphic.mafs.gz /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/NC_045170.1_polymorphic.mafs.gz /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/NC_045171.1_polymorphic.mafs.gz /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/NC_045172.1_polymorphic.mafs.gz /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/NC_045173.1_polymorphic.mafs.gz /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/NC_045174.1_polymorphic.mafs.gz /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/NC_045175.1_polymorphic.mafs.gz /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/NC_045176.1_polymorphic.mafs.gz /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/NC_045177.1_polymorphic.mafs.gz
do zcat $i | tail -n +2 -q >> /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/pherr_wholegenome_polymorphic.mafs; done
cut -f 1,2,3,4 /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/pherr_wholegenome_polymorphic.mafs > /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/pherr_wholegenome_polymorphic.sites
gzip /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/pherr_wholegenome_polymorphic.mafs

angsd sites index /center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/pherr_wholegenome_polymorphic.sites
