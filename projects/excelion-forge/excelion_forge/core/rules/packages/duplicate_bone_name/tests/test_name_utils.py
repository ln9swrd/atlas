from __future__ import annotations

import unittest

from excelion_forge.core.rules.primitives.naming import make_unique_name
from excelion_forge.core.rules.primitives.naming import sanitize_name


class TestNameUtils(unittest.TestCase):
    def test_make_unique_name_returns_same_name_when_available(self) -> None:
        result = make_unique_name("Root", {"Spine", "Arm"})
        self.assertEqual(result, "Root")

    def test_make_unique_name_skips_existing_suffixes(self) -> None:
        result = make_unique_name("Root", {"Root", "Root_2"})
        self.assertEqual(result, "Root_3")

    def test_make_unique_name_handles_empty_name(self) -> None:
        result = make_unique_name("", {"Root"})
        self.assertEqual(result, "")

    def test_make_unique_name_multiple_collisions(self) -> None:
        existing = {"Root", "Root_2", "Root_3", "Root_4"}

        result = make_unique_name(
            "Root",
            existing,
        )

        self.assertEqual(
            result,
            "Root_5",
        )

    def test_make_unique_name_supports_custom_pattern(self) -> None:
        existing = {"Root", "Root.002"}

        result = make_unique_name(
            "Root",
            existing,
            pattern="{base}.{n:03d}",
        )

        self.assertEqual(result, "Root.003")

    def test_make_unique_name_rejects_invalid_pattern(self) -> None:
        with self.assertRaises(ValueError):
            make_unique_name(
                "Root",
                {"Root"},
                pattern="{oops}",
            )

    def test_sanitize_collapses_repeated_symbols(self) -> None:
        self.assertEqual(sanitize_name("Root***:::?"), "Root")

    def test_sanitize_empty_result_fallback(self) -> None:
        self.assertEqual(sanitize_name("***"), "Unnamed")


if __name__ == "__main__":
    unittest.main()
