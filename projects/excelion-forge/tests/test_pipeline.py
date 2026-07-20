"""Tests for pipeline foundation modules."""

from __future__ import annotations

import unittest

from excelion_forge.core.pipeline import Pipeline
from excelion_forge.core.pipeline import PipelineContext
from excelion_forge.core.pipeline import PipelineError
from excelion_forge.core.pipeline import PipelineRegistry
from excelion_forge.core.pipeline import FunctionTask
from excelion_forge.core.pipeline import Logger
from excelion_forge.core.pipeline import ProgressManager
from excelion_forge.core.pipeline import TaskStatus
from excelion_forge.core.pipeline import chunk_list
from excelion_forge.core.pipeline import safe_get
from excelion_forge.core.pipeline import format_duration


class TestPipelineContext(unittest.TestCase):
    """Tests for PipelineContext."""

    def test_context_operations(self) -> None:
        """Test basic context operations."""
        ctx = PipelineContext()
        ctx.set("key1", "value1")
        self.assertEqual(ctx.get("key1"), "value1")

        ctx.set_result("result1", "data1")
        self.assertEqual(ctx.get_result("result1"), "data1")

        ctx.set_config("config1", "setting1")
        self.assertEqual(ctx.get_config("config1"), "setting1")

    def test_context_clone(self) -> None:
        """Test context cloning."""
        ctx1 = PipelineContext()
        ctx1.set("key1", "value1")
        
        ctx2 = ctx1.clone()
        self.assertEqual(ctx2.get("key1"), "value1")
        
        ctx2.set("key1", "newvalue")
        self.assertEqual(ctx1.get("key1"), "value1")
        self.assertEqual(ctx2.get("key1"), "newvalue")


class TestPipelineTasks(unittest.TestCase):
    """Tests for Task and FunctionTask."""

    def test_function_task(self) -> None:
        """Test FunctionTask execution."""
        def sample_func(ctx: PipelineContext) -> str:
            return "Hello, Pipeline!"
        
        task = FunctionTask("test_task", sample_func)
        ctx = PipelineContext()
        result = task.run(ctx)
        
        self.assertTrue(result.success)
        self.assertEqual(result.status, TaskStatus.COMPLETED)
        self.assertEqual(result.result, "Hello, Pipeline!")

    def test_task_failure(self) -> None:
        """Test task failure handling."""
        def failing_func(ctx: PipelineContext) -> None:
            raise PipelineError("Test error")
        
        task = FunctionTask("fail_task", failing_func)
        ctx = PipelineContext()
        result = task.run(ctx)
        
        self.assertFalse(result.success)
        self.assertEqual(result.status, TaskStatus.FAILED)
        self.assertIsNotNone(result.error)


class TestPipelineRegistry(unittest.TestCase):
    """Tests for Pipeline and PipelineRegistry."""

    def test_pipeline_registration(self) -> None:
        """Test pipeline registration and retrieval."""
        registry = PipelineRegistry()
        pipeline = Pipeline("test_pipeline", "Test Pipeline")
        
        registry.register(pipeline)
        retrieved = registry.get("test_pipeline")
        
        self.assertIsNotNone(retrieved)
        self.assertEqual(retrieved.name, "Test Pipeline")


class TestUtils(unittest.TestCase):
    """Tests for utility functions."""

    def test_chunk_list(self) -> None:
        """Test list chunking."""
        items = [1, 2, 3, 4, 5]
        chunks = chunk_list(items, 2)
        
        self.assertEqual(len(chunks), 3)
        self.assertEqual(chunks[0], [1, 2])
        self.assertEqual(chunks[1], [3, 4])
        self.assertEqual(chunks[2], [5])

    def test_safe_get(self) -> None:
        """Test safe dictionary access."""
        data = {"key1": "value1"}
        self.assertEqual(safe_get(data, "key1"), "value1")
        self.assertEqual(safe_get(data, "nonexistent", "default"), "default")
        self.assertIsNone(safe_get(data, "nonexistent"))

    def test_format_duration(self) -> None:
        """Test duration formatting."""
        self.assertEqual(format_duration(30.5), "30.50s")
        self.assertEqual(format_duration(90), "1m 30s")
        self.assertEqual(format_duration(3723), "1h 2m 3s")


if __name__ == "__main__":
    unittest.main()
