rule calc_gobal_stats:
    """
    Calculate global statistics on a fasta file.
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