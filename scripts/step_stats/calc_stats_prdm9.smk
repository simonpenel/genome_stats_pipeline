import os
ACCESSNB = [elt for elt in os.listdir('data/ncbi/') if elt.startswith('GC') == True]
DOMAIN = ['KRAB', 'SET', 'SSXRD', 'ZF']

rule all:
    """
    Get all the stats
    """
    input:
        stats_prdm9 = expand("results/{accession}/summary_table_prdm9_{accession}.csv", accession=ACCESSNB),
        krab = "table_results/krab_data.csv",
        krabzf = "table_results/krabzf_data.csv",
        zf = "table_results/zf_count.csv",
        table ="table_results/table_prdm9.csv"

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

rule get_prot_fasta:
     """
     Get the protein fasta file as tempory file
     """
     input:
         url_prot_fasta="data/ncbi/{accession}/url_protein.faa.txt"
     output:
         file_gff=temp("data/ncbi/{accession}/protein.faa")
     shell:
         """
         cd data/ncbi/{wildcards.accession}/ \
         && wget -i url_protein.faa.txt -O protein.faa.gz \
         && gunzip  protein.faa.gz \
         """

rule get_blastdb:
    """
    Genere a blast db
    """
    input:
        fasta = "data/ncbi/{accession}/protein.faa"
    output:    
        psq=temp("data/ncbi/{accession}/protdb.psq"),
        psi=temp("data/ncbi/{accession}/protdb.psi"),
        psd=temp("data/ncbi/{accession}/protdb.psd"),
        pog=temp("data/ncbi/{accession}/protdb.pog"),
        pin=temp("data/ncbi/{accession}/protdb.pin"),
        phr=temp("data/ncbi/{accession}/protdb.phr")        
    shell:
        """
        formatdb -i {input.fasta} -t protdb -n data/ncbi/{wildcards.accession}/protdb -p T -o T
        """
         
rule hmm_build:
    """
    HMM creation.
    """
    input:
        "data/ref_align/Prdm9_Metazoa_Reference_alignment/Domain_{domain}_ReferenceAlignment.fa"
    output:
        "results/hmm_build/{domain}.hmm"
    shell:
        "hmmbuild {output} {input}"
 
rule hmm_search:
    """
    Proteome search using the HMMs.
    """
    input:
        model="results/hmm_build/{domain}.hmm",
        protein="data/ncbi/{accession}/protein.faa"
    output:
        table = "results/{accession}/hmm_search/tbl/{domain}",
        domains = "results/{accession}/hmm_search/domtbl/{domain}_domains"
    shell:
        "hmmsearch -E 1E-3 --domE 1E-3 --tblout {output.table} --domtblout {output.domains} --noali {input.model} {input.protein}"


rule tbl_processing:
    """
    Result file processing for a later use.
    """
    input:
        "results/{accession}/hmm_search/tbl/{domain}"
    output:
        "results/{accession}/hmm_search/tbl/{domain}_processed"
    shell:
        "python scripts/step_stats/hmmsearch_parser.py -i {input} -o {output}"

rule domain_processing:
    """
    Result file processing for a later use.
    """
    input:
        "results/{accession}/hmm_search/tbl/{domain}_processed",
        domain_data="results/{accession}/hmm_search/domtbl/{domain}_domains"
    output:
        processed="results/{accession}/hmm_search/domtbl/{domain}_domains_processed",
        summary="results/{accession}/hmm_search/domtbl/{domain}_domains_summary"
    shell:
       "python scripts/step_stats/domain_parser.py -i {input.domain_data} -o {output.processed} -s {output.summary}"


def domain_done(wildcards):
    return expand("results/" + wildcards.accession + "/hmm_search/domtbl/{domain}_domains_summary" , domain=DOMAIN)

rule table_editing:
    """
    Creation of a summary table of hmm_search results.
    """
    input:
        domain_done
    output:
        "results/{accession}/summary_table_prdm9_{accession}.csv"
    shell:
        "python scripts/step_stats/table_builder.py -a {wildcards.accession} -o {output}"


rule read_table:
    """
    Reads each summary table and runs a blastp analysis on every candidate
    """
    input:
        "results/{accession}/summary_table_prdm9_{accession}.csv",
        psq="data/ncbi/{accession}/protdb.psq",
        psi="data/ncbi/{accession}/protdb.psi",
        psd="data/ncbi/{accession}/protdb.psd",
        pog="data/ncbi/{accession}/protdb.pog",
        pin="data/ncbi/{accession}/protdb.pin",
        phr="data/ncbi/{accession}/protdb.phr"   
        
    output:
        "results/{accession}/blastp.txt",
    shell:
        """
        python3 scripts/step_stats/blastp_analysis.py results/{wildcards.accession}/summary_table_prdm9_{wildcards.accession}.csv {wildcards.accession}\
        """

rule summary:
    """
    Concatenation of each proteome blastp results.
    """
    input: 
        expand("results/{accession}/blastp.txt", accession=ACCESSNB)
    output:
        "results/BLASTP_results/blastp_summary.txt"
    shell:
        """
        cat {input} > {output}
        """

rule blastp_results:
    """
    Writing a table from the concatenation
    """
    input:
        "results/BLASTP_results/blastp_summary.txt"
    output:
        "results/BLASTP_results/blastp_results.csv",
    shell:
        """
        python3 scripts/step_stats/blastp_table.py\
        """

rule taxonomy:
    """
    Creation of a table associating a genome accession number to its complete taxonomy
    """
    input:
        "results/BLASTP_results/blastp_summary.txt"
    output:
        "data/resources/sorted_taxonomy.csv"
    shell:
        "python3 scripts/step_stats/taxonomy.py"

rule create_table:
    """
    Creation of multiple result table using blastp results and hmm search results
    """
    input:
        "results/BLASTP_results/blastp_results.csv",
        "data/resources/sorted_taxonomy.csv"
    output:
        "table_results/krab_data.csv",
        "table_results/krabzf_data.csv",
        "table_results/zf_count.csv",
        "table_results/table_prdm9.csv"
    shell:
        """
        python3 scripts/step_stats/krab.py\
        && python3 scripts/step_stats/krabzf.py\
        && python3 scripts/step_stats/zf_analysis.py\
        && python3 scripts/step_stats/table_prdm9.py
        """
