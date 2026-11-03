#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT="$SCRIPT_DIR/bbtools_versions.txt"
{
echo "Deduplication - Clumpify"
clumpify.sh --version 2>&1
echo
echo "Low-Complexity Filtering - BBDuk"
bbduk.sh --version 2>&1
echo
echo "Conda environment: ${CONDA_DEFAULT_ENV:-Not detected}"
} > "$OUTPUT"
echo "Saved to: $OUTPUT"
