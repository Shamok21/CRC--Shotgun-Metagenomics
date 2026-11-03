#!/usr/bin/env bash
# Reproducible MetaPhlAn taxonomic profiling for low-complexity-filtered paired-end FASTQ files.
# Sample IDs are read from HANDOVER/10_Scripts/config/samples.txt.
# Keep this script under HANDOVER/10_Scripts/MetaPhlAn/.
# Requirements: activate the environment containing MetaPhlAn; prepare the database separately.

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
HANDOVER_DIR="$PROJECT_ROOT/HANDOVER"
CONFIG_FILE="$HANDOVER_DIR/10_Scripts/config/samples.txt"
INPUT_DIR="$HANDOVER_DIR/06_LowComplexity/FASTQ_LowComplexity"
TAXONOMY_DIR="$HANDOVER_DIR/07_Taxonomy/MetaPhlAn"
DB_DIR="$TAXONOMY_DIR/Database"
PROFILE_DIR="$TAXONOMY_DIR/Profiles"
MAPPING_DIR="$TAXONOMY_DIR/Mapping"
LOG_DIR="$TAXONOMY_DIR/Logs"
MERGED_DIR="$TAXONOMY_DIR/Merged"

log() { printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"; }
die() { log "ERROR: $*" >&2; exit 1; }

[[ -f "$CONFIG_FILE" ]] || die "Sample list not found: $CONFIG_FILE. Create it with one sample ID per line."
[[ -d "$INPUT_DIR" ]] || die "Input directory not found: $INPUT_DIR. Keep the project folder structure unchanged."
command -v metaphlan >/dev/null 2>&1 || die "MetaPhlAn is not available. Activate the environment containing MetaPhlAn first."

mkdir -p "$PROFILE_DIR" "$MAPPING_DIR" "$LOG_DIR" "$MERGED_DIR"

# Read sample IDs from the config file; ignore blank lines and lines beginning with #.
mapfile -t SAMPLES < <(sed 's/\r$//' "$CONFIG_FILE" | sed '/^[[:space:]]*$/d; /^[[:space:]]*#/d; s/^[[:space:]]*//; s/[[:space:]]*$//')
((${#SAMPLES[@]} > 0)) || die "No sample IDs found in $CONFIG_FILE"

for sample in "${SAMPLES[@]}"; do
  [[ "$sample" =~ ^[A-Za-z0-9._-]+$ ]] || die "Invalid sample ID '$sample' in $CONFIG_FILE. Use letters, numbers, dots, underscores, or hyphens only."
done

# A downloaded tar archive is not an installed database. Require Bowtie2 index files.
if ! find "$DB_DIR" -type f \( -name '*.bt2' -o -name '*.bt2l' \) -print -quit 2>/dev/null | grep -q .; then
  die "No Bowtie2 index files found under $DB_DIR. Prepare/install the MetaPhlAn database before running; this script will not download it automatically."
fi

log "MetaPhlAn version: $(metaphlan --version 2>&1 | tail -n 1)"
log "Project root: $PROJECT_ROOT"
log "Sample list: $CONFIG_FILE"
log "Input directory: $INPUT_DIR"
log "Database directory: $DB_DIR"
log "Samples to process: ${#SAMPLES[@]}"
log "Using --nproc 1 to reduce memory use."

PROFILE_FILES=()
for sample in "${SAMPLES[@]}"; do
  R1="$INPUT_DIR/${sample}_lowcomplex_1.fastq.gz"
  R2="$INPUT_DIR/${sample}_lowcomplex_2.fastq.gz"
  PROFILE="$PROFILE_DIR/${sample}_profile.tsv"
  BOWTIE_OUT="$MAPPING_DIR/${sample}_bowtie2.bz2"
  LOG_FILE="$LOG_DIR/${sample}_metaphlan.log"

  [[ -s "$R1" ]] || die "Missing or empty R1 file for $sample: $R1"
  [[ -s "$R2" ]] || die "Missing or empty R2 file for $sample: $R2"

  # Skip an existing non-empty profile to make reruns safe.
  if [[ -s "$PROFILE" ]]; then
    log "Skipping $sample because a non-empty profile already exists: $PROFILE"
    PROFILE_FILES+=("$PROFILE")
    continue
  fi

  log "Starting sample $sample"
  if metaphlan "${R1},${R2}" \
      --input_type fastq \
      --nproc 1 \
      --bowtie2db "$DB_DIR" \
      --bowtie2out "$BOWTIE_OUT" \
      -o "$PROFILE" > "$LOG_FILE" 2>&1; then
    cat "$LOG_FILE"
  else
    cat "$LOG_FILE" >&2
    die "MetaPhlAn failed for $sample. See log: $LOG_FILE"
  fi

  [[ -s "$PROFILE" ]] || die "MetaPhlAn did not create a non-empty profile for $sample. See $LOG_FILE"
  PROFILE_FILES+=("$PROFILE")
  log "Finished sample $sample"
done

if command -v merge_metaphlan_tables.py >/dev/null 2>&1; then
  log "Merging per-sample profiles"
  merge_metaphlan_tables.py "${PROFILE_FILES[@]}" > "$MERGED_DIR/merged_abundance_table.tsv"
  log "Merged table: $MERGED_DIR/merged_abundance_table.tsv"
else
  log "WARNING: merge_metaphlan_tables.py not found; individual profiles remain in $PROFILE_DIR"
fi

log "All requested samples processed. Profiles: $PROFILE_DIR"
log "Mappings: $MAPPING_DIR"
log "Logs: $LOG_DIR"
