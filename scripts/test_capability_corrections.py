"""Behavioral controls for the real, read-only capability-correction CLI."""
import copy
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
CHECKER = ROOT / "scripts/check_capability_corrections.py"
RECORD = ROOT / "review/semantic-kernel/competitive-landscape-corrections-20261118/CORRECTIONS.json"


class CapabilityCorrectionTests(unittest.TestCase):
    def setUp(self):
        self.record = json.loads(RECORD.read_text())

    def run_record(self, record):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "corrections.json"
            path.write_text(json.dumps(record))
            return subprocess.run(
                [sys.executable, str(CHECKER), "--record", str(path)],
                capture_output=True, text=True)

    def test_intact_record_passes_without_rewriting_inputs(self):
        paths = {RECORD, CHECKER}

        def collect(value):
            if isinstance(value, dict):
                if "path" in value and "sha256" in value:
                    paths.add(ROOT / value["path"])
                for child in value.values():
                    collect(child)
            elif isinstance(value, list):
                for child in value:
                    collect(child)

        collect(self.record)
        before = {p: (p.read_bytes(), p.stat().st_mtime_ns) for p in paths}
        result = self.run_record(self.record)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("3 corrections", result.stdout)
        self.assertIn("accounted_lines=50", result.stdout)
        self.assertEqual(before, {p: (p.read_bytes(), p.stat().st_mtime_ns) for p in paths})

    def test_missing_correction_blocks_even_when_others_remain(self):
        for index in range(3):
            with self.subTest(index=index):
                record = copy.deepcopy(self.record)
                omitted = record["corrections"].pop(index)["id"]
                result = self.run_record(record)
                self.assertEqual(result.returncode, 3, result.stdout + result.stderr)
                self.assertIn(omitted, result.stderr)

    def test_missing_or_empty_mandatory_sections_block(self):
        sections = [
            (0, "effective_grades"), (0, "supersedes"),
            (0, "historical_report_grades"), (0, "calibration"),
            (1, "effective_grades"), (1, "completes"),
            (1, "historical_report_grades"), (1, "calibration"),
            (2, "accounting"), (2, "commit"), (2, "supersedes"),
        ] + [(i, field) for i in range(3) for field in ("scenario", "evidence")]
        for index, field in sections:
            for empty in (False, True):
                with self.subTest(index=index, field=field, empty=empty):
                    record = copy.deepcopy(self.record)
                    if empty:
                        record["corrections"][index][field] = None
                    else:
                        del record["corrections"][index][field]
                    result = self.run_record(record)
                    self.assertEqual(result.returncode, 3, result.stdout + result.stderr)
                    self.assertIn(field, result.stderr)

    def test_omitted_grade_cell_blocks(self):
        for index in (0, 1):
            record = copy.deepcopy(self.record)
            cell = next(iter(record["corrections"][index]["effective_grades"]))
            del record["corrections"][index]["effective_grades"][cell]
            result = self.run_record(record)
            self.assertEqual(result.returncode, 3, result.stdout + result.stderr)
            self.assertIn(cell, result.stderr)

    def test_duplicate_or_unexpected_correction_fails(self):
        for unexpected in (False, True):
            record = copy.deepcopy(self.record)
            extra = copy.deepcopy(record["corrections"][0])
            if unexpected:
                extra["id"] = "C4-unexpected"
            record["corrections"].append(extra)
            result = self.run_record(record)
            self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
            self.assertIn("correction", result.stderr)

    def test_wrong_count_or_hash_fails(self):
        for wrong_hash in (False, True):
            record = copy.deepcopy(self.record)
            if wrong_hash:
                record["report"]["sha256"] = "0" * 64
            else:
                record["corrections"][2]["accounting"]["counts"]["deposit"]["guidance"] += 1
            result = self.run_record(record)
            self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
            self.assertIn("sha256 mismatch" if wrong_hash else "recomputed counts", result.stderr)

    def test_empty_inventory_or_missing_input_blocks(self):
        for missing_input in (False, True):
            record = copy.deepcopy(self.record)
            if missing_input:
                record["report"]["path"] = "__missing_correction_test_input__"
            else:
                record["corrections"] = []
            result = self.run_record(record)
            self.assertEqual(result.returncode, 3, result.stdout + result.stderr)
            self.assertIn("BLOCKED", result.stderr)


if __name__ == "__main__":
    unittest.main()
