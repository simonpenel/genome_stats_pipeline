rule calc_stats_on_gff3:
    """
    Calculate detailed statistics on gff data (need fasta as well).
    """
    input:
        gff="data/ncbi/{accession}/genomic.gff",
        fasta="data/ncbi/{accession}/genomic.fna"
    output:
        stats="results/{accession}/genomic.gff.statistics.csv",
        #to be removed because this output file is big
        cds_fasta=temp("data/ncbi/{accession}/genomic.gff.generated_CDS.fa")
        #other files are not moved into results for the moment
    resources:
        mem_mb: 20000    
    shell:
        """
        stats_on_gff3_ncbi {input.gff} {input.fasta} &&
        mv data/ncbi/{wildcards.accession}/genomic.gff.statistics.csv {output.stats}
        """
        
