#!/usr/bin/env bash
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

# Step 07: Paired-end low-complexity filtering, quality control, and reporting.
# Project: Shotgun metagenomics
# IMPORTANT: This script is for documentation/reproducibility.
# Do not rerun over completed results; the safety check below prevents overwriting.

set -euo pipefail

IN="$HANDOVER/05_Clumpify/FASTQ_Clumpify"
OUT="$HANDOVER/06_LowComplexity"
FASTQ="$OUT/FASTQ_LowComplexity"
LOG="$OUT/Results_LowComplexity"
CSV="$LOG"
FASTQC="$OUT/QC_LowComplexity"
MULTIQC="$OUT/QC_LowComplexity"

# Prevent accidentally replacing existing final results or the existing summary.
if [[ -e "$CSV/lowcomplex_summary.csv" ]]; then
  echo "STOP: Existing low-complexity results found in $OUT" >&2
  echo "This script will not overwrite your completed analysis." >&2
  exit 1
fi
for sample in "${SAMPLES[@]}"; do
  if [[ -e "$FASTQ/${sample}_lowcomplex_1.fastq.gz" || -e "$FASTQ/${sample}_lowcomplex_2.fastq.gz" ]]; then
    echo "STOP: Output FASTQ already exists for $sample" >&2
    exit 1
  fi
done

# Organize each output type in its own folder.
mkdir -p "$FASTQ" "$LOG" "$CSV" "$FASTQC" "$MULTIQC"

# Record software versions for reproducibility.
{
  echo "=== Java ==="
  java -version 2>&1
  echo "=== BBTools/BBDuk ==="
  bbduk.sh --version 2>&1 || true
  echo "=== FastQC ==="
  fastqc --version 2>&1
  echo "=== MultiQC ==="
  multiqc --version 2>&1
} > "$LOG/software_versions.log"

# CSV counts represent reads, not read pairs.
SUMMARY="$CSV/lowcomplex_summary.csv"
printf 'Sample,Input_Reads,Low_Entropy_Discards,Output_Reads\n' > "$SUMMARY"

# Create one combined BBDuk log while retaining per-sample original logs.
COMBINED="$LOG/lowcomplex_all_samples.log"
: > "$COMBINED"

for sample in "${SAMPLES[@]}"; do
  echo "Processing $sample"
  r1="$IN/${sample}_dedup_1.fastq.gz"
  r2="$IN/${sample}_dedup_2.fastq.gz"
  tmp="$OUT/${sample}_interleaved.fastq.gz"

  # Validate both deduplicated input files before processing.
  [[ -s "$r1" && -s "$r2" ]] || { echo "Missing input for $sample" >&2; exit 1; }

  # Convert separate R1/R2 files into properly paired interleaved FASTQ.
  # This avoids the paired-input streaming error observed with BBDuk.
  reformat.sh in1="$r1" in2="$r2" out="$tmp" \
    2> "$LOG/${sample}_reformat.log"

  # Remove low-entropy reads with BBDuk, keeping paired-end outputs synchronized.
  # Settings match the successful test: entropy=0.5, entropyk=5, entropywindow=50.
  bbduk.sh -Xmx2g threads=2 \
    in="$tmp" interleaved=t \
    out1="$FASTQ/${sample}_lowcomplex_1.fastq.gz" \
    out2="$FASTQ/${sample}_lowcomplex_2.fastq.gz" \
    entropy=0.5 entropyk=5 entropywindow=50 \
    2> "$LOG/${sample}_lowcomplex.log"

  # Append a labeled copy of each BBDuk log to the combined log.
  printf '\n========== %s ==========\n' "$sample" >> "$COMBINED"
  cat "$LOG/${sample}_lowcomplex.log" >> "$COMBINED"

  # Extract read counts from the BBDuk report into the CSV summary.
  awk -v sample="$sample" '
    /^Input:/ {input=$2}
    /^Low entropy discards:/ {removed=$4}
    /^Result:/ {output=$2}
    END {
      if (input=="" || removed=="" || output=="") exit 1
      print sample "," input "," removed "," output
    }
  ' "$LOG/${sample}_lowcomplex.log" >> "$SUMMARY"

  # Remove only the temporary interleaved file after successful processing.
  rm -- "$tmp"
  echo "Finished $sample"
done

# Generate individual FastQC reports for all 12 filtered FASTQ files.
fastqc -t 2 --outdir "$FASTQC" "$FASTQ"/*_lowcomplex_[12].fastq.gz

# Aggregate FastQC reports into one MultiQC HTML report.
multiqc "$FASTQC" --outdir "$MULTIQC" \
  --filename multiqc_lowcomplex_report.html --force

echo "Completed all six samples. Organized results: $OUT"
