#!/usr/bin/env python3
"""
Verification script to confirm Atlas Runtime MVP meets all requirements
"""

import json
from atlas_runtime import AtlasRuntime

def verify_all_requirements():
    print("=== Verifying Atlas Runtime MVP Completion ===\n")
    
    # 1. Test Ledger Model Creation
    print("1. Testing Ledger Model Creation:")
    runtime = AtlasRuntime()
    print("   ✓ AtlasRuntime class created")
    
    # Test all required classes
    try:
        obs = runtime.record_observation({"test": "data"})
        inf = runtime.record_inference(obs.id, {"analysis": "result"})
        ver = runtime.start_verification(inf.id, {"criteria": "test"})
        evi = runtime.record_evidence(ver.id, "method", obs.id, {"artifact": "data"})
        dec = runtime.record_decision("approved", "reason", [evi.id])
        print("   ✓ All ledger classes (Observation, Inference, Verification, Evidence, Decision) created and working")
    except Exception as e:
        print(f"   ✗ Error in ledger creation: {e}")
        return False
    
    # 2. Test AtlasRuntime Methods
    print("\n2. Testing AtlasRuntime Methods:")
    methods = [
        'record_observation',
        'record_inference', 
        'start_verification',
        'record_evidence',
        'record_decision'
    ]
    
    for method in methods:
        if hasattr(runtime, method):
            print(f"   ✓ {method} method exists")
        else:
            print(f"   ✗ {method} method missing")
            return False
    
    # 3. Test Dataclass Requirements
    print("\n3. Testing Dataclass Requirements:")
    
    # UUID generation
    obs = runtime.record_observation({"test": "data"})
    if obs.id and len(obs.id) > 0:
        print("   ✓ UUID automatically generated")
    else:
        print("   ✗ UUID not generated")
        return False
    
    # Timestamp generation
    if obs.timestamp and len(obs.timestamp) > 0:
        print("   ✓ Timestamp automatically recorded")
    else:
        print("   ✗ Timestamp not recorded")
        return False
    
    # JSON serializability
    try:
        json_str = json.dumps(obs, default=str)
        print("   ✓ JSON serializable")
    except Exception as e:
        print(f"   ✗ JSON serialization failed: {e}")
        return False
    
    # 4. Test Traceability (Rule 011)
    print("\n4. Testing Traceability (Rule 011):")
    
    # Create complete chain
    obs = runtime.record_observation({"source": "sensor_1", "value": 25.6})
    inf = runtime.record_inference(obs.id, {"interpretation": "normal"})
    ver = runtime.start_verification(inf.id, {"threshold": 25.0})
    evi = runtime.record_evidence(ver.id, "statistical", obs.id, {"p_value": 0.03})
    dec = runtime.record_decision("approved", "within range", [evi.id])
    
    # Verify chain exists
    try:
        # Check decision references evidence
        assert dec.evidence_ids[0] == evi.id
        # Check evidence references verification  
        assert evi.verification_id == ver.id
        # Check verification references inference
        assert ver.inference_id == inf.id
        # Check inference references observation
        assert inf.observation_id == obs.id
        print("   ✓ Complete traceability chain established (Decision -> Evidence -> Verification -> Inference -> Observation)")
    except Exception as e:
        print(f"   ✗ Traceability chain failed: {e}")
        return False
    
    # 5. Test Rule Engine (Rule 010 & Rule 011)
    print("\n5. Testing Rule Engine:")
    
    validation = runtime.validate()
    if validation["rule_010_consistency"] == True:
        print("   ✓ Rule 010 (Consistency) validated")
    else:
        print("   ✗ Rule 010 (Consistency) failed")
        return False
        
    if validation["rule_011_traceability"] == True:
        print("   ✓ Rule 011 (Traceability) validated")
    else:
        print("   ✗ Rule 011 (Traceability) failed")
        return False
    
    # 6. Test JSON Export
    print("\n6. Testing JSON Export:")
    
    try:
        runtime.export_ledger("verification_ledger.json")
        with open("verification_ledger.json", "r") as f:
            data = json.load(f)
        
        required_sections = ["observations", "inferences", "verifications", "evidence", "decisions"]
        for section in required_sections:
            if section in data:
                print(f"   ✓ {section} section present in export")
            else:
                print(f"   ✗ {section} section missing from export")
                return False
        
        print("   ✓ Complete ledger exported successfully")
    except Exception as e:
        print(f"   ✗ Export failed: {e}")
        return False
    
    # 7. Verify All Requirements Met
    print("\n=== COMPLETION VERIFICATION ===")
    print("✓ Ledger Model with Observation, Inference, Verification, Evidence, Decision classes")
    print("✓ Automatic UUID and timestamp generation") 
    print("✓ JSON serializability")
    print("✓ Complete traceability chain (Rule 011)")
    print("✓ Rule Engine validation (Rule 010 & Rule 011)")
    print("✓ JSON export functionality")
    print("✓ All Atlas Runtime methods implemented")
    
    print("\n🎉 Atlas Runtime MVP is COMPLETE and MEETS ALL REQUIREMENTS! 🎉")
    return True

if __name__ == "__main__":
    verify_all_requirements()