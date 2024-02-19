import os
ACCESSNB = [elt for elt in os.listdir('data/ncbi/') if elt.startswith('GC') == True]

rule all:
    input: expand("data/ncbi/{accession}/genomic.gff.statistics.csv", accession=ACCESSNB)


rule :
    """
    Calculate statistics.
    """
    input:
        gff="data/ncbi/{accession}/genomic.gff",
        fasta="data/ncbi/{accession}/genomic.fna"
    output:
        stats="data/ncbi/{accession}/genomic.gff.statistics.csv"
    shell:
        "stats_on_gff3_ncbi {input.gff} {input.fasta}"

