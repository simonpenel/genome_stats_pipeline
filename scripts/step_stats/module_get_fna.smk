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