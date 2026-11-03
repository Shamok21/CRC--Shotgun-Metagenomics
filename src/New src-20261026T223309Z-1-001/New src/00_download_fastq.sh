#!/usr/bin/env bash

# Download the samples from SRA
# Convert them to paired FASTQ files
# Compress the FASTQ files after conversion

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

SAMPLE_FILE="${PROJECT_DIR}/config/samples.txt"
RAW_DIR="${PROJECT_DIR}/raw_data"
TMP_DIR="${PROJECT_DIR}/tmp/fasterq"

mkdir -p "$RAW_DIR" "$TMP_DIR"

# Check that the needed tools are available
for cmd in prefetch fasterq-dump gzip; do
    command -v "$cmd" >/dev/null 2>&1 || {
        echo "ERROR: $cmd is not installed or not in PATH."
        exit 1
    }
done

# Check that the sample list exists
if [[ ! -f "$SAMPLE_FILE" ]]; then
    echo "ERROR: samples.txt was not found."
    exit 1
fi

cd "$RAW_DIR"

while read -r SAMPLE; do

    [[ -z "$SAMPLE" ]] && continue

    echo "Processing $SAMPLE"

    # Skip the sample if the FASTQ files are already there
    if [[ -s "${SAMPLE}_1.fastq.gz" && -s "${SAMPLE}_2.fastq.gz" ]]; then
        echo "$SAMPLE already exists. Skipping."
        continue
    fi

    # Download the SRA run
    prefetch "$SAMPLE"

    SRA_FILE="${SAMPLE}/${SAMPLE}.sra"

    if [[ ! -s "$SRA_FILE" ]]; then
        echo "ERROR: SRA file was not found for $SAMPLE."
        exit 1
    fi

    # Convert the SRA file to paired FASTQ
    fasterq-dump "$SRA_FILE" \
        --split-files \
        --threads 2 \
        --temp "$TMP_DIR"

    # Make sure both FASTQ files were created
    if [[ ! -s "${SAMPLE}_1.fastq" || ! -s "${SAMPLE}_2.fastq" ]]; then
        echo "ERROR: FASTQ conversion failed for $SAMPLE."
        exit 1
    fi

    # Compress the FASTQ files
    gzip "${SAMPLE}_1.fastq" "${SAMPLE}_2.fastq"

    echo "$SAMPLE finished."

done < "$SAMPLE_FILE"
