#!/usr/bin/env python3
"""
Verify that all Atlas Runtime components can be imported correctly
"""

try:
    import atlas_runtime
    print("✓ Successfully imported atlas_runtime module")
    
    # Test that we can create instances
    runtime = atlas_runtime.AtlasRuntime()
    print("✓ Successfully created AtlasRuntime instance")
    
    # Test individual class imports
    from atlas_runtime import Observation, Inference, Verification, Evidence, Decision
    print("✓ Successfully imported all ledger classes")
    
    # Test creating objects
    obs = Observation("test_source", {"data": "test"})
    print("✓ Successfully created Observation object")
    
    inf = Inference("test_obs_id", {"analysis": "test"})
    print("✓ Successfully created Inference object")
    
    ver = Verification("test_inf_id", {"criteria": "test"})
    print("✓ Successfully created Verification object")
    
    evi = Evidence("test_ver_id", "method", "test_obs_id", {"artifact": "test"})
    print("✓ Successfully created Evidence object")
    
    dec = Decision("approved", "reason", ["evidence_id"])
    print("✓ Successfully created Decision object")
    
    print("\n🎉 ALL IMPORTS WORKING CORRECTLY! 🎉")
    print("Atlas Runtime MVP is ready for use!")
    
except ImportError as e:
    print(f"✗ Import error: {e}")
except Exception as e:
    print(f"✗ Error during verification: {e}")