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
        && wget -q -i url_genomic.gff.txt -O genomic.gff.gz \
        && gunzip  genomic.gff.gz \
        """