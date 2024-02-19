configfile: "scripts/step_get_urls/config.json"

with open("data/resources/organisms_data") as reader:
    """
    Creates the list of URL that will be used for download
    """
    PATHLIST = []
    ACCESSNB = []
    CUR_LIST = []
    CURATED = [] # Assemblies with annotation and protein sequence
    for line in reader.readlines()[1:]:
        line_data = line.strip().split('\t')
        if line_data[-1] != 'None': # if there is an existing URL
            ACCESSNB.append(line_data[2])
            PATHLIST.append(f"{line_data[-1]}")
            if line_data[3] == 'True': # if genome is curated
                CUR_LIST.append(f"{line_data[-1]}")
                CURATED.append(line_data[2])
                print(line_data[2], line_data[3])

if config["curated_only"] == 1:
    FINAL = CURATED # Accession number list
    PATHLIST = dict(zip(FINAL, CUR_LIST)) # Dictionary with accession number as keysand URLs as values
else:
    FINAL = ACCESSNB
    PATHLIST = dict(zip(FINAL, PATHLIST))

rule all:
    input: 
        expand("data/ncbi/{accession}/url_protein.faa.txt", accession=CURATED),
        expand("data/ncbi/{accession}/url_genomic.fna.txt", accession=FINAL),
        expand("data/ncbi/{accession}/url_genomic.gff.txt", accession=CURATED)


def GetPath(wildcards):
    return(PATHLIST[wildcards.accession])

rule download_protein_data:
    params:
        http_path = GetPath
    input:
        "data/resources/organisms_data"
    output:
        "data/ncbi/{accession}/url_protein.faa.txt"
    shell:
        """
        cd data/ncbi/{wildcards.accession}/ \
        && echo {params.http_path}_protein.faa.gz > url_protein.faa.txt\
        && cd ../../../
        """
        
rule download_genomic_data:
    params:
        http_path = GetPath
    input:
        "data/resources/organisms_data"
    output:
        "data/ncbi/{accession}/url_genomic.fna.txt"
    shell:
        """
        cd data/ncbi/{wildcards.accession}/ \
        && echo {params.http_path}_genomic.fna.gz > url_genomic.fna.txt\
        && cd ../../../
        """

rule download_annotation_data:
    params:
        http_path = GetPath
    input:
        "data/resources/organisms_data"
    output:
        "data/ncbi/{accession}/url_genomic.gff.txt"
    shell:
        """
        cd data/ncbi/{wildcards.accession}/ \
        && echo  {params.http_path}_genomic.gff.gz  > url_genomic.gff.txt\
        && cd ../../../
        """
