import unittest
import sys
import os

sys.path.insert(
    0,
    os.path.join(os.path.dirname(__file__), '..')
)

from forge.core.factory import ContractFactory

class TestContractFactory(unittest.TestCase):
    def test_create_execution_contract(self):
        contract_dict = {
            "execution_type": "python_execution",
            "entrypoint": "main.py",
            "files": [
                "main.py"
            ]
        }

        contract = ContractFactory.create_execution_contract(
            contract_dict
        )

        self.assertEqual(
            contract.execution_type,
            "python_execution"
        )

        self.assertEqual(
            contract.entrypoint,
            "main.py"
        )

        self.assertEqual(
            contract.files,
            ("main.py",)
        )

    def test_missing_field(self):
        contract_dict = {
            "execution_type": "python_execution"
        }

        with self.assertRaises(ValueError):
            ContractFactory.create_execution_contract(
                contract_dict
            )

    def test_invalid_files_type(self):
        contract_dict = {
            "execution_type": "python_execution",
            "entrypoint": "main.py",
            "files": "main.py"
        }

        with self.assertRaises(ValueError):
            ContractFactory.create_execution_contract(
                contract_dict
            )

    def test_invalid_contract_type(self):
        with self.assertRaises(TypeError):
            ContractFactory.create_execution_contract(
                "not_a_dict"
            )

    def test_empty_execution_type(self):
        contract_dict = {
            "execution_type": "",
            "entrypoint": "main.py",
            "files": []
        }

        with self.assertRaises(ValueError):
            ContractFactory.create_execution_contract(
                contract_dict
            )

    def test_empty_entrypoint(self):
        contract_dict = {
            "execution_type": "python_execution",
            "entrypoint": "",
            "files": []
        }

        with self.assertRaises(ValueError):
            ContractFactory.create_execution_contract(
                contract_dict
            )

    def test_invalid_files_content(self):
        contract_dict = {
            "execution_type": "python_execution",
            "entrypoint": "main.py",
            "files": ["main.py", 123]
        }

        with self.assertRaises(ValueError):
            ContractFactory.create_execution_contract(
                contract_dict
            )

    def test_files_tuple_conversion(self):
        contract_dict = {
            "execution_type": "python_execution",
            "entrypoint": "main.py",
            "files": [
                "main.py",
                "utils.py"
            ]
        }

        contract = ContractFactory.create_execution_contract(
            contract_dict
        )

        self.assertIsInstance(
            contract.files,
            tuple
        )

if __name__ == '__main__':
    unittest.main()