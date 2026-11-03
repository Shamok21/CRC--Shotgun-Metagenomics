
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

# Step 05: Check the deduplicated files
# Make sure the files are okay and the paired reads still match.


# Check 1: File integrity and read counts
# Go through all six samples and check both R1 and R2 files.
for S in "${SAMPLES[@]}"; do

  # Folder containing the deduplicated reads.
  D="$HANDOVER/05_Clumpify/FASTQ_Clumpify"

  # R1 and R2 files for the current sample.
  F1="$D/${S}_dedup_1.fastq.gz"
  F2="$D/${S}_dedup_2.fastq.gz"

  # Check that both gzip files can be read without errors.
  if gzip -t "$F1" "$F2" 2>/dev/null; then

    # Each FASTQ read has four lines, so divide by four.
    R1=$(($(gzip -cd "$F1" | wc -l) / 4))
    R2=$(($(gzip -cd "$F2" | wc -l) / 4))

    # R1 and R2 should have the same number of reads.
    if [ "$R1" -eq "$R2" ]; then
      echo "$S: PASS | R1=$R1 | R2=$R2"
    else
      echo "$S: FAIL | Read counts differ: R1=$R1 R2=$R2"
    fi
  else
    echo "$S: FAIL | Missing or corrupted FASTQ.gz"
  fi
done


# Check 2: Compare reads before and after deduplication
# This shows how many read pairs were removed from each sample.

D="$HANDOVER"

# Print the column names.
printf "Sample\tBefore\tAfter\tRemoved\tRemoved%%\n"

for S in "${SAMPLES[@]}"; do

  # Count read pairs before deduplication (after host removal).
  BEFORE=$(($(gzip -cd "$D/04_Bowtie2/FASTQ_Bowtie2/${S}_nonhost_1.fastq.gz" | wc -l) / 4))

  # Count read pairs remaining after deduplication.
  AFTER=$(($(gzip -cd "$D/05_Clumpify/FASTQ_Clumpify/${S}_dedup_1.fastq.gz" | wc -l) / 4))

  # Calculate how many pairs were removed.
  REMOVED=$((BEFORE-AFTER))

  # Calculate the percentage removed.
  PCT=$(awk -v r="$REMOVED" -v b="$BEFORE" 'BEGIN {printf "%.2f",100*r/b}')

  # Print the results for this sample.
  printf "%s\t%s\t%s\t%s\t%s%%\n" "$S" "$BEFORE" "$AFTER" "$REMOVED" "$PCT"
done


# Check 3: Make sure paired read IDs match
# R1 and R2 should have matching IDs in the same order.
# We compare the IDs instead of comparing the read sequences.

for S in "${SAMPLES[@]}"; do

  D="$HANDOVER/05_Clumpify/FASTQ_Clumpify"

  # Take the read IDs from both files and compare them.
  # awk selects the header line of each FASTQ read.
  # The /1 and /2 endings are removed before comparing.
  if diff -q \
    <(gzip -cd "$D/${S}_dedup_1.fastq.gz" | awk 'NR%4==1 {sub(/\/[12]$/, "", $1); print $1}') \
    <(gzip -cd "$D/${S}_dedup_2.fastq.gz" | awk 'NR%4==1 {sub(/\/[12]$/, "", $1); print $1}') \
    >/dev/null; then

    echo "$S: PAIR IDs PASS"
  else
    echo "$S: PAIR IDs FAIL"
  fi
done

