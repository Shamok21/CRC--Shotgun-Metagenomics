
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

#!/bin/bash

# ============================================================
# Step 03: Duplicate Removal Using Clumpify
# Project: Colorectal Cancer Shotgun Metagenomics
# Tool: Clumpify (BBTools 40.02)
# ============================================================
#
# Purpose:
# Remove exact duplicate read pairs after human host removal.
#
# Input:
# Paired-end, host-removed FASTQ.gz files (R1 and R2).
#
# Output:
# Two deduplicated FASTQ.gz files per sample.
#
# Memory optimization:
# Automatically split reads into temporary groups to avoid
# exceeding the available RAM on an 8 GB MacBook Air.
#
# Note:
# lowcomplexity=t adjusts memory estimation in Clumpify.
# It does NOT perform low-complexity sequence filtering.
# ============================================================

# Process the six samples sequentially to reduce memory usage.
for SAMPLE in "${SAMPLES[@]}"; do

  # Display the sample currently being processed.
  echo "========== Processing $SAMPLE =========="

  # Clumpify settings:
  # dedupe=t        : Remove exact duplicate read pairs.
  # groups=auto     : Automatically select temporary groups.
  # lowcomplexity=t : Use conservative memory estimation.
  # entryfilter=t   : Reduce memory usage during deduplication.
  # usetmpdir=t     : Enable the specified temporary directory.
  # tmpdir          : Store temporary files on the external SSD.
  # threads=2       : Use two processing threads.
  # -Xmx3g          : Limit Java heap memory to 3 GB.
  # overwrite=t     : Allow overwriting existing output files.

  clumpify.sh \
    in1="${HANDOVER}/04_Bowtie2/FASTQ_Bowtie2/${SAMPLE}_nonhost_1.fastq.gz" \
    in2="${HANDOVER}/04_Bowtie2/FASTQ_Bowtie2/${SAMPLE}_nonhost_2.fastq.gz" \
    out1="${HANDOVER}/05_Clumpify/FASTQ_Clumpify/${SAMPLE}_dedup_1.fastq.gz" \
    out2="${HANDOVER}/05_Clumpify/FASTQ_Clumpify/${SAMPLE}_dedup_2.fastq.gz" \
    dedupe=t groups=auto lowcomplexity=t entryfilter=t \
    usetmpdir=t \
    tmpdir=${HANDOVER}/05_Clumpify/FASTQ_Clumpify \
    threads=2 -Xmx3g overwrite=t

  # Stop the loop if the current sample fails.
  if [ $? -ne 0 ]; then
    echo "FAILED: $SAMPLE — stopping loop"
    break
  fi

  # Confirm successful completion of the current sample.
  echo "COMPLETED: $SAMPLE"

done

