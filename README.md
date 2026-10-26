# CRC-Shotgun-Metagenomics
# Shotgun Metagenomics Analysis of Gut Microbial Communities in Colorectal Cancer and Healthy Controls

## Project Overview

This project aims to characterize gut microbial communities using publicly available paired-end shotgun metagenomic sequencing data from colorectal cancer (CRC) patients and healthy controls.

The study uses six samples from NCBI BioProject PRJNA1138893, including four CRC samples and two healthy controls.

The analysis focuses on microbial taxonomic composition, relative abundance, and alpha and beta diversity. Due to the limited sample size, comparisons will be exploratory.

In the first phase of the project (Semester 1), the workflow completed raw read quality assessment, adapter trimming, human host-DNA removal, sequence deduplication, low-complexity read filtering, and marker-based taxonomic profiling using MetaPhlAn v4.2.2. In the continuation phase (Semester 2), the project will focus on downstream statistical and biological analyses in R—specifically alpha and beta microbial diversity, differential abundance testing between CRC and healthy controls, and functional pathway profiling. Due to the limited sample size, biological comparisons are interpreted as exploratory patterns while establishing an end-to-end, reproducible shotgun metagenomics workflow.

## Research Objectives

The main objectives of this project are to:

1. Retrieve and preprocess publicly available shotgun metagenomic sequencing data from CRC patients and healthy controls.
2. Assess sequencing quality and remove adapters, low-quality reads, host-derived DNA, duplicate reads, and low-complexity sequences.
3. Perform marker based taxonomic profiling and estimate microbial relative abundances using MetaPhlAn v4.2.2..
4. Characterize and compare relative taxonomic composition between CRC and healthy-control samples.
5. Evaluate alpha diversity within individual samples.
6. Evaluate beta diversity to explore differences in microbial community structure.
7. Identify differentially abundant bacterial taxa (enriched or depleted) in CRC patients compared to healthy controls..
8. Explore microbial functional potential and metabolic pathways using HUMAnN if computational resources allow.


## Dataset Description

This study uses publicly available human gut shotgun metagenomic sequencing data obtained from the NCBI Sequence Read Archive (SRA).

### Dataset Information

- **BioProject ID:** [PRJNA1138893](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA1138893)
- **Sample Type:** Fecal (stool) samples
- **Sequencing Strategy:** Whole-genome shotgun metagenomics
- **Sequencing Layout:** Paired-end
- **Sequencing Platform:** Illumina NovaSeq 6000
- **Total Samples:** 6
- **CRC Samples:** 4
- **Healthy Controls:** 2

### Sample Information

| Group | Sample ID | SRA Run | BioSample |
|-------|-----------|---------|-----------|
| CRC | C4 | SRR29930208 | SAMN42746538 |
| CRC | C5 | SRR29930207 | SAMN42746539 |
| CRC | C7 | SRR29930206 | SAMN42746540 |
| CRC | C31 | SRR29930209 | SAMN42746537 |
| Healthy | H13 | SRR29930199 | SAMN42746546 |
| Healthy | H14 | SRR29930198 | SAMN42746547 |

### Dataset Selection

The selected subset consists of four colorectal cancer (CRC) samples and two healthy controls.

This subset was selected to provide a computationally manageable dataset for developing the shotgun metagenomics analysis workflow and exploring microbial differences between CRC patients and healthy controls.

Due to the limited sample size, the biological comparisons will be exploratory.


## Software and Computational Environment

### Bioinformatics Software

The following software versions were recorded across the project's computational environments.

| Software | Version | Purpose |
|---|---|---|
| SRA Toolkit | 3.4.1 | Sequencing data retrieval |
| FastQC | 0.13.0 | Sequencing quality assessment |
| MultiQC | 1.35 | Quality control report aggregation |
| fastp | 1.3.7 | Adapter trimming and quality filtering |
| Bowtie2 | 2.5.5 | Human host read identification |
| Samtools | 1.24 | Alignment file processing |
| Clumpify (BBTools) | 39.91 | Duplicate read removal |
| BBDuk (BBTools) | 39.91 | Low-complexity sequence filtering |
| MetaPhlAn | 4.2.2 | Marker gene Taxonomic profiling |
| R (phyloseq,ggplot)| 4.x | Downstream microbial composition, diversity analysis, and visualization |
| HUMAan | 3.x | Functional potential and metabolic pathway profiling (optional)

### Computational Environments

**macOS**
- Operating System: macOS
- Environment Manager: Conda
- Conda Environment: `meta_env`

**Ubuntu**
- Operating System: Ubuntu through Windows Subsystem for Linux (WSL)
- Access Interface: MobaXterm
- Available RAM: Approximately 8 GB

Software versions may differ between environments.

## Bioinformatics Workflow

All data preprocessing stages and taxonomic profiling with MetaPhlAn v4.2.2 have been completed for this semester across all six samples. Downstream diversity, differential abundance, and functional analyses are scheduled for next semester.

### Workflow Overview

