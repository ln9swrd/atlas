#!/usr/bin/env python3
"""
Demo script for Atlas Runtime MVP
This demonstrates the complete workflow from observation to decision
"""

import json
from atlas_runtime import AtlasRuntime, Observation, Inference, Verification, Evidence, Decision

def main():
    print("=== Atlas Runtime MVP Demo ===")
    
    # Initialize the runtime
    runtime = AtlasRuntime()
    print("✓ Atlas Runtime initialized")
    
    # Step 1: Create an observation
    obs = runtime.record_observation({
        "source": "temperature_sensor_001",
        "value": 25.6,
        "unit": "celsius",
        "location": "room_A"
    })
    print(f"✓ Observation created: {obs.id}")
    
    # Step 2: Create an inference
    inf = runtime.record_inference(obs.id, {
        "processed_value": 25.6,
        "interpretation": "Temperature is normal",
        "confidence": 0.95,
        "analysis_method": "statistical_analysis"
    })
    print(f"✓ Inference created: {inf.id}")
    
    # Step 3: Start verification
    ver = runtime.start_verification(inf.id, {
        "threshold": 25.0,
        "acceptable_range": 2.0,
        "verification_type": "statistical"
    })
    print(f"✓ Verification started: {ver.id}")
    
    # Step 4: Record evidence
    evi = runtime.record_evidence(ver.id, "statistical_analysis", obs.id, {
        "p_value": 0.03,
        "test_result": "significant",
        "sample_size": 100,
        "confidence_level": 0.95
    })
    print(f"✓ Evidence recorded: {evi.id}")
    
    # Step 5: Record decision
    dec = runtime.record_decision(
        status="approved",
        reason="Temperature reading within acceptable range and statistically significant",
        evidence_ids=[evi.id]
    )
    print(f"✓ Decision recorded: {dec.id}")
    
    # Validate the system (Rule 010 & Rule 011)
    print("\n=== Validation ===")
    validation_result = runtime.validate()
    print("Validation results:")
    print(json.dumps(validation_result, indent=2))
    
    # Export ledger
    print("\n=== Exporting Ledger ===")
    runtime.export_ledger()
    print("✓ Ledger exported to ledger.json")
    
    # Display traceability
    print("\n=== Traceability Chain ===")
    print(f"Decision {dec.id} -> Evidence {evi.id} -> Verification {ver.id} -> Inference {inf.id} -> Observation {obs.id}")
    
    print("\n=== Demo Complete ===")

if __name__ == "__main__":
    main()