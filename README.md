# MAKE YOUR OWN GENOME PROJECT

## 1. Abstract & Aim Of Project
Within the scope of the ‘Build Your Own Genome’ competition, Mediterraneibacter gnavus, a species of relevance to the gut microbiota, was selected. This selection was motivated by evidence indicating that its mucin-degrading activity contributes to dysbiosis, particularly in autoimmune conditions, and is also associated with the induction of various inflammatory processes. The aim of this study is to reconstruct the genomic architecture of this pathobiont in silico through bioinformatics analyses and computational approaches.

## 2. NCBI Data & Data Source
* **Source:** NCBI Sequence Read Archive
* **Sequence Platform:** Oxford Nanopore
* **NCBI Number:** SRR24651220

## 3. config.yaml and Pipeline Configurations

### YAML
```yaml
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
    input:
        "data/raw/{sample}.fastq"
    output:
        "results/Genomics/1_Assembly/1_Preprocessing/fastqc_before_trimming/{sample}_fastqc.html"
    conda:
        "envs/genomics.yaml"
    script:
        "scripts/Genomics/1_Assembly/1_Preprocessing/ReadQualityCheck.py"
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
    shell:
        "flye --nano-raw {input.reads} --genome-size {params.genome_size} --threads {params.threads} --out-dir {output.out_dir}"
rule quast:
    input:
        "results/Genomics/1_Assembly/2_Assemblers/flye/{sample}/assembly.fasta"
    output:
        "results/Genomics/1_Assembly/3_Evaluation/quast/{sample}/report.html"
    conda:
        "envs/genomics.yaml"
    script:
        "scripts/Genomics/1_Assembly/3_Evaluation/QuastEvaluation.py"

## 4. Troubleshooting Report

### The Snakemake & Core Management
* **Technical Problem:** Running the pipeline with `--cores 4` caused simultaneous read/write operations on the same directories; leading to `DirectoryNotEmpty` and `MissingOutputException`.
* **Solution:** By implementing explicit `directory()` flags and ensuring unique output paths for each sample, I stabilized the parallel processing.

### Overload & Memory Management
* **Technical Problem:** The Flye overlap phase triggered a heap memory overflow freezing the Ubuntu environment.
* **Solution:** Optimization of the `config.yaml` to enforce a hard memory limit and prioritizing disk-swapping for temporary intermediate files.

### Github Repository Bloat
* **Technical Problem:** Repository bloat caused by `.snakemake` cache resulted in GitHub push rejection.
* **Solution:** Executed a hard-purge of the Git index and established a granular `.gitignore` to sync only the 8.65 MiB of analytical core data.

## 5. QUAST Comparison Results
The following metrics represent the final assembly quality of *Mediterraneibacter gnavus* (Sample: SRR24651220). Achieving a single-contig assembly confirms the success of the heuristic filtering and resource-aware pipeline configuration.

| Metric | Final Value | Biological Interpretation |
| :--- | :--- | :--- |
| **Total Length** | 3,191,442 bp | Full genome representative of *M. gnavus*. |
| **Number of Contigs** | 1 | Complete & Circularized genome achieved. |
| **N50** | 3,191,442 bp | Maximum possible contiguity for this isolate. |
| **L50** | 1 | Single sequence representing the chromosome. |
| **GC Content** | 44.22% | Consistent with *M. gnavus* phylogenetic standards. |

> **Note:** The assembly was validated using QUAST v5.2.0. The high N50 value indicates that the Oxford Nanopore long-reads were successfully resolved into a high-fidelity reference-grade genome.

## 6. Future Perspective
Leveraging the high-contiguity genomic blueprint generated in this study, the next investigative phase aims to elucidate the ecological determinants of intestinal homeostasis by exploring the competitive landscape between the pathobiont *Mediterraneibacter gnavus* and the beneficial commensal *Akkermansia muciniphila* within the mucin-utilization niche. 

Proceeding from the hypothesis of competitive exclusion, subsequent research will utilize **in silico genome-scale metabolic modeling (GEMs)** derived from this assembly to simulate multi-species interactions under varied nutrient constraints. The objective is to determine if directed symbiotic expansion of *A. muciniphila* can effectively sequester limiting mucin substrates, thereby robustly suppressing *M. gnavus* population density and offering a novel, non-antibiotic therapeutic strategy to ameliorate inflammation by restoring microbial equilibrium in dysbiotic gut environments.
