# MAKE YOUR OWN GENOME PROJECT

## 1. Abstract & Aim Of Project
Within the scope of the ‘Build Your Own Genome’ competition, Mediterraneibacter gnavus, a species of relevance to the gut microbiota, was selected. This selection was motivated by evidence indicating that its mucin-degrading activity contributes to dysbiosis, particularly in autoimmune conditions, and is also associated with the induction of various inflammatory processes. The aim of this study is to reconstruct the genomic architecture of this pathobiont in silico through bioinformatics analyses and computational approaches.

## 2. NCBI Data & Data Source
* **Source:** NCBI Sequence Read Archive
* **Sequence Platform:** Oxford Nanopore
* **NCBI Number:** SRR24651220


## 3. config.yaml and Pipeline Configuration

```text
data_dir: "data/raw"
results_dir: "results/Genome"

samples:
  - SRR24651203
  - SRR24651220_1

threads:
  high: 8
  medium: 4
  low: 2

params:
  genome_size: "3.8m"
  min_read_length: 1000

rule fastqc_before_trimming:
    input: "data/raw/{sample}.fastq"
    output: "results/Genomics/1_Assembly/1_Preprocessing/fastqc_before_trimming/{sample}_fastqc.html"
    conda: "envs/genomics.yaml"
    script: "scripts/Genomics/1_Assembly/1_Preprocessing/ReadQualityCheck.py"

rule flye:
    input: reads = lambda wildcards: "data/raw/{}.fastq".format(wildcards.sample.strip().replace("/", ""))
    params: genome_size=config["params"]["genome_size"], threads=config["threads"]["high"]
    output: 
        out_dir = "results/Genomics/1_Assembly/2_Assemblers/flye/{sample}",
        assembly = "results/Genomics/1_Assembly/2_Assemblers/flye/{sample}/assembly.fasta"
    shell: "flye --nano-raw {input.reads} --genome-size {params.genome_size} --threads {params.threads} --out-dir {output.out_dir}"

rule quast:
    input: "results/Genomics/1_Assembly/2_Assemblers/flye/{sample}/assembly.fasta"
    output: "results/Genomics/1_Assembly/3_Evaluation/quast/{sample}/report.html"
    conda: "envs/genomics.yaml"
    script: "scripts/Genomics/1_Assembly/3_Evaluation/QuastEvaluation.py"

## 4. Troubleshooting Report
- The Snakemake & Core Management: Fixed DirectoryNotEmpty and MissingOutputException by implementing explicit directory() flags.
- Overload & Memory Management: Optimized config.yaml to prevent heap memory overflow in Flye overlap phase.
- Github Repository Bloat: Purged .snakemake cache and updated .gitignore to stay under quota.

## 5. QUAST Comparison Results
| Metric | Final Value | Biological Interpretation |
| :--- | :--- | :--- |
| Total Length | 3,191,442 bp | Full genome representative of M. gnavus. |
| Number of Contigs | 1 | Complete & Circularized genome achieved. |
| N50 | 3,191,442 bp | Maximum possible contiguity for this isolate. |
| GC Content | 44.22% | Consistent with M. gnavus standards. |


## 6. Future Perspective
Leveraging the high-contiguity genomic blueprint generated in this study, the next investigative phase aims to elucidate the ecological determinants of intestinal homeostasis by exploring the competitive landscape between the pathobiont *Mediterraneibacter gnavus* and the beneficial commensal *Akkermansia muciniphila* within the mucin-utilization niche. 

Proceeding from the hypothesis of competitive exclusion, subsequent research will utilize **in silico genome-scale metabolic modeling (GEMs)** derived from this assembly to simulate multi-species interactions under varied nutrient constraints. The objective is to determine if directed symbiotic expansion of *A. muciniphila* can effectively sequester limiting mucin substrates, thereby robustly suppressing *M. gnavus* population density and offering a novel, non-antibiotic therapeutic strategy to ameliorate inflammation by restoring microbial equilibrium in dysbiotic gut environments.
