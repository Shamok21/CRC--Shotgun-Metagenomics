# Host Removal, Deduplication and Low-Complexity Filtering

## Overview

This README documents seven Bash scripts used in the
colorectal cancer shotgun metagenomics project.

The scripts cover human host-read removal, duplicate-read
filtering, validation, quality control, and low-complexity
sequence filtering.

## My scripts

05_build_host_index.sh
Builds the Bowtie2 index for the GRCh38 human reference genome.

06_host_removal.sh
Aligns cleaned paired-end reads to GRCh38 using Bowtie2
and extracts non-host paired reads using Samtools.

07_host_removel_versions.sh
Reports the Bowtie2 and Samtools versions.

08_deduplication.sh
Processes non-host paired reads using Clumpify.

09_dedup_validation.sh
Checks deduplicated FASTQ files, read counts, and paired-read IDs.

10_before_after_dedup.sh
Runs FastQC and MultiQC to compare reads before and after
deduplication.

11_lowcomplex_filtering.sh
Uses BBTools to filter low-complexity reads and produces
quality-control reports and summary results.

## Sample configuration

Sample accessions are read from:

10_Scripts/config/samples.txt

The sample list can be updated for another dataset.

## Paths and outputs

The scripts are located directly inside HANDOVER/10_Scripts
and derive the HANDOVER directory from their own location.

They use the existing project directories:

04_Bowtie2/
05_Clumpify/
06_LowComplexity/

## Reproducibility

The original analytical commands and parameters were retained.
Only project paths and sample-list handling were adapted.

All seven scripts passed Bash syntax checking.
Full execution and output reproducibility have not been tested.

The appropriate software environment and tool versions are
required to reproduce the analysis.

## Important warning

Do not rerun processing scripts over completed results without
checking their output paths.

The original Clumpify command retains overwrite=t.
The reference download/build script and other processing scripts
may replace existing files.

## Software Versions

Conda environment: `meta_env`

| Pipeline Step | Software | Version |
|---|---|---|
| Host Removal | Bowtie2 | 2.5.5 |
| Host Removal | Samtools | 1.24 |
| Deduplication | Clumpify (BBTools) | 39.91 |
| Low-Complexity Filtering | BBDuk (BBTools) | 39.91 |
