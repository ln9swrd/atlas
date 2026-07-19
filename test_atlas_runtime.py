#!/usr/bin/env python3
"""
Test script for Atlas Runtime MVP
"""

import json
from atlas_runtime import AtlasRuntime

def test_atlas_runtime():
    print("=== Testing Atlas Runtime MVP ===")
    
    # Initialize runtime
    runtime = AtlasRuntime()
    print("✓ Runtime initialized")
    
    # Test 1: Observation creation
    obs = runtime.record_observation({
        "source": "sensor_1",
        "value": 25.6,
        "unit": "celsius"
    })
    assert obs.id is not None, "Observation ID should be generated"
    assert obs.timestamp is not None, "Observation timestamp should be generated"
    print("✓ Observation created successfully")
    
    # Test 2: Inference creation
    inf = runtime.record_inference(obs.id, {
        "processed_value": 25.6,
        "interpretation": "Temperature is normal",
        "confidence": 0.95
    })
    assert inf.id is not None, "Inference ID should be generated"
    assert inf.timestamp is not None, "Inference timestamp should be generated"
    assert inf.observation_id == obs.id, "Inference should reference correct observation"
    print("✓ Inference created successfully")
    
    # Test 3: Verification creation
    ver = runtime.start_verification(inf.id, {
        "threshold": 25.0,
        "acceptable_range": 2.0
    })
    assert ver.id is not None, "Verification ID should be generated"
    assert ver.timestamp is not None, "Verification timestamp should be generated"
    assert ver.inference_id == inf.id, "Verification should reference correct inference"
    print("✓ Verification created successfully")
    
    # Test 4: Evidence creation
    evi = runtime.record_evidence(ver.id, "statistical_analysis", obs.id, {
        "p_value": 0.03,
        "test_result": "significant"
    })
    assert evi.id is not None, "Evidence ID should be generated"
    assert evi.timestamp is not None, "Evidence timestamp should be generated"
    assert evi.verification_id == ver.id, "Evidence should reference correct verification"
    print("✓ Evidence created successfully")
    
    # Test 5: Decision creation
    dec = runtime.record_decision(
        status="approved",
        reason="Temperature reading within acceptable range",
        evidence_ids=[evi.id]
    )
    assert dec.id is not None, "Decision ID should be generated"
    assert dec.timestamp is not None, "Decision timestamp should be generated"
    assert len(dec.evidence_ids) == 1, "Decision should reference evidence"
    print("✓ Decision created successfully")
    
    # Test 6: Validation
    validation_result = runtime.validate()
    assert validation_result["rule_010_consistency"] == True, "Rule 010 (Consistency) should pass"
    assert validation_result["rule_011_traceability"] == True, "Rule 011 (Traceability) should pass"
    print("✓ Validation passed")
    
    # Test 7: Export
    runtime.export_ledger("test_ledger.json")
    print("✓ Ledger exported successfully")
    
    # Test 8: Verify export content
    with open("test_ledger.json", "r") as f:
        ledger_data = json.load(f)
    
    assert len(ledger_data["observations"]) == 1, "Should have 1 observation"
    assert len(ledger_data["inferences"]) == 1, "Should have 1 inference"
    assert len(ledger_data["verifications"]) == 1, "Should have 1 verification"
    assert len(ledger_data["evidence"]) == 1, "Should have 1 evidence"
    assert len(ledger_data["decisions"]) == 1, "Should have 1 decision"
    print("✓ Export content verified")
    
    # Test 9: Traceability chain
    # Decision -> Evidence -> Verification -> Inference -> Observation
    decision = ledger_data["decisions"][0]
    evidence = ledger_data["evidence"][0]
    verification = ledger_data["verifications"][0]
    inference = ledger_data["inferences"][0]
    observation = ledger_data["observations"][0]
    
    assert decision["evidence_ids"][0] == evidence["id"], "Decision should reference evidence"
    assert evidence["verification_id"] == verification["id"], "Evidence should reference verification"
    assert verification["inference_id"] == inference["id"], "Verification should reference inference"
    assert inference["observation_id"] == observation["id"], "Inference should reference observation"
    print("✓ Traceability chain verified")
    
    print("\n=== All Tests Passed! ===")
    print("Atlas Runtime MVP is working correctly.")
    return True

if __name__ == "__main__":
    test_atlas_runtime()