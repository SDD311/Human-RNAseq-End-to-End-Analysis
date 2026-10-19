# NGS Quality Control Summary Pipeline

## Overview
This project demonstrates a simple, reproducible Python workflow for summarising next-generation sequencing (NGS) quality-control metrics.

The script processes sample-level QC metrics from a CSV file, validates the input and generates a structured report.

This is an educational bioinformatics project using synthetic data. It is not a clinically validated pipeline.

## Objectives
- Organise sequencing QC information across multiple samples.
- Extract and summarise total read counts, GC percentages and Q30 percentages.
- Identify samples requiring further review using an illustrative Q30 threshold.
- Demonstrate Python scripting, input validation and reproducible reporting.

## Tools and Technologies
- Python 3
- Python standard libraries: csv, argparse and pathlib
- Git and GitHub
- PowerShell or another compatible terminal

## Repository Structure
```text
ngs-qc-summary/
├── README.md
├── scripts/
│   └── summarize_qc.py
├── data/
│   └── example_qc_metrics.csv
└── results/
    └── qc_summary.csv
```

Additional repository files may include LICENSE and .gitignore.

## Input Data
The example input file is located at `data/example_qc_metrics.csv`.

It contains four synthetic samples with these columns:
- sample_id: sample identifier
- total_reads: total number of reads
- gc_percent: percentage of GC bases
- q30_percent: percentage of bases with a Phred quality score of at least 30

## How to Run
Download or clone this repository, open a terminal in the project root directory and run:

```bash
python scripts/summarize_qc.py --input data/example_qc_metrics.csv --output results/qc_summary.csv
```

On Windows, the command may use `py` instead of `python`.

## Example Results
| Sample | Total Reads | GC (%) | Q30 (%) | Status |
|--------|------------:|-------:|--------:|--------|
| Sample_01 | 1500000 | 48.5 | 92.3 | PASS |
| Sample_02 | 1200000 | 51.2 | 85.6 | PASS |
| Sample_03 | 980000 | 49.1 | 76.4 | REVIEW |
| Sample_04 | 1750000 | 50.3 | 94.2 | PASS |

The script uses an illustrative Q30 cutoff of 80% to label samples as PASS or REVIEW. This threshold is not a universal sequencing QC acceptance criterion.

## Reproducibility
The example uses synthetic CSV data and Python standard libraries. No additional Python packages are required for the current version. Running the command above should regenerate the example report.

## Limitations
- This version processes a prepared metrics CSV rather than raw FASTQ sequencing files.
- It does not yet run FastQC or MultiQC.
- QC status is based only on an illustrative Q30 threshold and does not establish overall sequencing suitability.
- The workflow is for educational and research demonstration only; it is not clinically validated.

## Planned Improvements
- Integrate FastQC and MultiQC outputs.
- Add automated unit tests.
- Improve configuration and QC reporting.
- Test the workflow using a small, appropriately licensed public sequencing dataset.

