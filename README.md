# CRC-Shotgun-Metagenomics
# Shotgun Metagenomics Analysis of Gut Microbial Communities in Colorectal Cancer and Healthy Controls

## Project Overview

This undergraduate graduation project investigates gut microbial community composition in colorectal cancer (CRC) patients compared with healthy controls using publicly available paired-end shotgun metagenomic sequencing data.

The study analyzes six human fecal metagenomic samples from NCBI BioProject [PRJNA1138893](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA1138893), originating from He et al. (2025), comprising four CRC samples and two healthy controls.

**Graduation Project I (Semester 1 — Completed):**  
Established a documented, reproducible bioinformatics pipeline encompassing raw read retrieval, quality control, adapter and quality trimming, human host-DNA depletion, sequence deduplication, low-complexity sequence filtering, marker-based taxonomic profiling using **MetaPhlAn v4.2.2** (CHOCOPhlAn database), and exploratory phylum- and genus-level relative abundance analyses and visualizations in **R v4.5.2**.

**Graduation Project II (Semester 2 — Planned):**  
Will build upon the established taxonomic profiles to conduct formal ecological and statistical analyses, including within-sample alpha diversity, between-sample beta diversity ordination, statistical differential abundance testing, and exploratory functional metabolic pathway profiling using **HUMAnN 3**.

---


## Research Aim and Objectives

The primary aim of this project is to develop and document a reproducible shotgun metagenomics pipeline for characterizing gut microbial communities and exploring potential differences between colorectal cancer and healthy-control samples.

### Specific Objectives

1. Establish and document a reproducible computational environment for shotgun metagenomic analysis across macOS and Ubuntu (WSL).
2. Retrieve and preprocess publicly available shotgun metagenomic sequencing data from CRC and healthy-control samples.
3. Assess sequencing-read quality and remove adapter sequences, low-quality bases, duplicate reads, and low-complexity sequences.
4. Remove human host-derived sequences by alignment against the human reference genome (GRCh38).
5. Perform marker-based taxonomic profiling and estimate microbial relative abundances using MetaPhlAn v4.2.2 with the CHOCOPhlAn database.
6. Characterize and visualize microbial taxonomic composition at the phylum and genus levels in R.
7. Evaluate alpha and beta diversity to explore within-sample diversity and community structure variation between groups (Project II).
8. Identify differentially abundant taxa and, if computational resources allow, investigate microbial functional metabolic pathways (Project II).

---



## Dataset Description

The study utilizes whole-genome shotgun metagenomic sequencing data of human fecal samples retrieved from the NCBI Sequence Read Archive (SRA).

### Dataset Metadata

- **BioProject Accession:** [PRJNA1138893](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA1138893)
- **Source Study:** He et al., *Frontiers in Immunology*, 2025 (`doi:10.3389/fimmu.2025.1696701`)
- **Sample Type:** Human fecal (stool) samples
- **Sequencing Strategy:** Whole-Genome Shotgun (WGS) Metagenomics
- **Sequencing Platform:** Illumina NovaSeq 6000
- **Sequencing Layout:** Paired-end (2 × 150 bp)
- **Total Samples:** 6 (4 Colorectal Cancer, 2 Healthy Controls)


### Sample Information

| Group | Sample ID | SRA Run | BioSample |
|-------|-----------|---------|-----------|
| CRC | C4 | SRR29930208 | SAMN42746538 |
| CRC | C5 | SRR29930207 | SAMN42746539 |
| CRC | C7 | SRR29930206 | SAMN42746540 |
| CRC | C31 | SRR29930209 | SAMN42746537 |
| Healthy | H13 | SRR29930199 | SAMN42746546 |
| Healthy | H14 | SRR29930198 | SAMN42746547 |

---

## Software and Computational Environment

### Bioinformatics Software

| Tool | Version | Purpose | Citation / Source |
| :--- | :--- | :--- | :--- |
| **SRA Toolkit** | 3.4.1 | Data retrieval (`prefetch`, `fasterq-dump --split-files`) | NCBI |
| **FastQC** | 0.12.1 | Per-base sequence quality assessment | Babraham Bioinformatics |
| **MultiQC** | 1.35 | Consolidated quality control report aggregation | Ewels et al., 2016 |
| **fastp** | 1.3.7 | Adapter trimming and Q20 quality/length filtering | Chen et al., 2018 |
| **Bowtie2** | 2.5.5 | Alignment against human reference genome (GRCh38) | Langmead & Salzberg, 2012 |
| **SAMtools** | 1.24 | Alignment filtering (`view -b -f 12 -F 256`) and FASTQ extraction | Li et al., 2009 |
| **Clumpify (BBTools)** | 39.91 | Optical and PCR duplicate read removal (`dedupe=t`) | Bushnell (JGI) |
| **BBDuk (BBTools)** | 39.91 | Entropy-based low-complexity sequence filtering | Bushnell (JGI) |
| **MetaPhlAn** | 4.2.2 | Marker-gene taxonomic profiling (`mpa_vJan25_CHOCOPhlAnSGB_202503`) | Blanco-Míguez et al., 2023 |
| **R** | 4.5.2 | Taxonomic composition analysis, statistics, and visualization | R Core Team |
| **R Packages** | — | `ggplot2`, `dplyr`, `tidyr`, `stringr` (and `phyloseq` for Project II) | CRAN / Bioconductor |
| **HUMAnN** | 3.x | Functional profiling and metabolic pathway analysis (Project II) | Beghini et al., 2021 |

