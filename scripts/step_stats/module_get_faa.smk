
rule get_prot_fasta:
     """
     Get the protein fasta file as tempory file
     """
     input:
         url_prot_fasta="data/ncbi/{accession}/url_protein.faa.txt"
     output:
         file_faa="data/ncbi/{accession}/protein.faa"
     shell:
         """
         cd data/ncbi/{wildcards.accession}/ \
         && wget -i url_protein.faa.txt -O protein.faa.gz \
         && gunzip  protein.faa.gz \
         """
