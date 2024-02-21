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

This will calculate the global statistics for the organisms who are missing global statistics



`snakemake -n -s scripts/step_stats/process_gff3.smk` 

This will calculate the gff statistics for the organisms who are missing gff statistics



`snakemake -n -s scripts/step_stats/process_all_dna_stats.smk`

This will calculate the global statistics AND gff statistics for the organisms who are missing global statistics and/or gff statistics (since input files  will be updated, it will run all the rules depending of these files)