*Methodological Note on Taxonomic Profiler:*  
MetaPhlAn v4.2.2 with the CHOCOPhlAn marker database was selected over the initially considered Kraken2/Bracken k-mer workflow because MetaPhlAn's clade-specific marker-gene strategy provides accurate species-level resolution while operating efficiently within available memory (~8 GB RAM).

### Hardware & Operating Systems

- **macOS:** Environment managed using Conda (`meta_env`).
- **Ubuntu (WSL):** Executed through Windows Subsystem for Linux via MobaXterm with approximately 8 GB RAM.
- **Workflow Automation:** Modular Bash scripts configured with `set -euo pipefail` to ensure robust error handling and execution traceability.

---

## Bioinformatics Workflow

All data preprocessing stages and taxonomic profiling with MetaPhlAn v4.2.2 have been completed for this semester across all six samples. Downstream diversity, differential abundance, and functional analyses are scheduled for next semester.

## Bioinformatics Workflow

```text
NCBI SRA (PRJNA1138893)
   │
   ▼
01. Data Retrieval (SRA Toolkit v3.4.1: prefetch & fasterq-dump)
   │
   ▼
02. Initial Quality Control (FastQC v0.12.1 + MultiQC v1.35)
   │
   ▼
03. Read Preprocessing & Adapter Trimming (fastp v1.3.7: Q20, min 50 bp)
   │
   ▼
04. Post-Trimming Quality Assessment (FastQC + MultiQC)
   │
   ▼
05. Human Host-DNA Depletion (Bowtie2 v2.5.5 against GRCh38 + SAMtools v1.24)
   │
   ▼
06. Duplicate Read Removal (Clumpify - BBTools v39.91)
   │
   ▼
07. Low-Complexity Read Filtering (BBDuk - BBTools v39.91)
   │
   ▼
185,220,234 Clean Microbial Reads (92,610,117 Read Pairs)
   │
   ▼
08. Marker-Based Taxonomic Profiling (MetaPhlAn v4.2.2 + CHOCOPhlAn Database)
   │
   ▼
09. Taxonomic Composition Analysis & Visualization in R v4.5.2
   │   • Phylum-level stacked bar charts & heatmaps
   │   • Top-15 genus-level pie charts & group comparisons
   │
   ========================================================================
                 COMPLETED IN GRADUATION PROJECT I (SEM 1)
   ========================================================================
   │
   ▼
   ========================================================================
                  PLANNED FOR GRADUATION PROJECT II (SEM 2)
   ========================================================================
   │
   ▼
10. Microbial Diversity Analyses in R (Alpha & Beta Diversity)
   │
   ▼
11. Differential Abundance Testing (Enriched / Depleted Taxa in CRC)
   │
   ▼
12. Functional Metagenomic Profiling (Metabolic Pathways via HUMAnN 3)
```

