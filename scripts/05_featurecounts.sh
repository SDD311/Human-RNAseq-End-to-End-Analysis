#!/usr/bin/env bash
set -euo pipefail

# Gene-level quantification with featureCounts

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

source config/pipeline.env

mkdir -p results/counts

command -v featureCounts >/dev/null || {
    echo "ERROR: featureCounts is not installed" >&2
    exit 1
}

[[ -f "$GTF" ]] || {
    echo "ERROR: Gene annotation GTF missing" >&2
    exit 1
}

if [[ ! "$STRAND" =~ ^[012]$ ]]; then
    echo "ERROR: Set STRAND to 0, 1, or 2 after verifying the library protocol" >&2
    exit 1
fi

shopt -s nullglob

BAMS=(
    results/alignment/*_Aligned.sortedByCoord.out.bam
)

if [[ "${#BAMS[@]}" -ne 4 ]]; then
    echo "ERROR: Expected four aligned BAM files, found ${#BAMS[@]}" >&2
    exit 1
fi

# Detect whether the sequencing data are paired-end
if [[ -f data/trimmed_fastq/H929_D1_R1.fastq.gz &&
      -f data/trimmed_fastq/H929_D1_R2.fastq.gz ]]; then
    PAIRED_OPTIONS=(-p --countReadPairs)
else
    PAIRED_OPTIONS=()
fi

featureCounts \
    -T "$THREADS" \
    -a "$GTF" \
    -o results/counts/gene_counts.txt \
    -t exon \
    -g gene_id \
    -s "$STRAND" \
    "${PAIRED_OPTIONS[@]}" \
    "${BAMS[@]}"

echo "Gene quantification completed."

