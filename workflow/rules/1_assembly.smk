# FastQ
rule fastqc_before_trimming:
    input:
        "data/raw/{sample}.fastq"
    output:
        "results/Genomics/1_Assembly/1_Preprocessing/fastqc_before_trimming/{sample}_fastqc.html"
    conda:
        "envs/genomics.yaml"
    script:
        "scripts/Genomics/1_Assembly/1_Preprocessing/ReadQualityCheck.py"

# Assembly
rule flye:
    input:
        reads = lambda wildcards: "data/raw/{}.fastq".format(wildcards.sample.strip().replace("/", ""))
    params:
        genome_size=config["params"]["genome_size"],
        threads=config["threads"]["high"]
    output:
        out_dir = "results/Genomics/1_Assembly/2_Assemblers/flye/{sample}",
        assembly = "results/Genomics/1_Assembly/2_Assemblers/flye/{sample}/assembly.fasta",
        info = "results/Genomics/1_Assembly/2_Assemblers/flye/{sample}/assembly_info.txt"
    #conda:
        #"envs/genomics.yaml"
    shell:
        "flye --nano-raw {input.reads} --genome-size {params.genome_size} --threads {params.threads} --out-dir {output.out_dir}"
# Quast
rule quast:
    input:
        "results/Genomics/1_Assembly/2_Assemblers/flye/{sample}/assembly.fasta"
    output:
        "results/Genomics/1_Assembly/3_Evaluation/quast/{sample}/report.html"
    conda:
        "envs/genomics.yaml"
    script:
        "scripts/Genomics/1_Assembly/3_Evaluation/QuastEvaluation.py"
