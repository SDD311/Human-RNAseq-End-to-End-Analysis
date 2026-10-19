import argparse
import csv
from pathlib import Path

REQUIRED_COLUMNS = {"sample_id", "total_reads", "gc_percent", "q30_percent"}


def summarize_qc(input_file, output_file):
    with open(input_file, newline="", encoding="utf-8") as handle:
        reader = csv.DictReader(handle)
        if not reader.fieldnames or not REQUIRED_COLUMNS.issubset(reader.fieldnames):
            raise ValueError("Input must contain: " + ", ".join(sorted(REQUIRED_COLUMNS)))

        results = []
        for row_number, row in enumerate(reader, start=2):
            try:
                sample_id = row["sample_id"].strip()
                reads = int(row["total_reads"])
                gc = float(row["gc_percent"])
                q30 = float(row["q30_percent"])
            except (ValueError, TypeError, AttributeError) as exc:
                raise ValueError(f"Invalid values at CSV row {row_number}") from exc

            if not sample_id or reads < 0 or not (0 <= gc <= 100) or not (0 <= q30 <= 100):
                raise ValueError(f"Out-of-range values at CSV row {row_number}")

            status = "REVIEW" if q30 < 80 else "PASS"
            results.append({
                "sample_id": sample_id,
                "total_reads": reads,
                "gc_percent": gc,
                "q30_percent": q30,
                "qc_status": status,
            })

    if not results:
        raise ValueError("Input contains no samples")

    output_file = Path(output_file)
    output_file.parent.mkdir(parents=True, exist_ok=True)
    with open(output_file, "w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=[
            "sample_id", "total_reads", "gc_percent", "q30_percent", "qc_status"
        ])
        writer.writeheader()
        writer.writerows(results)

    print(f"Processed {len(results)} samples. Saved: {output_file}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Summarize NGS QC metrics")
    parser.add_argument("--input", required=True, help="Input metrics CSV")
    parser.add_argument("--output", required=True, help="Output summary CSV")
    args = parser.parse_args()
    summarize_qc(args.input, args.output)
