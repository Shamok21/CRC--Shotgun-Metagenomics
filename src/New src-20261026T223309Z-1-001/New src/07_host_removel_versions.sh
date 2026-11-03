#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HANDOVER="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Bowtie2 version:"
bowtie2 --version

echo "Samtools version:"
samtools --version
