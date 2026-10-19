
import csv
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
from summarize_qc import summarize_qc


def test_valid_qc_data(tmp_path):
    input_file = tmp_path / "input.csv"
    output_file = tmp_path / "output.csv"

    input_file.write_text(
        "sample_id,total_reads,gc_percent,q30_percent\n"
        "Sample_01,1500000,48.5,92.3\n"
        "Sample_02,980000,49.1,76.4\n",
        encoding="utf-8",
    )

    summarize_qc(input_file, output_file)

    with output_file.open(newline="", encoding="utf-8") as handle:
        results = list(csv.DictReader(handle))

    assert len(results) == 2
    assert results[0]["qc_status"] == "PASS"
    assert results[1]["qc_status"] == "REVIEW"


def test_missing_columns(tmp_path):
    input_file = tmp_path / "invalid.csv"
    output_file = tmp_path / "output.csv"

    input_file.write_text(
        "sample_id,total_reads\nSample_01,1500000\n",
        encoding="utf-8",
    )

    with pytest.raises(ValueError, match="Input must contain"):
        summarize_qc(input_file, output_file)


def test_invalid_q30(tmp_path):
    input_file = tmp_path / "invalid.csv"
    output_file = tmp_path / "output.csv"

    input_file.write_text(
        "sample_id,total_reads,gc_percent,q30_percent\n"
        "Sample_01,1500000,48.5,120\n",
        encoding="utf-8",
    )

    with pytest.raises(ValueError, match="Out-of-range"):
        summarize_qc(input_file, output_file)
