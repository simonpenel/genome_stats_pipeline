import os
ACCESSNB = [elt for elt in os.listdir('data/ncbi/') if elt.startswith('GC') == True]

rule all:
    input: expand("results/{accession}/genomic.gff.statistics.csv", accession=ACCESSNB)

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
 
rule calc_stats_on_gff3:
    """
    Calculate statistics.
    """
    input:
        gff="data/ncbi/{accession}/genomic.gff",
        fasta="data/ncbi/{accession}/genomic.fna"
    output:
        stats="results/{accession}/genomic.gff.statistics.csv",
        #to be removed because this output file is big
        cds_fasta=temp("data/ncbi/{accession}/genomic.gff.generated_CDS.fa")
        #other files are not moved into results for the moment
        
    shell:
        """
        stats_on_gff3_ncbi {input.gff} {input.fasta} &&
        mv data/ncbi/{wildcards.accession}/genomic.gff.statistics.csv {output.stats}
        """
