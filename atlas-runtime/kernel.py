# Kernel module

try:
    from .observation import Observation
    from .inference import Inference
    from .verification import Verification
    from .evidence import Evidence
    from .decision import Decision
except ImportError:  # loaded as scripts from atlas-runtime/ on sys.path
    from observation import Observation
    from inference import Inference
    from verification import Verification
    from evidence import Evidence
    from decision import Decision


class Kernel:
    def __init__(self):
        self.observation = Observation()
        self.inference = Inference()
        self.verification = Verification()
        self.evidence = Evidence()
        self.decision = Decision()

    def observe(self, data):
        return self.observation.observe(data)

    def infer(self, observation):
        return self.inference.infer(observation)

    def verify(self, data):
        return self.verification.verify(data)

    def record_evidence(self, data):
        return self.evidence.record(data)

    def decide(self, data):
        return self.decision.decide(data)
