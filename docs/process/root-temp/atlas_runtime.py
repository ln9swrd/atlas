import json
import uuid
from datetime import datetime
from typing import List, Optional
from dataclasses import dataclass, asdict

@dataclass
class Observation:
    id: str = None
    timestamp: str = None
    data: dict = None
    
    def __post_init__(self):
        if self.id is None:
            self.id = str(uuid.uuid4())
        if self.timestamp is None:
            self.timestamp = datetime.now().isoformat()
        if self.data is None:
            self.data = {}

@dataclass
class Inference:
    id: str = None
    timestamp: str = None
    observation_id: str = None
    data: dict = None
    
    def __post_init__(self):
        if self.id is None:
            self.id = str(uuid.uuid4())
        if self.timestamp is None:
            self.timestamp = datetime.now().isoformat()
        if self.data is None:
            self.data = {}

@dataclass
class Verification:
    id: str = None
    timestamp: str = None
    inference_id: str = None
    criteria: dict = None
    result: bool = None
    
    def __post_init__(self):
        if self.id is None:
            self.id = str(uuid.uuid4())
        if self.timestamp is None:
            self.timestamp = datetime.now().isoformat()
        if self.criteria is None:
            self.criteria = {}

@dataclass
class Evidence:
    id: str = None
    timestamp: str = None
    verification_id: str = None
    method: str = None
    observation_id: str = None
    artifact: dict = None
    
    def __post_init__(self):
        if self.id is None:
            self.id = str(uuid.uuid4())
        if self.timestamp is None:
            self.timestamp = datetime.now().isoformat()
        if self.artifact is None:
            self.artifact = {}

@dataclass
class Decision:
    id: str = None
    timestamp: str = None
    status: str = None  # 'approved', 'rejected', 'pending'
    reason: str = None
    evidence_ids: List[str] = None
    
    def __post_init__(self):
        if self.id is None:
            self.id = str(uuid.uuid4())
        if self.timestamp is None:
            self.timestamp = datetime.now().isoformat()
        if self.evidence_ids is None:
            self.evidence_ids = []

