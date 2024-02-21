import os
ACCESSNB = [elt for elt in os.listdir('data/ncbi/') if elt.startswith('GC') == True]
DOMAIN = ['KRAB', 'SET', 'SSXRD', 'ZF']

rule all:
    """
    Get the prdm9 stats
    """
    input:
        stats_prdm9 = expand("results/{accession}/summary_table_prdm9_{accession}.csv", accession=ACCESSNB),
        krab = "table_results/krab_data.csv",
        krabzf = "table_results/krabzf_data.csv",
        zf = "table_results/zf_count.csv",
        table ="table_results/table_prdm9.csv"

include: "module_get_faa.smk" 
include: "module_stats_prdm9.smk"

