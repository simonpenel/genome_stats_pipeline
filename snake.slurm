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

