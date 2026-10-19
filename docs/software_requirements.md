
# Software Requirements

## Project
End-to-End RNA-seq Analysis of THZ1-Treated
Human H929 Multiple Myeloma Cells

Dataset: GSE145889

## Operating System
Ubuntu Linux through Windows Subsystem for Linux (WSL 2).

## Confirmed Installed Software
- FastQC v0.12.1
- MultiQC v1.35

## Additional Required Software
- SRA Toolkit (prefetch and fasterq-dump)
- pigz
- fastp
- STAR
- Subread (featureCounts)
- R
- DESeq2
- R packages for visualisation and enrichment

## Reference Files
- Human reference genome FASTA
- Matching gene annotation GTF
- STAR genome index

The genome assembly, annotation release,
library strandedness and read layout must
be recorded before executing the pipeline.

## Reproducibility
All software versions, reference releases,
parameters and analysis commands will be
documented after pipeline validation.

## Limitations
This analysis includes two biological
replicates per condition.

Differential expression and pathway analysis
will therefore be exploratory.

The pipeline is intended for research and
educational demonstration, not clinical use.
