# genome_stats_pipeline
Snakemake for stats on genomes

Authors:
Laurent Duret, Simon Penel, Adrien Raimbault

# step 1: get the list of organisms

`snakemake -n -s scripts/step_get_organisms/fetch_data.smk`

# step 2: get the urls

`snakemake -n -s scripts/step_get_urls/data_dl.smk`

# step 3: calculates the statistics

Calculate the global dna statistics for the organisms who are missing it:

`snakemake -n -s scripts/step_stats/process_global_stats.smk`


Calculate the gff dna statistics for the organisms who are missing it:

`snakemake -n -s scripts/step_stats/process_gff3.smk` 



Calculate the global dna statistics AND gff dna statistics for the organisms who are missing global dna statistics and/or gff dna statistics (since input files  will be updated, it will run all the rules depending of these files):

`snakemake -n -s scripts/step_stats/process_all_dna_stats.smk`


Dot not remove temporay files:

`snakemake -n --notemp -s scripts/step_stats/process_all_dna_stats.smk`



Remove temporary files which have not been removed:

`snakemake -n --delete-temp-output -s scripts/step_stats/process_all_dna_stats.smk`


Running on 5 nodes in a local machine:

`/beegfs/data/soft/bioconda/bin/snakemake --cores 5  -s scripts/step_stats/process_all_dna_stats.smk`


Running on 5 nodes in the cluster with conda:

`/beegfs/data/soft/bioconda/bin/snakemake --cluster "sbatch" -j 5  -s scripts/step_stats/process_all_dna_stats.smk`


Running on 5 nodes in the cluster and grouping jobs in the same job on the clusters:

`snakemake --cluster "sbatch" -j 5  --groups get_gff=group0 get_fna=group0 calc_stats_on_gff3=group0 calc_global_stats=group0 -s scripts/step_stats/process_all_dna_stats.smk`



Running on 5 nodes in the cluster using guix (???):

`guix shell snakemake -- snakemake --cluster "sbatch" -j 5  --groups get_gff=group0 get_fna=group0 calc_stats_on_gff3=group0 calc_global_stats=group0 -s scripts/step_stats/process_all_dna_stats.smk`

Example of slurm file to run snakemake directly on a cluster node (here pbil-deb34):

```
#!/bin/sh
#SBATCH--mem=100000
#SBATCH--time=24:00:00
#SBATCH--cpus-per-task=10
#SBATCH--nodelist=pbil-deb34
uname -a
echo starting job
date
snakemake --cores 10 --rerun-incomplete -s scripts/step_stats/process_all_dna_stats.smk
date
echo ok 
```

# Using guix in step_stats

The configuration file allows to use guix, as for example in module_stats_prdm9.smk 

This is usefull when it is not possible/easy to install a software, as for example  when using the cluster.


# Software used by the pipeline 
 
## Blast tools 

* blastp, blastdbcmd,makeblastdb (can be installed and used with guix)

WARNING: the old version of 'formatdb' is used instead 'makeblastdb' because  'makeblastdb' is not working properly on beegfs system.

'formatdb' has to be installed manualy 

## HMMR tools
* hmmbuild, hmmsearch  (currently installed and used with guix)


## dna statistics tools
*  stats_on_gff3_ncbi, stats_on_genomes

to be installed with cargo

`cargo install stats_on_gff3_ncbi`
`cargo install stats_on_genomes`
