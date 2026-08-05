# Population genomics of Pacific herring spawning aggregations in the eastern Bering Sea 

Scripts used for data set assembly, analyses, and data visualization associated with my thesis are included here. 

Proquest [link](https://www.proquest.com/pqdtlocal1005781/dissertations-theses/population-genomics-pacific-herring-spawning/docview/3283687542/sem-2?accountid=14470) to thesis

Analyses were performed with UAF's HPC Chinook 

## Data 
where data can be accessed (pending) 

#### <ins>***Laura Timm's [WGSfqs-to-genolikelihoods](https://github.com/letimm/WGSfqs-to-genolikelihoods) generated all scripts**</ins>

#### ***alterations to scripts were made with guidance from a [physalia workshop](https://github.com/nt246/physalia-lcwgs/tree/main) and the  [lcwgs-guide-tutorial](https://github.com/nt246/lcwgs-guide-tutorial)**

# Dataset Compilation 

## **0. Set-Up**
- download programs and such (listed at bottom)
- download reference genome

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;NCBI Reference seq [GCF_900700415.2](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_900700415.2/) for *Clupea harengus*
```
# NCBI uses datasets to manage genome downloads
 conda create -n ncbi_datasets
 conda activate ncbi_datasets
 conda install -c conda-forge ncbi-datasets-cli

# get reference genome
datasets download genome accession GCF_900700415.2 --include gff3,cds,genome,seq-report --filename GCF_900700415.2.zip

```
- Index reference genome with [BWA](https://github.com/syd-alm/eBS_herring/blob/main/setup/GCF_900700415.2_Ch_v2.0.2_genomic_bwa-indexSLURM.sh) and [samtools](https://github.com/syd-alm/eBS_herring/blob/main/setup/GCF_900700415.2_Ch_v2.0.2_genomic_faiSLURM.sh) scripts
- have [list of chromosome names](https://github.com/syd-alm/eBS_herring/blob/main/setup/a_herring_ref_chromosomes.txt) in reference genome for downstream steps
 
## **1. QC of raw reads**
- make input file of raw fastqs with the following format:
```
1:/path/to/fastq1_R1.gz
2:/path/to/fastq1_R2.gz
3:/path/to/fastq2_R1.gz
4:/path/to/fastq2_R2.gz
```
- Run fastQC over raw reads with [raw-fastqcARRAY](https://github.com/syd-alm/eBS_herring/blob/main/qc/pherr-raw_fastqcARRAY.sh) and visualize with [raw-multiQCARRAY](https://github.com/syd-alm/eBS_herring/blob/main/qc/pherr-raw_multiqcSLURM.sh)

<ins>Optional</ins> 
- count raw reads
```
$(echo $(zcat [file] | wc -l) | bc)

```
- can use [read count script](https://github.com/syd-alm/eBS_herring/blob/main/qc/count_reads-raw.sh) and [plotting script](https://github.com/syd-alm/eBS_herring/blob/main/plots/count_reads_plot.R)

## **2. Trimming**
- install TRIMMOMATIC (v0.39) and fastp (v0.23.4)
- make input file of raw fastqs with the following format:

```
1:path/to/fastq1_R1.gz:path/to/fastq1_R2.gz
2:path/to/fastq2_R1.gz:path/to/fastq2_R2.gz
3:path/to/fastq3_R1.gz:path/to/fastq3_R2.gz
```
- trim low adapters, low-quality bases, and adapters with [trimARRAY](https://github.com/syd-alm/eBS_herring/blob/main/qc/pherr_trimARRAY_nextera_input.sh)
    - *change adapter files as needed 
       - Constantine Bay and Port Moller = **NexteraPE**
       - all others = **TruSeq3** (not TruSeq3-2)
    - Make sure adapters are removed in multiQC plots 

- Run fastQC over trimmed reads with [trimmed-fastqcARRAY](https://github.com/syd-alm/eBS_herring/blob/main/qc/pherr-trimmed_fastqcARRAY.sh) and visualize with [trimmed-multiQCARRAY](https://github.com/syd-alm/eBS_herring/blob/main/qc/pherr-trimmed_multiqcSLURM.sh)

 - can also run as interactive job with [in directory with fastqc output]
```
srun -p debug --nodes=1 --exclusive --pty /bin/bash
multiqc .
```

<ins>Optional</ins> 
- count trimmed reads
```
$(echo $(zcat [file] | wc -l) | bc)
```
- can also use [read count script]() and [plotting script]() and compare to raw reads

#### <ins>***move trimmed reads to $archive**</ins>

## **3. Align + filter reads, calculate depths**
  
- make input file of trimmed + paired fastqs with the following format:
```
1:path/to/sample1_trimmed_clipped_R1_paired.fastq.gz:path/to/sample1_trimmed_clipped_R2_trimmed.fastq.gz
2:path/to/sample2_trimmed_clipped_R1_paired.fastq.gz:path/to/sample2_trimmed_clipped_R2_trimmed.fastq.gz
3:path/to/sample3_trimmed_clipped_R1_paired.fastq.gz:path/to/sample3_trimmed_clipped_R2_trimmed.fastq.gz
```
- alignment happens in two sections:
  - [part 1.](https://github.com/syd-alm/eBS_herring/blob/main/scripts/pherr_alignARRAY_pt1.sh) align, convert to sam,  filter out unmapped reads, convert to bam,sort bam, add read group
  - [part 2.](https://github.com/syd-alm/eBS_herring/blob/main/scripts/pherr_alignARRAY_pt2.sh) mark duplicates, clip overlaps, calculate depths, index final aligned bams

- check that bams are good after final indexing 
```
# to check if bams are good/bad
samtools quickcheck -v *_sorted_dedup_clipped_rg.bam > bad_bams.fofn   && echo 'all ok' || echo 'some files failed check, see bad_bams.fofn'
```

- Inspect depth of aligned reads 
input file should look like:
```
1:/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/bamtools/160431.depth.gz
2:/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/bamtools/160432.depth.gz
```
- use depth array script [script](https://github.com/syd-alm/eBS_herring/blob/main/scripts/pherr_depthsARRAY.sh)
  - need [Laura's script](https://github.com/letimm/WGSfqs-to-genolikelihoods/blob/main/mean_cov_ind.py) copied in a directory to run this
- Plot depth distributions in R with [depth script](https://github.com/syd-alm/eBS_herring/blob/main/pherr_depth_plots.R)

#### <ins>***move aligned reads to long-term storage**</ins>

## **4. Calculate genotype likelihoods**
- create [chromosome file](https://github.com/syd-alm/eBS_herring/blob/main/setup/a_herring_ref_chromosomes.txt) for reference genome (*Clupea harengus*)
- using chromosome/contig names, make input file to calculate genotype likelihoods in an array by chromosome/contig
input file format:
```
1:/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/NC_045152.1_polymorphic.beagle.gz 
2:/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/NC_045153.1_polymorphic.beagle.gz
3:/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/NC_045154.1_polymorphic.beagle.gz
```

- use [angsdARRAY script](https://github.com/syd-alm/eBS_herring/tree/main/scripts) to calculate genotype likelihoods 
  - adjust parameters as needed:
    - setMinDepth = *n*
    - setMaxDepth = *5n*
    - -minMaf = 0.05 
    - -SNP_pval = 1e-10 
    - -minMapQ 15 \
    - -minQ 15 \

If calculating likelihoods by chromsome/contig in an array, need to concatenate all beagels and mafs into a whole genome file
- [concatenate beagles](https://github.com/syd-alm/eBS_herring/blob/main/scripts/pherr_concatenate_beagles.sh)
- [concatenate mafs](https://github.com/syd-alm/eBS_herring/blob/main/scripts/pherr_concatenate_mafs.sh)

*check that all chromosomes appear in .err file to make sure they were all included in concatenation 
- can get total SNP count by counting lines in final beagle 


## 5. Paralagous loci filtering 
- script from Laura
- will take a while to run 


yay, the whole dataset is put together! now you can run analyses

## **Pop Gen Analyses**
## 6. PCA
(using pcangsd v1.35)

*Important note:* whatever order the bamlist is in, is what order the samples will be in for all PCAs and admixture analysis

*don't mess this up or your plots will be wrong!*

### whole genome PCA
- run [whole genome pca script](https://github.com/syd-alm/eBS_herring/blob/main/scripts/pherr_wholegenome_pcangsd.sh) over concatenated whole genome beagle 
- can add filtered file to exclude individuals 
  - use --filter flag and add list of 1 (include) and 0 (exclude)
- check in log files that the pca converged 
  - if not, try upping the number on the --iter flag to help
- plot with [pca R script](https://github.com/syd-alm/eBS_herring/blob/main/plots/pca_function.R), conveniently made into a function that also includes a bar graph in the lower right of the eigenvalues

### by chromosome PCA
- make input file with location of each chromosome/contig beagle file, which should look like:
```
1:/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/NC_045152.1_polymorphic.beagle.gz 
2:/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/NC_045153.1_polymorphic.beagle.gz
3:/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/gls/NC_045154.1_polymorphic.beagle.gz
```
- run pcangsd  over each chromosome individually with [pcangsd array script](https://github.com/syd-alm/eBS_herring/blob/main/scripts/pherr_pcangsdARRAY_by_chrom_spawning.sh) 
  - still need to make sure that each chromosome/contig convered in out files
- plot each individually, which you can also do with this great [loop function](https://github.com/syd-alm/eBS_herring/blob/main/plots/pca_by_chrom_loop.R)!

## **Admixture**
- run with NGSadmix
- can run in an [array script](https://github.com/syd-alm/eBS_herring/blob/main/scripts/pherr_admixARRAY.sh) to save time (will already be time intensive)
  - adjust number of K values tested to fit dataset
  - good idea to run a few replicates (3 in this case)
- [plot with pophelper in R](https://github.com/syd-alm/eBS_herring/blob/main/plots/admix.R)
- can use this command wherever .log files are stored to extract log likelihood values:
```
extract_fname_bestlike() {
  printf "fname\tbest_like\n"
  for f in "$@"; do
    awk '
      /^Input:/ {
        if (match($0, /fname=[^[:space:]]+/)) {
          fname = substr($0, RSTART+6, RLENGTH-6)
        }
      }
      /^best like=/ {
        line = $0
        sub(/^best like=/, "", line)
        split(line, a, /[[:space:]]+/)
        best = a[1]
      }
      END {
        if (fname == "") fname = "NA"
        if (best == "") best = "NA"
        print fname "\t" best
      }
    ' "$f"
  done
}

extract_fname_bestlike *.log > all_linked_bestlike.txt
```
## Genetic diversity indicies
- before running any indices, need to calculate whole genome site allele frequency (saf) and site frequency spectrum (sfs) for all populations 
  - for --sites flag, supply the whole genome beagle sites file of all sampled individuals 
- input file should be list of bams

[calculate saf and sfs](https://github.com/syd-alm/eBS_herring/blob/main/scripts/pherr_sfs_KZ.sh) use -doSaf flag, convert to sfs for each population 
  - only included a script from one population, but should be used for each 

### pairwise (whole genome) Fst values:
- use [pairwise Fst script](https://github.com/syd-alm/eBS_herring/blob/main/scripts/pherr_fst_TG-KZ.sh)
- gives you a global Fst value in outfile
- can plot in a [Fst heatmap](https://github.com/syd-alm/eBS_herring/blob/main/plots/pairwise_fst_heatmap.R)


### sitewise Fst values:
- can calculate saf, sfs, and fst by chromosome in an array 
  - needs to be done for each population, but only includes a script for one combo
    - would be slick to have a variable to replace populations with a command instead of making a whole new script each time lol

[part 2.](https://github.com/syd-alm/eBS_herring/blob/main/scripts/pherr_popARRAY_TG-KZ.sh) use popARRAy script with -fst index and -fst stats, use .ml files for heterozygosity calculations 

- can use these by chromosome Fst values to plot Manhattan plots
  - still have to [concatenate all Fst values](https://github.com/syd-alm/eBS_herring/blob/main/scripts/pherr_concatenate_fst_TG-KZ.sh) for each population comparison so that you only have to read  1 file into R, instead of a new file for each chromosome 
- visualize concatenated file in [Manhattan plot](https://github.com/syd-alm/eBS_herring/blob/main/plots/wholegenome_fst_manhattan.R)

### heterozygosity 
- use .ml files from previous scripts to calculate heterozygosity by individual [heterozygosity script](https://github.com/syd-alm/eBS_herring/blob/main/scripts/individual_hetero.sh)
  - input should be individual bam list, not pop bam list
```
1:/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/bamtools/160431_sorted_dedup_clipped_rg.bam
2:/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/bamtools/160434_sorted_dedup_clipped_rg.bam
3:/center1/GLASSLAB/salmgren/lcwgs/ebs_popgen/bamtools/160435_sorted_dedup_clipped_rg.bam
```
- can average all idividuals from the population to get overall population heterozygsoity value
- how to interpert .ml files (from conversation with Laura):
  - first number = the total number of sites (taking seq error into account, so a sum of the genotype likelihoods for the individual, which is why the value isn't a whole number)
  - second number = the number of heterozygous sites
  - third number = ??? nobody knows?
    - so individual heterozygosity is second number / sum of first and second value. (Technically, it's the 2nd num / sum(1st, 2nd, and 3rd), but the third is always 0 in my data)
    - EX) .ml = 3781870.188860 1335719.811140 0.000000
      1335719.811140 / (3781870.188860 + 1335719.811140 + 0.000000) = 0.261

- can plot averages and individual ranges in [violin/box plots](https://github.com/syd-alm/eBS_herring/blob/main/plots/individual_heterozygosity.R)

### nucleotide diversity 
- calculate by population using agnsd -doThetas in [script](https://github.com/syd-alm/eBS_herring/blob/main/scripts/pherr_thetas_TG.sh)
- can also [plot](https://github.com/syd-alm/eBS_herring/blob/main/plots/nucleotide_diversity.R) in violin/boxplots

## Other things
- [mantel test in R](https://github.com/syd-alm/eBS_herring/blob/main/plots/ibd_mantel.R) for isolation by distance
- [sampling map in R](https://github.com/syd-alm/eBS_herring/blob/main/plots/sampling_map.R)


## **00. Program downloads & versions used**
- install angsd (angsd version: 0.940-dirty (htslib: 1.20) build (Apr  3 2024 04:57:10))
```
# ANGSD install 
# DO NOT USE THE CONDA INSTALL! (see https://github.com/ANGSD/angsd/issues/385)
# transfer latest angsd gitfile from https://www.popgen.dk/angsd/index.php/Installation to your software directory on chinook
wget http://popgen.dk/software/download/angsd/angsd0.940.tar.gz
tar xf angsd0.940.tar.gz
cd htslib
make
cd ../angsd
make HTSSRC=../htslib
cd ..
rm angsd0.940.tar.gz
```

- pcangsd (v1.35)
```
ImportError: cannot import name 'reader_cy' from 'pcangsd'
solution = re-download pcangsd with instructions from directions from https://github.com/Rosemeis/pcangsd/issues/61  
```
- fastQC v0.12.1 and multiQC (v1.23)
- fastp v0.23.4
- picard v3.1.1
- trimmomatic v0.39
- bwa v0.7.17
- samtools v1.20
- bamutil v1.0.15
- angsd v0.940
- pcangsd v1.35
- eigen in R v4.5.0
- ggplot2 v3.5.2
- NGSadmix 
- pophelper in R v2.3.1
- geosphere in R v 1.5.20
- vegan packaing in R v2.6.10