```

## Preprocessing & Taxonomic Profiling Results Summary

### Quantitative Filtering Across Workflow Stages

| Stage | Tool | Input Count | Retained Count | Removed Count | % Retained | Key Metric / Outcome |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Data Retrieval** | SRA Toolkit | 6 SRA runs | 6 paired-end FASTQ | — | 100% | 15.8M–21.4M read pairs per sample |
| **Adapter & QC Trimming** | fastp | 113,446,478 pairs | 112,919,873 pairs | 526,605 pairs | 98.82%–99.40% | Base quality improved; Q30 increased to >93% |
| **Human Host Removal** | Bowtie2 + SAMtools | 112,919,873 pairs | 112,603,986 pairs | 315,887 pairs | 99.72% | Minimal host contamination (0.10%–0.64% removed) |
| **Deduplication** | Clumpify | 112,603,986 pairs | 92,679,746 pairs | 19,924,240 pairs | 82.31% | Technical redundancy reduced (17.05%–18.56% removed) |
| **Low-Complexity Filtering** | BBDuk | 185,359,492 reads | 185,220,234 reads | 139,258 reads | 99.92% | Low-entropy reads discarded (0.063%–0.087% removed) |
| **Taxonomic Profiling** | MetaPhlAn v4.2.2 | 185,220,234 reads | 1,189 taxonomic clades | — | — | Merged abundance table across all 6 samples |

### Key Taxonomic Findings (Graduation Project I)

- **Phylum Level:**
  - *Bacteroidota* predominated across healthy controls (mean 57.11%) and three CRC samples, while *Firmicutes* was the second most abundant (healthy mean 31.24%, CRC mean 22.35%).
  - CRC sample C7 (SRR29930206) showed a pronounced shift toward *Pseudomonadota* (53.74%), accompanied by the highest unclassified proportion (34.21%).
- **Genus Level:**
  - *Phocaeicola* was dominant in healthy controls (mean 31.63% vs. 17.17% in CRC).
  - *Bacteroides* was more abundant in CRC samples on average (20.48% vs. 12.40% in healthy controls).
  - CRC sample C7 exhibited an elevated abundance of *Escherichia* (41.27%), a genus containing strains carrying the *pks* island associated with colibactin genotoxicity.
  - CRC sample C4 exhibited high *Faecalibacterium* abundance (27.81%), demonstrating individual-level heterogeneity.

---

## Project Status

### Completed (Graduation Project I)

- [x] Retrieve raw paired-end shotgun metagenomic sequencing data for all six samples.
- [x] Evaluate initial sequencing quality using FastQC and MultiQC.
- [x] Perform adapter trimming and Q20 quality filtering using fastp.
- [x] Perform post-trimming quality reassessment.
- [x] Deplete human host reads via Bowtie2 alignment against the GRCh38 human reference genome.
- [x] Remove duplicate sequencing reads using Clumpify.
- [x] Filter low-entropy low-complexity sequences using BBDuk.
- [x] Conduct final quality assessment of the 185,220,234 retained analysis-ready reads.
- [x] Execute marker-based taxonomic profiling using MetaPhlAn v4.2.2 and the CHOCOPhlAn database.
- [x] Merge individual sample profiles into a unified relative abundance matrix (1,189 taxonomic records).
- [x] Perform descriptive phylum- and genus-level relative abundance analyses and visualizations in R v4.5.2 (stacked bar plots, pie charts, heatmaps, and bubble plots).
- [x] Author and submit the Graduation Project I Research Report and Presentation.

### Next Steps (Graduation Project II — Next Semester)

- [ ] **Alpha Diversity Analysis:** Calculate within-sample richness and evenness indices (Observed species, Shannon index, Simpson index) in R using `phyloseq`.
- [ ] **Beta Diversity Analysis:** Compute between-sample dissimilarity matrices (Bray-Curtis, Jaccard) and visualize community separation via PCoA and NMDS ordination.
- [ ] **Differential Abundance Testing:** Identify statistically enriched or depleted microbial taxa in CRC patients versus healthy controls.
- [ ] **Functional Metagenomic Profiling:** Characterize microbial metabolic pathways and functional gene potential using HUMAnN 3 if computational resources permit.
- [ ] **Cohort Expansion (Optional):** Evaluate expanding the dataset to additional samples from BioProject PRJNA1138893 to enhance statistical power.

---

## Scope and Limitations

1. **Exploratory Sample Size:** This study analyzes a small subset of six samples (4 CRC and 2 healthy controls); observed differences represent preliminary descriptive patterns rather than validated clinical biomarkers.
2. **Computational Constraints:** Metagenomic analyses were optimized to operate within an 8 GB RAM computing environment, which determined the selection of marker-based MetaPhlAn over memory-intensive k-mer profilers.
3. **Clinical Metadata:** Individual participant clinical variables (e.g., patient age, sex, BMI, diet, medication history, and tumor stage) were unavailable in public records, precluding adjustment for confounding factors.
4. **Compositional Data:** Metagenomic relative abundances are compositional; shifts in the proportion of one taxon reflect relative community distributions rather than absolute microbial cell counts.


---

## References

1. World Health Organization. Colorectal cancer. Geneva: WHO; 2024. Available from: [https://www.who.int/news-room/fact-sheets/detail/colorectal-cancer](https://www.who.int/news-room/fact-sheets/detail/colorectal-cancer)
2. White MT, Sears CL. The microbial landscape of colorectal cancer. *Nat Rev Microbiol*. 2024;22:240–254. [doi:10.1038/s41579-023-00973-4](https://doi.org/10.1038/s41579-023-00973-4)
3. He J, Jia J, Qu W, Zhang S, Fan K, Lin R, et al. *Bacteroides ovatus*-derived N-methylserotonin inhibit colorectal cancer via the HTR1D-mediated cAMP-PKA-NF-κB signaling axis. *Front Immunol*. 2025;16:1696701. [doi:10.3389/fimmu.2025.1696701](https://www.google.com/search?q=https://doi.org/10.3389/fimmu.2025.1696701)
4. Jovel J, Patterson J, Wang W, Hotte N, O'Keefe S, Mitchel T, et al. Characterization of the gut microbiome using 16S or shotgun metagenomics. *Front Microbiol*. 2016;7:459. [doi:10.3389/fmicb.2016.00459](https://www.google.com/search?q=https://doi.org/10.3389/fmicb.2016.00459)
5. Quince C, Walker AW, Simpson JT, Loman NJ, Segata N. Shotgun metagenomics, from sampling to analysis. *Nat Biotechnol*. 2017;35(9):833–844. [doi:10.1038/nbt.3935](https://doi.org/10.1038/nbt.3935)
6. National Center for Biotechnology Information. BioProject PRJNA1138893. Bethesda (MD): National Library of Medicine; 2024. Available from: [https://www.ncbi.nlm.nih.gov/bioproject/PRJNA1138893](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA1138893)
7. Andrews S. FastQC: A Quality Control Tool for High Throughput Sequence Data. Babraham Bioinformatics; 2010. Available from: [https://www.bioinformatics.babraham.ac.uk/projects/fastqc/](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
8. Ewels P, Magnusson M, Lundin S, Käller M. MultiQC: summarize analysis results for multiple tools and samples in a single report. *Bioinformatics*. 2016;32(19):3047–3048. [doi:10.1093/bioinformatics/btw354](https://www.google.com/search?q=https://doi.org/10.1093/bioinformatics/btw354)
9. Chen S, Zhou Y, Chen Y, Gu J. fastp: an ultra-fast all-in-one FASTQ preprocessor. *Bioinformatics*. 2018;34(17):i884–i890. [doi:10.1093/bioinformatics/bty560](https://www.google.com/search?q=https://doi.org/10.1093/bioinformatics/bty560)
10. Langmead B, Salzberg SL. Fast gapped-read alignment with Bowtie 2. *Nat Methods*. 2012;9(4):357–359. [doi:10.1038/nmeth.1923](https://doi.org/10.1038/nmeth.1923)
11. Li H, Handsaker B, Wysoker A, et al. The Sequence Alignment/Map format and SAMtools. *Bioinformatics*. 2009;25(16):2078–2079. [doi:10.1093/bioinformatics/btp352](https://www.google.com/search?q=https://doi.org/10.1093/bioinformatics/btp352)
12. Bushnell B. BBTools: a suite of fast, multithreaded bioinformatics tools. Joint Genome Institute; 2024. Available from: [https://jgi.doe.gov/data-and-tools/software-tools/bbtools/](https://jgi.doe.gov/data-and-tools/software-tools/bbtools/)
13. Blanco-Míguez A, Beghini F, Cumbo F, McIver LJ, Thompson KN, Zolfo M, et al. Extending and improving metagenomic taxonomic profiling with uncharacterized species using MetaPhlAn 4. *Nat Biotechnol*. 2023;41:1633–1644. [doi:10.1038/s41587-023-01688-w](https://doi.org/10.1038/s41587-023-01688-w)
14. Thomas AM, Manghi P, Asnicar F, et al. Metagenomic analysis of colorectal cancer datasets identifies cross-cohort microbial diagnostic signatures and a link with choline degradation. *Nat Med*. 2019;25(4):667–678. [doi:10.1038/s41591-019-0405-7](https://www.google.com/search?q=https://doi.org/10.1038/s41591-019-0405-7)
15. Pleguezuelos-Manzano C, Puschhof J, Rosendahl Huber A, et al. Mutational signature in colorectal cancer caused by genotoxic pks+ *E. coli*. *Nature*. 2020;580:269–273. [doi:10.1038/s41586-020-2080-8](https://www.google.com/search?q=https://doi.org/10.1038/s41586-020-2080-8)
16. Sokol H, Pigneur B, Watterlot L, et al. *Faecalibacterium prausnitzii* is an anti-inflammatory commensal bacterium identified by gut microbiota analysis of Crohn disease patients. *Proc Natl Acad Sci USA*. 2008;105(43):16731–16736. [doi:10.1073/pnas.0804812105](https://www.google.com/search?q=https://doi.org/10.1073/pnas.0804812105)
17. Gloor GB, Macklaim JM, Pawlowsky-Glahn V, Egozcue JJ. Microbiome datasets are compositional: and this is not optional. *Front Microbiol*. 2017;8:2224. [doi:10.3389/fmicb.2017.02224](https://www.google.com/search?q=https://doi.org/10.3389/fmicb.2017.02224)
