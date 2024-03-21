#!/bin/sh
#SBATCH --job-name=snakemake_main_job
#SBATCH--mem=100000
#SBATCH--time=24:00:00
#SBATCH--cpus-per-task=10
#SBATCH --output=slurm_logs/%x-%j.log
uname -a
echo "install snakemake"
guix install snakemake
echo "starting job"
date
export SBATCH_DEFAULTS=" --output=slurm_logs/%x-%j.log"
snakemake --cores 10 --rerun-incomplete -s scripts/step_stats/process_all_dna_stats.smk
date
echo ok 