class AtlasRuntime:
    def __init__(self):
        self.observations: List[Observation] = []
        self.inferences: List[Inference] = []
        self.verifications: List[Verification] = []
        self.evidence_list: List[Evidence] = []
        self.decisions: List[Decision] = []
    
    def record_observation(self, data: dict) -> Observation:
        obs = Observation(data=data)
        self.observations.append(obs)
        return obs
    
    def record_inference(self, observation_id: str, data: dict) -> Inference:
        inference = Inference(observation_id=observation_id, data=data)
        self.inferences.append(inference)
        return inference
    
    def start_verification(self, inference_id: str, criteria: dict) -> Verification:
        verification = Verification(inference_id=inference_id, criteria=criteria)
        self.verifications.append(verification)
        return verification
    
    def record_evidence(self, verification_id: str, method: str, observation_id: str, artifact: dict) -> Evidence:
        evidence = Evidence(
            verification_id=verification_id,
            method=method,
            observation_id=observation_id,
            artifact=artifact
        )
        self.evidence_list.append(evidence)
        return evidence
    
    def record_decision(self, status: str, reason: str, evidence_ids: List[str]) -> Decision:
        decision = Decision(status=status, reason=reason, evidence_ids=evidence_ids)
        self.decisions.append(decision)
        return decision
    
    def validate(self) -> dict:
        """Validate Rule 010 (Consistency) and Rule 011 (Traceability)"""
        results = {
            "rule_010_consistency": True,
            "rule_011_traceability": True,
            "errors": []
        }
        
        # Rule 010: Consistency check
        # This is a simplified check - in practice this would be more complex
        # For now, we'll just ensure all objects have required fields
        for obs in self.observations:
            if not obs.id or not obs.timestamp:
                results["rule_010_consistency"] = False
                results["errors"].append("Observation missing required fields")
                
        for inf in self.inferences:
            if not inf.id or not inf.timestamp or not inf.observation_id:
                results["rule_010_consistency"] = False
                results["errors"].append("Inference missing required fields")
                
        for ver in self.verifications:
            if not ver.id or not ver.timestamp or not ver.inference_id:
                results["rule_010_consistency"] = False
                results["errors"].append("Verification missing required fields")
                
        for evi in self.evidence_list:
            if not evi.id or not evi.timestamp or not evi.verification_id:
                results["rule_010_consistency"] = False
                results["errors"].append("Evidence missing required fields")
                
        for dec in self.decisions:
            if not dec.id or not dec.timestamp or not dec.status:
                results["rule_010_consistency"] = False
                results["errors"].append("Decision missing required fields")
        
        # Rule 011: Traceability check
        # Check that each decision has evidence that traces back to an observation
        for decision in self.decisions:
            if not decision.evidence_ids:
                results["rule_011_traceability"] = False
                results["errors"].append(f"Decision {decision.id} has no evidence")
                continue
                
            for evidence_id in decision.evidence_ids:
                # Find the evidence
                evidence = next((e for e in self.evidence_list if e.id == evidence_id), None)
                if not evidence:
                    results["rule_011_traceability"] = False
                    results["errors"].append(f"Evidence {evidence_id} not found")
                    continue
                    
                # Find the verification that generated this evidence
                verification = next((v for v in self.verifications if v.id == evidence.verification_id), None)
                if not verification:
                    results["rule_011_traceability"] = False
                    results["errors"].append(f"Verification {evidence.verification_id} not found")
                    continue
                    
                # Find the inference that generated this verification
                inference = next((i for i in self.inferences if i.id == verification.inference_id), None)
                if not inference:
                    results["rule_011_traceability"] = False
                    results["errors"].append(f"Inference {verification.inference_id} not found")
                    continue
                    
                # Find the observation that generated this inference
                observation = next((o for o in self.observations if o.id == inference.observation_id), None)
                if not observation:
                    results["rule_011_traceability"] = False
                    results["errors"].append(f"Observation {inference.observation_id} not found")
        
        return results
    
    def export_ledger(self, filename: str = "ledger.json"):
        """Export the entire ledger to a JSON file"""
        ledger_data = {
            "observations": [asdict(obs) for obs in self.observations],
            "inferences": [asdict(inf) for inf in self.inferences],
            "verifications": [asdict(ver) for ver in self.verifications],
            "evidence": [asdict(evi) for evi in self.evidence_list],
            "decisions": [asdict(dec) for dec in self.decisions]
        }
        
        with open(filename, 'w') as f:
            json.dump(ledger_data, f, indent=2)

# Demo execution
if __name__ == "__main__":
    # Initialize the runtime
    runtime = AtlasRuntime()
    
    # Create an observation
    obs = runtime.record_observation({
        "source": "sensor_1",
        "value": 25.6,
        "unit": "celsius"
    })
    print(f"Created observation: {obs.id}")
    
    # Create an inference
    inf = runtime.record_inference(obs.id, {
        "processed_value": 25.6,
        "interpretation": "Temperature is normal",
        "confidence": 0.95
    })
    print(f"Created inference: {inf.id}")
    
    # Start verification
    ver = runtime.start_verification(inf.id, {
        "threshold": 25.0,
        "acceptable_range": 2.0
    })
    print(f"Started verification: {ver.id}")
    
    # Record evidence
    evi = runtime.record_evidence(ver.id, "statistical_analysis", obs.id, {
        "p_value": 0.03,
        "test_result": "significant"
    })
    print(f"Recorded evidence: {evi.id}")
    
    # Record decision
    dec = runtime.record_decision(
        status="approved",
        reason="Temperature reading within acceptable range",
        evidence_ids=[evi.id]
    )
    print(f"Recorded decision: {dec.id}")
    
    # Validate the system
    validation_result = runtime.validate()
    print("Validation results:")
    print(json.dumps(validation_result, indent=2))
    
    # Export ledger
    runtime.export_ledger()
    print("Ledger exported to ledger.json")