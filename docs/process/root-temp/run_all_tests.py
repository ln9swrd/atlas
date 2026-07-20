#!/usr/bin/env python3
"""
Run all tests for Atlas Runtime MVP
"""

import sys
import os

def run_test(test_name, test_function):
    """Run a single test and return results"""
    try:
        print(f"Running {test_name}...")
        result = test_function()
        if result:
            print(f"✓ {test_name} - PASSED")
            return True
        else:
            print(f"✗ {test_name} - FAILED")
            return False
    except Exception as e:
        print(f"✗ {test_name} - ERROR: {e}")
        return False

def test_imports():
    """Test that all modules can be imported"""
    try:
        import atlas_runtime
        from atlas_runtime import Observation, Inference, Verification, Evidence, Decision
        return True
    except Exception as e:
        print(f"Import test failed: {e}")
        return False

def test_basic_workflow():
    """Test basic workflow functionality"""
    try:
        from atlas_runtime import AtlasRuntime
        
        runtime = AtlasRuntime()
        
        # Test all core methods exist
        assert hasattr(runtime, 'record_observation')
        assert hasattr(runtime, 'record_inference') 
        assert hasattr(runtime, 'start_verification')
        assert hasattr(runtime, 'record_evidence')
        assert hasattr(runtime, 'record_decision')
        assert hasattr(runtime, 'validate')
        assert hasattr(runtime, 'export_ledger')
        
        # Test basic functionality
        obs = runtime.record_observation({"test": "data"})
        assert obs.id is not None
        
        return True
    except Exception as e:
        print(f"Workflow test failed: {e}")
        return False

def test_traceability():
    """Test traceability chain"""
    try:
        from atlas_runtime import AtlasRuntime
        
        runtime = AtlasRuntime()
        
        # Create complete chain
        obs = runtime.record_observation({"source": "test"})
        inf = runtime.record_inference(obs.id, {"analysis": "test"})
        ver = runtime.start_verification(inf.id, {"criteria": "test"})
        evi = runtime.record_evidence(ver.id, "method", obs.id, {"artifact": "test"})
        dec = runtime.record_decision("approved", "reason", [evi.id])
        
        # Verify chain exists
        assert dec.evidence_ids[0] == evi.id
        assert evi.verification_id == ver.id
        assert ver.inference_id == inf.id
        assert inf.observation_id == obs.id
        
        return True
    except Exception as e:
        print(f"Traceability test failed: {e}")
        return False

def test_validation():
    """Test validation functionality"""
    try:
        from atlas_runtime import AtlasRuntime
        
        runtime = AtlasRuntime()
        obs = runtime.record_observation({"test": "data"})
        validation = runtime.validate()
        
        assert 'rule_010_consistency' in validation
        assert 'rule_011_traceability' in validation
        
        return True
    except Exception as e:
        print(f"Validation test failed: {e}")
        return False

def main():
    print("=== Running Atlas Runtime MVP Tests ===\n")
    
    tests = [
        ("Module Imports", test_imports),
        ("Basic Workflow", test_basic_workflow),
        ("Traceability Chain", test_traceability),
        ("System Validation", test_validation)
    ]
    
    passed = 0
    total = len(tests)
    
    for test_name, test_func in tests:
        if run_test(test_name, test_func):
            passed += 1
        print()
    
    print(f"=== TEST RESULTS: {passed}/{total} tests passed ===")
    
    if passed == total:
        print("🎉 ALL TESTS PASSED! Atlas Runtime MVP is fully functional! 🎉")
        return 0
    else:
        print("❌ Some tests failed. Please review the implementation.")
        return 1

if __name__ == "__main__":
    sys.exit(main())