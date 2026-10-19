
#!/usr/bin/env bash
set -euo pipefail

# GSE145889 — H929 cell line RNA-seq data
# Download four SRA runs and convert to FASTQ.

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
METADATA="${PROJECT_ROOT}/metadata/samples.csv"
SRA_DIR="${PROJECT_ROOT}/data/sra"
FASTQ_DIR="${PROJECT_ROOT}/data/raw_fastq"

mkdir -p "$SRA_DIR" "$FASTQ_DIR"

# Check dependencies
for tool in prefetch fasterq-dump pigz; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "ERROR: Required tool not installed: $tool" >&2
        exit 1
    fi
done

# Download and extract sequencing runs
tail -n +2 "$METADATA" | while IFS=, read -r sample geo sra cell condition; do

    echo "Processing ${sample} (${sra})"

    prefetch "$sra" --output-directory "$SRA_DIR"

    fasterq-dump \
        "${SRA_DIR}/${sra}/${sra}.sra" \
        --split-files \
        --threads 4 \
        --outdir "$FASTQ_DIR"

    # Rename outputs to biological sample IDs
    if [[ -f "${FASTQ_DIR}/${sra}_1.fastq" && -f "${FASTQ_DIR}/${sra}_2.fastq" ]]; then
        mv "${FASTQ_DIR}/${sra}_1.fastq" "${FASTQ_DIR}/${sample}_R1.fastq"
        mv "${FASTQ_DIR}/${sra}_2.fastq" "${FASTQ_DIR}/${sample}_R2.fastq"
        pigz -p 4 "${FASTQ_DIR}/${sample}_R1.fastq" "${FASTQ_DIR}/${sample}_R2.fastq"
    elif [[ -f "${FASTQ_DIR}/${sra}.fastq" ]]; then
        mv "${FASTQ_DIR}/${sra}.fastq" "${FASTQ_DIR}/${sample}.fastq"
        pigz -p 4 "${FASTQ_DIR}/${sample}.fastq"
    else
        echo "ERROR: Expected FASTQ outputs not found for ${sra}" >&2
        exit 1
    fi

    echo "Completed ${sample}"
done

echo "All four sequencing runs have been downloaded."

