# Human Reference Genome and Annotation

## Project
GSE145889 — RNA-seq Analysis of THZ1-Treated H929 Human Multiple Myeloma Cells

## Reference Genome
- Species: Homo sapiens
- Genome assembly: GRCh38
- Reference provider: GENCODE
- Genome FASTA: GRCh38 primary assembly
- Annotation: GENCODE comprehensive gene annotation (GTF)

## Reference Directory

reference/
├── genome/
│   ├── GRCh38.primary_assembly.genome.fa
│   └── star_index/
└── annotation/
    └── genes.gtf

## Reference Preparation

The genome FASTA and matching GTF must be downloaded
from the same selected GENCODE release.

A STAR genome index will be generated using the selected
FASTA and GTF files.

## Important Notes

- Reference genome files are not stored on GitHub.
- The exact GENCODE release and download URLs will be
  recorded before pipeline execution.
- Reference checksums will be saved for reproducibility.
- Library layout and strandedness must be verified
  before alignment and gene quantification.
