#!/usr/bin/env bash

# Run FastQC on the raw FASTQ files
# Combine all the FastQC reports with MultiQC

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

RAW_DIR="${PROJECT_DIR}/raw_data"
QC_DIR="${PROJECT_DIR}/qc_reports/raw"

mkdir -p "$QC_DIR"

# Check that FastQC and MultiQC are available
for cmd in fastqc multiqc; do
    command -v "$cmd" >/dev/null 2>&1 || {
        echo "ERROR: $cmd is not installed."
        exit 1
    }
done

# Get all raw FASTQ files
shopt -s nullglob
FILES=("$RAW_DIR"/*.fastq.gz)

if (( ${#FILES[@]} == 0 )); then
    echo "ERROR: No raw FASTQ files were found."
    exit 1
fi

echo "Found ${#FILES[@]} FASTQ files."

# Run FastQC
fastqc "${FILES[@]}" -o "$QC_DIR"

# Make one MultiQC report
multiqc "$QC_DIR" \
    -o "$QC_DIR" \
    --force

echo "Raw QC finished."
