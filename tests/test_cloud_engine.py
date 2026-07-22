"""
Tests for CloudPipelineEngine (Atlas v3.0 Final)
"""
import unittest
from core.cloud.cloud_engine import CloudPipelineEngine, CloudBuildPayload


class TestCloudPipelineEngine(unittest.TestCase):

    def setUp(self):
        self.engine = CloudPipelineEngine(cloud_region="asia-northeast3")

    def test_create_payload(self):
        payload = self.engine.create_build_payload("BUILD-001", "Excelion")
        self.assertEqual(payload.build_id, "BUILD-001")
        self.assertEqual(payload.project_name, "Excelion")
        self.assertEqual(payload.parameters["region"], "asia-northeast3")

    def test_trigger_cloud_build(self):
        payload = self.engine.create_build_payload("BUILD-002", "Excelion")
        res = self.engine.trigger_cloud_build(payload)
        self.assertEqual(res["status"], "QUEUED")

        status = self.engine.get_build_status("BUILD-002")
        self.assertIsNotNone(status)
        self.assertEqual(status["build_id"], "BUILD-002")


if __name__ == "__main__":
    unittest.main()
