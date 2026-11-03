#!/bin/bash
# Portable paths: this script lives in HANDOVER/10_Scripts/02_Host_to_LowComplexity/
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HANDOVER="$(cd "$SCRIPT_DIR/.." && pwd)"
SAMPLE_FILE="$HANDOVER/10_Scripts/config/samples.txt"
[[ -f "$SAMPLE_FILE" ]] || { echo "Missing samples file: $SAMPLE_FILE" >&2; exit 1; }
SAMPLES=()
while IFS= read -r sample || [[ -n "$sample" ]]; do
  sample="${sample%%#*}"
  sample="${sample//[[:space:]]/}"
  [[ -n "$sample" ]] && SAMPLES+=("$sample")
done < "$SAMPLE_FILE"
[[ ${#SAMPLES[@]} -gt 0 ]] || { echo "No samples found in $SAMPLE_FILE" >&2; exit 1; }


# Human reference genome: GRCh38 primary assembly
# Source: Ensembl release 115

# Go to host directory
cd "$HANDOVER/04_Bowtie2/Host_Reference"

# Download GRCh38 reference genome
curl -L -o GRCh38.fa.gz \
https://ftp.ensembl.org/pub/release-115/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz

# Uncompress reference genome
gunzip GRCh38.fa.gz

# Build Bowtie2 index
bowtie2-build --threads 4 GRCh38.fa GRCh38
