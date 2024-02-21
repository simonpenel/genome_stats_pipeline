# genome_stats_pipeline
Snakemake for stats on genomes

Authors:
Laurent Duret, Simon Penel, Adrien Raimbault

# 1: get the list of organisms

`snakemake -n -s scripts/step_get_organisms/fetch_data.smk`

# 2: get the url

`snakemake -n -s scripts/step_get_urls/data_dl.smk`

# 3: calculate the statistics

`snakemake -n -s scripts/step_stats/process_global_stats.smk`

This will calculate the global dna statistics for the organisms who are missing it.



`snakemake -n -s scripts/step_stats/process_gff3.smk` 

This will calculate the gff dna statistics for the organisms who are missing it.



`snakemake -n -s scripts/step_stats/process_all_dna_stats.smk`

This will calculate the global dna statistics AND gff dna statistics for the organisms who are missing global dna statistics and/or gff dna statistics (since input files  will be updated, it will run all the rules depending of these files)
