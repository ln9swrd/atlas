"""Tests for experimental VisualPerceptionEngine.

Verifies OptionalDependencyError and NotImplementedError behavior
without requiring cv2/torch installed.
"""

import unittest
from unittest.mock import MagicMock, patch


class TestVisualPerceptionExperimental(unittest.TestCase):
    def test_optional_dependency_error_on_missing_deps(self):
        """When vision deps are missing, OptionalDependencyError is raised."""
        from core.tools.visual_perception import (
            VisualPerceptionEngine,
            OptionalDependencyError,
        )

        with patch(
            "core.tools.visual_perception._require_vision_deps",
            side_effect=OptionalDependencyError(["opencv-python", "torch"]),
        ):
            with self.assertRaises(OptionalDependencyError) as ctx:
                VisualPerceptionEngine()
            self.assertIn("opencv-python", str(ctx.exception))
            self.assertIn("torch", str(ctx.exception))

    def test_not_implemented_when_deps_present(self):
        """When deps load successfully, _load_model raises NotImplementedError."""
        from core.tools.visual_perception import VisualPerceptionEngine

        fake_torch = MagicMock()
        fake_torch.cuda.is_available.return_value = False
        fake_torch.device.return_value = "cpu"

        fake_deps = {
            "cv2": object(),
            "torch": fake_torch,
            "models": object(),
            "transforms": object(),
            "Image": object(),
            "np": object(),
        }

        with patch(
            "core.tools.visual_perception._require_vision_deps",
            return_value=fake_deps,
        ):
            with self.assertRaises(NotImplementedError) as ctx:
                VisualPerceptionEngine()
            self.assertIn("experimental", str(ctx.exception).lower())


if __name__ == "__main__":
    unittest.main()
