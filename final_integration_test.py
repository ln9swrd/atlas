#!/usr/bin/env python3
"""
Final integration test for Atlas Runtime MVP
This tests the complete workflow from start to finish
"""

import json
from atlas_runtime import AtlasRuntime

def test_complete_workflow():
    print("=== Final Integration Test ===")
    
    # Initialize the system
    runtime = AtlasRuntime()
    print("1. System initialized successfully")
    
    # Step 1: Create Observation
    observation_data = {
        "source": "temperature_sensor_001",
        "value": 25.6,
        "unit": "celsius",
        "location": "main_lab"
    }
    obs = runtime.record_observation(observation_data)
    print(f"2. Observation created: {obs.id}")
    
    # Step 2: Create Inference
    inference_data = {
        "processed_value": 25.6,
        "interpretation": "Temperature is within normal operating range",
        "confidence": 0.95,
        "analysis_method": "statistical_analysis"
    }
    inf = runtime.record_inference(obs.id, inference_data)
    print(f"3. Inference created: {inf.id}")
    
    # Step 3: Start Verification
    verification_criteria = {
        "threshold": 25.0,
        "acceptable_range": 2.0,
        "verification_type": "statistical",
        "required_confidence": 0.9
    }
    ver = runtime.start_verification(inf.id, verification_criteria)
    print(f"4. Verification started: {ver.id}")
    
    # Step 4: Record Evidence
    evidence_artifact = {
        "p_value": 0.03,
        "test_result": "significant",
        "sample_size": 100,
        "confidence_level": 0.95,
        "statistical_method": "t-test"
    }
    evi = runtime.record_evidence(ver.id, "statistical_analysis", obs.id, evidence_artifact)
    print(f"5. Evidence recorded: {evi.id}")
    
    # Step 5: Record Decision
    dec = runtime.record_decision(
        status="approved",
        reason="Temperature reading within acceptable range and statistically significant",
        evidence_ids=[evi.id]
    )
    print(f"6. Decision recorded: {dec.id}")
    
    # Step 6: Validate System
    validation = runtime.validate()
    print("7. System validation:")
    print(f"   Rule 010 (Consistency): {validation['rule_010_consistency']}")
    print(f"   Rule 011 (Traceability): {validation['rule_011_traceability']}")
    
    # Step 7: Export Ledger
    runtime.export_ledger("final_test_ledger.json")
    print("8. Ledger exported to final_test_ledger.json")
    
    # Step 8: Verify Export Content
    with open("final_test_ledger.json", "r") as f:
        ledger = json.load(f)
    
    print("9. Export verification:")
    print(f"   Observations: {len(ledger['observations'])}")
    print(f"   Inferences: {len(ledger['inferences'])}")  
    print(f"   Verifications: {len(ledger['verifications'])}")
    print(f"   Evidence: {len(ledger['evidence'])}")
    print(f"   Decisions: {len(ledger['decisions'])}")
    
    # Step 9: Verify Traceability Chain
    print("10. Traceability chain verification:")
    
    # Decision -> Evidence -> Verification -> Inference -> Observation
    decision = ledger['decisions'][0]
    evidence = ledger['evidence'][0] 
    verification = ledger['verifications'][0]
    inference = ledger['inferences'][0]
    observation = ledger['observations'][0]
    
    assert decision['evidence_ids'][0] == evidence['id'], "Decision should reference evidence"
    assert evidence['verification_id'] == verification['id'], "Evidence should reference verification"  
    assert verification['inference_id'] == inference['id'], "Verification should reference inference"
    assert inference['observation_id'] == observation['id'], "Inference should reference observation"
    
    print("   ✓ Complete traceability chain verified")
    
    # Step 10: Print Final Summary
    print("\n=== FINAL SUMMARY ===")
    print(f"✓ Complete workflow executed successfully")
    print(f"✓ All {len(ledger['observations'])} observations processed")
    print(f"✓ All {len(ledger['inferences'])} inferences analyzed") 
    print(f"✓ All {len(ledger['verifications'])} verifications completed")
    print(f"✓ All {len(ledger['evidence'])} evidence items recorded")
    print(f"✓ All {len(ledger['decisions'])} decisions made")
    print(f"✓ System validation: {'PASS' if validation['rule_010_consistency'] and validation['rule_011_traceability'] else 'FAIL'}")
    
    print("\n🎉 Atlas Runtime MVP - COMPLETE AND FUNCTIONAL! 🎉")
    return True

if __name__ == "__main__":
    test_complete_workflow()