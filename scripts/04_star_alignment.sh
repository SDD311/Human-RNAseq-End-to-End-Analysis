#!/usr/bin/env bash
set -euo pipefail

# STAR alignment of GSE145889 H929 RNA-seq samples

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

source config/pipeline.env

INPUT="data/trimmed_fastq"
OUTPUT="results/alignment"

mkdir -p "$OUTPUT"

command -v STAR >/dev/null || {
    echo "ERROR: STAR is not installed" >&2
    exit 1
}

[[ -f "$STAR_INDEX/Genome" ]] || {
    echo "ERROR: STAR genome index is missing" >&2
    exit 1
}

while IFS=, read -r sample geo sra cell condition; do

    [[ "$sample" == "sample_id" || -z "$sample" ]] && continue

    echo "Aligning $sample"

    R1="$INPUT/${sample}_R1.fastq.gz"
    R2="$INPUT/${sample}_R2.fastq.gz"
    SINGLE="$INPUT/${sample}.fastq.gz"

    READS=()

    if [[ -f "$R1" && -f "$R2" ]]; then
        READS=("$R1" "$R2")
    elif [[ -f "$SINGLE" ]]; then
        READS=("$SINGLE")
    else
        echo "ERROR: Missing FASTQ for $sample" >&2
        exit 1
    fi

    STAR \
        --runThreadN "$THREADS" \
        --genomeDir "$STAR_INDEX" \
        --readFilesIn "${READS[@]}" \
        --readFilesCommand zcat \
        --outFileNamePrefix "$OUTPUT/${sample}_" \
        --outSAMtype BAM SortedByCoordinate \
        --outSAMattributes Standard

    echo "Finished aligning $sample"

done < metadata/samples.csv

echo "All alignments completed."

