#!/usr/bin/env bash

# Run FastQC again after cleaning
# Combine the FastQC and fastp reports with MultiQC

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

CLEAN_DIR="${PROJECT_DIR}/trimmed_data"
QC_DIR="${PROJECT_DIR}/qc_reports/clean"

mkdir -p "$QC_DIR"

# Check that FastQC and MultiQC are available
for cmd in fastqc multiqc; do
    command -v "$cmd" >/dev/null 2>&1 || {
        echo "ERROR: $cmd is not installed."
        exit 1
    }
done

# Get all clean FASTQ files
shopt -s nullglob
FILES=("$CLEAN_DIR"/*.clean.fastq.gz)

if (( ${#FILES[@]} == 0 )); then
    echo "ERROR: No clean FASTQ files were found."
    exit 1
fi

echo "Found ${#FILES[@]} clean FASTQ files."

# Run FastQC on the clean files
fastqc "${FILES[@]}" -o "$QC_DIR"

# Make one MultiQC report
multiqc "$QC_DIR" \
    -o "$QC_DIR" \
    --force

echo "Post-clean QC finished."
