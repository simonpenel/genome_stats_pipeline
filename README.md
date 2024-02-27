# genome_stats_pipeline
Snakemake for stats on genomes

Authors:
Laurent Duret, Simon Penel, Adrien Raimbault

# step 1: get the list of organisms

`snakemake -n -s scripts/step_get_organisms/fetch_data.smk`

# step 2: get the urls

`snakemake -n -s scripts/step_get_urls/data_dl.smk`

# step 3: calculates the statistics

`snakemake -n -s scripts/step_stats/process_global_stats.smk`

This will calculate the global dna statistics for the organisms who are missing it.



`snakemake -n -s scripts/step_stats/process_gff3.smk` 

This will calculate the gff dna statistics for the organisms who are missing it.


`snakemake -n -s scripts/step_stats/process_all_dna_stats.smk`

This will calculate the global dna statistics AND gff dna statistics for the organisms who are missing global dna statistics and/or gff dna statistics (since input files  will be updated, it will run all the rules depending of these files)



`snakemake -n --notemp -s scripts/step_stats/process_all_dna_stats.smk`

Dot not remove temporay files


`snakemake -n --delete-temp-output -s scripts/step_stats/process_all_dna_stats.smk`

Remove temporary files which have not been removed

`/beegfs/data/soft/bioconda/bin/snakemake --cluster "sbatch" -j 5  -s scripts/step_stats/process_all_dna_stats.smk`

Running on 5 nodes in the cluster.

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
