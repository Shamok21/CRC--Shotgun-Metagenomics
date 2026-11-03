#!/usr/bin/env bash

# Save the versions of the tools used in the preprocessing steps

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

LOG_DIR="${PROJECT_DIR}/logs"
OUTPUT="${LOG_DIR}/software_versions.txt"

mkdir -p "$LOG_DIR"

{
    echo "Software versions"
    echo "================="
    echo

    echo "SRA Toolkit:"
    if command -v prefetch >/dev/null 2>&1; then
        prefetch --version
    else
        echo "prefetch not found"
    fi

    echo
    echo "fasterq-dump:"
    if command -v fasterq-dump >/dev/null 2>&1; then
        fasterq-dump --version
    else
        echo "fasterq-dump not found"
    fi

    echo
    echo "FastQC:"
    if command -v fastqc >/dev/null 2>&1; then
        fastqc --version
    else
        echo "FastQC not found"
    fi

    echo
    echo "MultiQC:"
    if command -v multiqc >/dev/null 2>&1; then
        multiqc --version
    else
        echo "MultiQC not found"
    fi

    echo
    echo "fastp:"
    if command -v fastp >/dev/null 2>&1; then
        fastp --version
    else
        echo "fastp not found"
    fi

    echo
    echo "Conda:"
    if command -v conda >/dev/null 2>&1; then
        conda --version
    else
        echo "Conda not found"
    fi

} > "$OUTPUT"

echo "Versions saved to:"
echo "$OUTPUT"o