```text
NCBI SRA
   |
   v
Data Retrieval (SRA Toolkit)
   |
   v
Raw Read Quality Control (FastQC / MultiQC)
   |
   v
Adapter Trimming and Quality Filtering (fastp)
   |
   v
Post-Trimming Quality Control (FastQC)
   |
   v
Human Host Read Removal (Bowtie2 / Samtools)
   |
   v
Duplicate Read Removal (Clumpify)
   |
   v
Low-Complexity Filtering (BBDuk)
   |
   v
Filtered Paired-End FASTQ Files
   |
   v
Taxonomic Profiling (MetaPhlan v4.2.2 + CHOCOPhlAn Database) 
   |
   v
==========================================================================
               NEXT SEMESTER (PLANNED DOWNSTREAM ANALYSES)
==========================================================================
   |
   v
Microbial Composition, Alpha & Beta Diversity Analysis in R [NEXT SEMESTER]
   |
   v
 Differential Abundance (Enriched/Depleted Taxa in CRC) [NEXT SEMESTER]
   |
   v
 Functional Profiling (Metabolic Pathways via HUMAnN) [NEXT SEMESTER]
   |
   v
```

### Completed Preprocessing Stages

| Stage | Tool | Status | Available Outputs |
|---|---|---|---|
| Data retrieval | SRA Toolkit | Completed | Paired-end sequencing reads |
| Initial quality assessment | FastQC | Completed | 12 raw FastQC HTML reports |
| Quality report aggregation | MultiQC | Completed | `multiqc_report.html` |
| Adapter trimming and quality filtering | fastp | Completed | 6 sample HTML reports and a combined report index |
| Post-trimming quality assessment | FastQC | Completed | 12 clean FastQC HTML reports |
| Human host read removal | Bowtie2 / Samtools | Completed | 12 non-host FASTQ.gz files, `host_removal_summary.csv`, and `bowtie2_all_samples.log` |
| Duplicate read removal | Clumpify | Completed | 12 deduplicated FASTQ.gz files, `clumpify_deduplication_summary.csv`, `multiqc_dedup_report.html`, `multiqc_before_after_dedup.html`, and `dedup_fastq_all_samples.tar` |
| Low-complexity filtering | BBDuk | Completed | 12 filtered FASTQ.gz files, `lowcomplex_summary.csv`, `lowcomplex_all_samples.log`, FastQC and MultiQC report folders |
|Taxonomic profiling | MetaPhlAn v4.2.2 | Completed | Marker-gene species profiling | Per-sample taxonomic profiles and merged relative abundance tables |

### Output File Documentation

The available outputs correspond to the six selected sequencing runs:

- `SRR29930198`
- `SRR29930199`
- `SRR29930206`
- `SRR29930207`
- `SRR29930208`
- `SRR29930209`

**Quality Control**

Initial and post-trimming FastQC assessments produced HTML reports for both paired-end reads of each sample.

fastp generated six sample-specific HTML reports. A combined HTML index, `fastp_all_samples.html`, is also available.

**Human Host Removal**

The host removal stage generated paired non-host FASTQ files for all six samples.

Additional documentation includes:

- `host_removal_summary.csv`
- `bowtie2_all_samples.log`

**Duplicate Removal**

Clumpify generated paired-end deduplicated FASTQ output files for all six samples.

**Low-Complexity Filtering**

BBDuk generated 12 compressed paired-end FASTQ files, representing two output files per sample.

The output naming convention is:

- `SRR_ACCESSION_lowcomplex_1.fastq.gz`
- `SRR_ACCESSION_lowcomplex_2.fastq.gz`

These files are the latest available preprocessing outputs and are intended for taxonomic classification using Kraken2.

The presence of output files has been documented; file integrity and detailed quality metrics have not yet been independently verified.

## Current Project Status

### Completed

- [x] Retrieve sequencing data for six samples.
- [x] Perform initial sequencing quality assessment.
- [x] Perform adapter trimming and quality filtering.
- [x] Perform post-trimming quality assessment.
- [x] Remove human host-associated reads.
- [x] Remove duplicate sequencing reads.
- [x] Filter low-complexity sequences.
- [x] Generate paired-end preprocessing output files for all six samples.
- [x] Complete marker-based taxonomic profiling and relative abundance estimation using MetaPhlAn v4.2.2 
### In Progress

### Next Steps

- [ ] Calculate microbial relative abundance.
- [ ] Perform alpha diversity analysis in R.
- [ ] Perform beta diversity analysis in R.
- [ ] Generate visualizations and interpret microbial patterns.
- [ ] Explore functional profiling if feasible.

## Analysis Limitations

Sample Size: This study examines an exploratory subset of six samples (4 CRC and 2 healthy controls); observed differences represent preliminary microbial patterns rather than validated clinical biomarkers.

Computational Resources: Available memory (~8 GB RAM) restricts large k-mer reference databases, motivating the adoption of marker-gene profiling via MetaPhlAn v4.2.2.

Clinical Metadata: Limited individual patient metadata (e.g., diet, BMI, medication history, comorbidities) restricts adjustment for potential confounding variables.

The workflow documentation and analysis results will be updated as the project progresses.
