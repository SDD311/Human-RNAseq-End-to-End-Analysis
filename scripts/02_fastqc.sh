#!/usr/bin/env bash
set -euo pipefail

# Raw FASTQ quality control: FastQC + MultiQC

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

INPUT_DIR="${PROJECT_ROOT}/data/raw_fastq"
FASTQC_DIR="${PROJECT_ROOT}/results/qc/fastqc_raw"
MULTIQC_DIR="${PROJECT_ROOT}/results/qc/multiqc_raw"

mkdir -p "$FASTQC_DIR" "$MULTIQC_DIR"

# Check software availability
for tool in fastqc multiqc; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "ERROR: $tool is not installed" >&2
        exit 1
    fi
done

# Find raw FASTQ files
shopt -s nullglob
FASTQ_FILES=(
    "$INPUT_DIR"/*.fastq.gz
    "$INPUT_DIR"/*.fq.gz
)

if (( ${#FASTQ_FILES[@]} == 0 )); then
    echo "ERROR: No compressed FASTQ files found" >&2
    exit 1
fi

echo "Running FastQC on ${#FASTQ_FILES[@]} FASTQ files"

fastqc \
    --threads 4 \
    --outdir "$FASTQC_DIR" \
    "${FASTQ_FILES[@]}"

echo "Generating MultiQC report"

multiqc \
    "$FASTQC_DIR" \
    --outdir "$MULTIQC_DIR" \
    --filename multiqc_report.html \
    --force

echo "Raw sequencing QC completed."

