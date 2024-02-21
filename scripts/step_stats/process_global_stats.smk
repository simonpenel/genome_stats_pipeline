import os
ACCESSNB = [elt for elt in os.listdir('data/ncbi/') if elt.startswith('GC') == True]

rule all_global:
    input:
        global_stats = expand("results/{accession}/genomic.fna.global_stats.csv", accession=ACCESSNB)

include: "module_get_fna.smk" 
include: "module_global_stats.smk"