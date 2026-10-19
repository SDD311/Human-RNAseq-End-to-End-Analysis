#!/usr/bin/env bash
set -euo pipefail

# Master RNA-seq analysis pipeline
# GSE145889: H929 THZ1 vs DMSO

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

mkdir -p logs

LOG_FILE="logs/pipeline_$(date +%Y%m%d_%H%M%S).log"

# Save pipeline output to a log and terminal
exec > >(tee -a "$LOG_FILE") 2>&1

echo "========================================"
echo "GSE145889 H929 RNA-seq Pipeline"
echo "========================================"
echo "Started: $(date)"

# Validate required files
for file in \
    metadata/samples.csv \
    config/pipeline.env \
    scripts/01_download.sh \
    scripts/02_fastqc.sh \
    scripts/03_fastp.sh \
    scripts/04_star_alignment.sh \
    scripts/05_featurecounts.sh \
    scripts/06_deseq2.R \
    scripts/07_pathway_analysis.R
do
    if [[ ! -f "$file" ]]; then
        echo "ERROR: Missing file: $file" >&2
        exit 1
    fi
done

source config/pipeline.env

# Prevent execution without reference configuration
if [[ ! -f "$STAR_INDEX/Genome" ]]; then
    echo "ERROR: STAR genome index not prepared" >&2
    exit 1
fi

if [[ ! -f "$GTF" ]]; then
    echo "ERROR: Gene annotation file missing" >&2
    exit 1
fi

if [[ ! "$STRAND" =~ ^[012]$ ]]; then
    echo "ERROR: Library strandedness not configured" >&2
    exit 1
fi

echo "Stage 1: Download sequencing data"
bash scripts/01_download.sh

echo "Stage 2: Raw sequencing quality control"
bash scripts/02_fastqc.sh

echo "Stage 3: Read preprocessing"
bash scripts/03_fastp.sh

echo "Stage 4: STAR alignment"
bash scripts/04_star_alignment.sh

echo "Stage 5: Gene quantification"
bash scripts/05_featurecounts.sh

echo "Stage 6: Differential expression"
Rscript scripts/06_deseq2.R

echo "Stage 7: Hallmark pathway analysis"
Rscript scripts/07_pathway_analysis.R

echo "========================================"
echo "Pipeline completed: $(date)"
echo "Log file: $LOG_FILE"
echo "========================================"
