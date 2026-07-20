"""Unit tests for Excelion Forge fix manager using mock bpy."""

from __future__ import annotations

import sys
import unittest
from typing import Any, cast
from unittest.mock import MagicMock

import types

# Provide a minimal `bpy` stub for module import-time requirements.
if "bpy" not in sys.modules:
    bpy_mock = types.ModuleType("bpy")
    bpy_mock.types = types.SimpleNamespace(Operator=type("Operator", (), {}), PropertyGroup=object, Context=object)
    bpy_mock.props = types.SimpleNamespace(StringProperty=lambda **k: None, BoolProperty=lambda **k: None)
    bpy_mock.utils = types.SimpleNamespace(register_class=lambda cls: None, unregister_class=lambda cls: None)
    bpy_mock.ops = types.SimpleNamespace(object=types.SimpleNamespace(transform_apply=lambda **k: None, mode_set=types.SimpleNamespace(poll=lambda: lambda: False, __call__=lambda **k: None)))
    sys.modules["bpy"] = bpy_mock

from excelion_forge.operators.fix_manager import FixManager
from excelion_forge.core.runtime.fake_adapter import FakeBpyAdapter


class FakeBone:
    def __init__(self, name: str) -> None:
        self.name = name


class FakeArmatureData:
    def __init__(self, bones: list[FakeBone]) -> None:
        self.bones = bones


class FakeObject:
    def __init__(
        self,
        object_type: str,
        data: FakeArmatureData | None = None,
        select_get_val: bool = True,
    ) -> None:
        self.type = object_type
        self.data = data
        self.select_get = MagicMock(return_value=select_get_val)
        self.select_set = MagicMock()


class FakeContext:
    def __init__(
        self,
        active_object: FakeObject | None = None,
        mode: str = "OBJECT",
    ) -> None:
        self.active_object = active_object
        self.mode = mode


class TestFixManager(unittest.TestCase):
    """Test cases for FixManager auto-fixes."""

    def setUp(self) -> None:
        self.runtime = FakeBpyAdapter()

    def test_apply_transforms_success(self) -> None:
        mock_target = FakeObject(
            object_type="ARMATURE",
            select_get_val=True,
        )
        mock_context = FakeContext(
            active_object=mock_target,
            mode="OBJECT",
        )

        mock_context.runtime = self.runtime
        success = FixManager.fix_issue(cast(Any, mock_context), "APPLY_TRANSFORMS", {})
        self.assertTrue(success)
        self.assertIn(("object.transform_apply", {"location": True, "rotation": True, "scale": True}), self.runtime.calls)

    def test_apply_transforms_wrong_type(self) -> None:
        mock_target = FakeObject(
            object_type="MESH",
        )
        mock_context = FakeContext(
            active_object=mock_target,
            mode="OBJECT",
        )

        mock_context.runtime = self.runtime
        success = FixManager.fix_issue(cast(Any, mock_context), "APPLY_TRANSFORMS", {})
        self.assertFalse(success)
        self.assertEqual(self.runtime.calls, [])

    def test_rename_empty_bones(self) -> None:
        bone1 = FakeBone(name="")
        bone2 = FakeBone(name="Spine")
        bone3 = FakeBone(name="   ")
        mock_target = FakeObject(
            object_type="ARMATURE",
            data=FakeArmatureData(bones=[bone1, bone2, bone3]),
        )
        mock_context = FakeContext(active_object=mock_target)

        success = FixManager.fix_issue(
            cast(Any, mock_context),
            "RENAME_EMPTY_BONE",
            {},
        )

        self.assertTrue(success)
        self.assertEqual(bone1.name, "Bone_000")
        self.assertEqual(bone2.name, "Spine")
        self.assertEqual(bone3.name, "Bone_002")

    def test_rename_duplicate_bones(self) -> None:
        bone1 = FakeBone(name="Root")
        bone2 = FakeBone(name="Root ")
        bone3 = FakeBone(name="Spine")
        mock_target = FakeObject(
            object_type="ARMATURE",
            data=FakeArmatureData(bones=[bone1, bone2, bone3]),
        )
        mock_context = FakeContext(active_object=mock_target)

        success = FixManager.fix_issue(
            cast(Any, mock_context),
            "RENAME_DUPLICATE_BONE",
            {"old_name": "Root"},
        )

        self.assertTrue(success)
        self.assertEqual(bone1.name, "Root")
        self.assertEqual(bone2.name, "Root_fixed")
        self.assertEqual(bone3.name, "Spine")


if __name__ == "__main__":
    unittest.main()
