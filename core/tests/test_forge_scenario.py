import asyncio
import sys
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.append(str(REPO_ROOT))

from core.forge.forge_runtime import ForgeMissionRunner


class ForgeScenarioTests(unittest.TestCase):
    def test_forge_character_creation_mission_runs(self):
        async def _run():
            runner = ForgeMissionRunner()
            return await runner.run_mission(
                mission="Brave character creation",
                asset_name="CHAR_Brave_001",
            )

        result = asyncio.run(_run())

        self.assertEqual(result["mission"], "Brave character creation")
        self.assertEqual(result["decision"]["status"], "approved")
        self.assertTrue(result["review"]["passed"])
        self.assertTrue(result["plugin"]["executed"])
        self.assertTrue(result["audit"]["runtime"])
        self.assertTrue(result["audit"]["integration"])
        self.assertTrue(result["audit"]["external"])


if __name__ == "__main__":
    unittest.main()
