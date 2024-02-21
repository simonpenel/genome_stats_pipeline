import os
ACCESSNB = [elt for elt in os.listdir('data/ncbi/') if elt.startswith('GC') == True]

rule all_gff3:
    input:
        detailed_stats = expand("results/{accession}/genomic.gff.statistics.csv", accession=ACCESSNB),

include: "module_get_gff.smk"
include: "module_get_fna.smk" 
include: "module_gff3.smk"