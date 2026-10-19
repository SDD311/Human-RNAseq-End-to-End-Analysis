#!/usr/bin/env bash
set -euo pipefail

# FASTQ preprocessing using fastp
# Trimming parameters are preliminary and must
# be reviewed after inspecting FastQC results.

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

INPUT_DIR="${PROJECT_ROOT}/data/raw_fastq"
OUTPUT_DIR="${PROJECT_ROOT}/data/trimmed_fastq"
REPORT_DIR="${PROJECT_ROOT}/results/fastp"
METADATA="${PROJECT_ROOT}/metadata/samples.csv"

mkdir -p "$OUTPUT_DIR" "$REPORT_DIR"

if ! command -v fastp >/dev/null 2>&1; then
    echo "ERROR: fastp is not installed" >&2
    exit 1
fi

while IFS=, read -r sample geo sra cell condition; do

    [[ "$sample" == "sample_id" ]] && continue
    [[ -z "$sample" ]] && continue

    R1="${INPUT_DIR}/${sample}_R1.fastq.gz"
    R2="${INPUT_DIR}/${sample}_R2.fastq.gz"
    SINGLE="${INPUT_DIR}/${sample}.fastq.gz"

    echo "Processing sample: $sample"

    if [[ -f "$R1" && -f "$R2" ]]; then

        fastp \
            --in1 "$R1" \
            --in2 "$R2" \
            --out1 "${OUTPUT_DIR}/${sample}_R1.fastq.gz" \
            --out2 "${OUTPUT_DIR}/${sample}_R2.fastq.gz" \
            --thread 4 \
            --html "${REPORT_DIR}/${sample}.html" \
            --json "${REPORT_DIR}/${sample}.json"

    elif [[ -f "$SINGLE" ]]; then

        fastp \
            --in1 "$SINGLE" \
            --out1 "${OUTPUT_DIR}/${sample}.fastq.gz" \
            --thread 4 \
            --html "${REPORT_DIR}/${sample}.html" \
            --json "${REPORT_DIR}/${sample}.json"

    else
        echo "ERROR: FASTQ files missing for $sample" >&2
        exit 1
    fi

done < "$METADATA"

echo "Preprocessing completed for all samples."

