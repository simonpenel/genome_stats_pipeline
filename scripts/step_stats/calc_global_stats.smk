import os
ACCESSNB = [elt for elt in os.listdir('data/ncbi/') if elt.startswith('GC') == True]

rule all_global:
    input:
        global_stats = expand("results/{accession}/genomic.fna.global_stats.csv", accession=ACCESSNB)


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

rule get_fna:
    """
    Get the fna file as tempory file
    """
    input:
        url_fna="data/ncbi/{accession}/url_genomic.fna.txt"
    output:
        file_fna=temp("data/ncbi/{accession}/genomic.fna")
    shell:
        """
        cd data/ncbi/{wildcards.accession}/ \
        && wget -i url_genomic.fna.txt -O genomic.fna.gz \
        && gunzip  genomic.fna.gz \
        """
         
rule calc_gobal_stats:
    """
    Calculate global statistics.
    """
    input:
        fasta="data/ncbi/{accession}/genomic.fna"
    output:
        stats="results/{accession}/genomic.fna.global_stats.csv",        
    shell:
        """
        stats_on_genomes {input.fasta} &&
        mv data/ncbi/{wildcards.accession}/genomic.fna.global_stats.csv {output.stats}
        """
