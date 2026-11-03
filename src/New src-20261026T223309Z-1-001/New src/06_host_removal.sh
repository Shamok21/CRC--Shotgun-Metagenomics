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


# Host removal using Bowtie2 and Samtools
# Human reference genome: GRCh38
# Keep paired reads where both mates are unmapped to the human genome

# Create output directory
mkdir -p ${HANDOVER}/04_Bowtie2/FASTQ_Bowtie2

# Go to clean FASTQ directory
cd "$HANDOVER/03_Fastp_Clean"

# Process the six samples sequentially
for SAMPLE in "${SAMPLES[@]}"
do
  echo "===== Processing $SAMPLE ====="

  bowtie2 --very-sensitive -p 4 \
    -x ${HANDOVER}/04_Bowtie2/Host_Reference/GRCh38 \
    -1 FASTQ_Fastp_Clean/${SAMPLE}_1.clean.fastq.gz \
    -2 FASTQ_Fastp_Clean/${SAMPLE}_2.clean.fastq.gz \
  | samtools view -b -f 12 -F 256 - \
  | samtools fastq \
      -1 ${HANDOVER}/04_Bowtie2/FASTQ_Bowtie2/${SAMPLE}_nonhost_1.fastq.gz \
      -2 ${HANDOVER}/04_Bowtie2/FASTQ_Bowtie2/${SAMPLE}_nonhost_2.fastq.gz \
      -0 /dev/null -s /dev/null -n -

  echo "===== Finished $SAMPLE ====="
done
