#!/usr/bin/env bash

# Clean the paired FASTQ files with fastp
# Detect adapters automatically
# Use Q20 as the quality cutoff
# Keep reads that are at least 50 bp long

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

SAMPLE_FILE="${PROJECT_DIR}/config/samples.txt"
RAW_DIR="${PROJECT_DIR}/raw_data"
CLEAN_DIR="${PROJECT_DIR}/trimmed_data"
REPORT_DIR="${PROJECT_DIR}/qc_reports/clean"

mkdir -p "$CLEAN_DIR" "$REPORT_DIR"

# Check that fastp is available
command -v fastp >/dev/null 2>&1 || {
    echo "ERROR: fastp is not installed."
    exit 1
}

while read -r SAMPLE; do

    [[ -z "$SAMPLE" ]] && continue

    R1="${RAW_DIR}/${SAMPLE}_1.fastq.gz"
    R2="${RAW_DIR}/${SAMPLE}_2.fastq.gz"

    OUT1="${CLEAN_DIR}/${SAMPLE}_1.clean.fastq.gz"
    OUT2="${CLEAN_DIR}/${SAMPLE}_2.clean.fastq.gz"

    # Check that both R1 and R2 exist
    if [[ ! -s "$R1" || ! -s "$R2" ]]; then
        echo "ERROR: Missing R1 or R2 for $SAMPLE."
        exit 1
    fi

    echo "Cleaning $SAMPLE"

    fastp \
        -i "$R1" \
        -I "$R2" \
        -o "$OUT1" \
        -O "$OUT2" \
        --detect_adapter_for_pe \
        --qualified_quality_phred 20 \
        --length_required 50 \
        --thread 4 \
        --html "${REPORT_DIR}/${SAMPLE}_fastp.html" \
        --json "${REPORT_DIR}/${SAMPLE}_fastp.json"

    # Check that both clean files were created
    if [[ ! -s "$OUT1" || ! -s "$OUT2" ]]; then
        echo "ERROR: fastp output is missing for $SAMPLE."
        exit 1
    fi

    echo "$SAMPLE finished."

done < "$SAMPLE_FILE"
