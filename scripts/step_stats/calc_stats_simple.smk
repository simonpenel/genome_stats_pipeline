import os
ACCESSNB = [elt for elt in os.listdir('data/ncbi/') if elt.startswith('GC') == True]


rule all:
    """
    Get all the stats
    """
    input:
        stats_on_dna_1 = expand("results/{accession}/stats_on_dna_1_{accession}.csv", accession=ACCESSNB),
        stats_on_dna_2 = expand("results/{accession}/stats_on_dna_2_{accession}.csv", accession=ACCESSNB),

rule get_gff:
    """
    Get the gff file as tempory file
    """
    input:
        url_gff="data/ncbi/{accession}/url_genomic.gff.txt"
    output:
        file_gff=temp("data/ncbi/{accession}/genomic.gff")
    shell:
        """
        cd data/ncbi/{wildcards.accession}/ \
        && wget -i url_genomic.gff.txt -O genomic.gff.gz \
        && gunzip  genomic.gff.gz \
        """
 
rule calc_stats_on_dna_1:
    """
    1st  stat 
    """
    input:
        file_gff="data/ncbi/{accession}/genomic.gff"
        
    output:
        table="results/{accession}/stats_on_dna_1_{accession}.csv",
        
    shell:
        """
        cd data/ncbi/{wildcards.accession}/ \
        && cat  genomic.gff|grep A > ../../../{output.table} \
        && cd ../../../
        """

rule calc_stats_on_dna_2:
    """
    2eme  stat, with a different approach
    """
    input:
        file_gff="data/ncbi/{accession}/genomic.gff"
        
    output:
        table="results/{accession}/stats_on_dna_2_{accession}.csv",
        
    shell:
        """
        grep C {input.file_gff} > {output.table}
        """
