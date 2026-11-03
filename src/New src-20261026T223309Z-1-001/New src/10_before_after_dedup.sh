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

# FastQC and MultiQC before and after deduplication

PROJECT="$HANDOVER"

# Create output folders
mkdir -p "$PROJECT/05_Clumpify/QC_Clumpify"
mkdir -p "$PROJECT/04_Bowtie2/QC_Bowtie2"

# Select only the samples listed in config/samples.txt.
DEDUP_FILES=()
NONHOST_FILES=()
for SAMPLE in "${SAMPLES[@]}"; do
  for READ in 1 2; do
    DEDUP_FILES+=("$PROJECT/05_Clumpify/FASTQ_Clumpify/${SAMPLE}_dedup_${READ}.fastq.gz")
    NONHOST_FILES+=("$PROJECT/04_Bowtie2/FASTQ_Bowtie2/${SAMPLE}_nonhost_${READ}.fastq.gz")
  done
done

# FastQC after deduplication
fastqc -t 2 \
  --outdir "$PROJECT/05_Clumpify/QC_Clumpify" \
  "${DEDUP_FILES[@]}"

# MultiQC after deduplication
multiqc "$PROJECT/05_Clumpify/QC_Clumpify" \
  --outdir "$PROJECT/05_Clumpify/QC_Clumpify" \
  --filename multiqc_dedup_report.html

# FastQC before deduplication
fastqc -t 2 \
  --outdir "$PROJECT/04_Bowtie2/QC_Bowtie2" \
  "${NONHOST_FILES[@]}"

# MultiQC comparison: before vs after
multiqc \
  "$PROJECT/04_Bowtie2/QC_Bowtie2" \
  "$PROJECT/05_Clumpify/QC_Clumpify" \
  --outdir "$PROJECT/05_Clumpify/Results_Clumpify" \
  --filename multiqc_before_after_dedup.html
