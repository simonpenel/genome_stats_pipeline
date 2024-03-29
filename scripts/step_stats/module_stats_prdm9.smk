configfile: "scripts/step_stats/config.json"

if config["mode"] == "guix":
    RUNCMD="guix shell hmmer -- "
else:
    RUNCMD=""

rule get_blastdb:
    """
    Genere a blast db
    WARNING: formatdb is used and not makeblastdb. Suffixes and options are different with makeblastdb
    """
    input:
        fasta = "data/ncbi/{accession}/protein.faa"
    output:    
        psq="data/ncbi/{accession}/protdb.psq",
        psi="data/ncbi/{accession}/protdb.psi",
        psd="data/ncbi/{accession}/protdb.psd",
        pin="data/ncbi/{accession}/protdb.pin",
        phr="data/ncbi/{accession}/protdb.phr"        
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
        "{RUNCMD} hmmbuild {output} {input}"
 
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
        "{RUNCMD} hmmsearch -E 1E-3 --domE 1E-3 --tblout {output.table} --domtblout {output.domains} --noali {input.model} {input.protein}"


rule tbl_processing:
    """
    Result file processing for a later use.
    """
    input:
        "results/{accession}/hmm_search/tbl/{domain}"
    output:
        "results/{accession}/hmm_search/tbl/{domain}_processed"
    shell:
        "python3 scripts/step_stats/python/hmmsearch_parser.py -i {input} -o {output}"

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
       "python3 scripts/step_stats/python/domain_parser.py -i {input.domain_data} -o {output.processed} -s {output.summary}"


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
        "python3 scripts/step_stats/python/table_builder.py -a {wildcards.accession} -o {output}"


rule read_table:
    """
    Reads each summary table and runs a blastp analysis on every candidate
    """
    input:
        "results/{accession}/summary_table_prdm9_{accession}.csv",
        psq="data/ncbi/{accession}/protdb.psq",
        psi="data/ncbi/{accession}/protdb.psi",
        psd="data/ncbi/{accession}/protdb.psd",
        pin="data/ncbi/{accession}/protdb.pin",
        phr="data/ncbi/{accession}/protdb.phr"   
        
    output:
        "results/{accession}/blastp.txt",
    shell:
        """
        python3 scripts/step_stats/python/blastp_analysis.py results/{wildcards.accession}/summary_table_prdm9_{wildcards.accession}.csv {wildcards.accession}\
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
        python3 scripts/step_stats/python/blastp_table.py\
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
        "python3 scripts/step_stats/python/taxonomy.py"

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
        python3 scripts/step_stats/python/krab.py\
        && python3 scripts/step_stats/python/krabzf.py\
        && python3 scripts/step_stats/python/zf_analysis.py\
        && python3 scripts/step_stats/python/table_prdm9.py
        """
