# ADR-010: Hybrid AI Provider Architecture

## Status

Accepted

## Context

Atlas relies on AI capabilities for:

* Planning assistance
* Code analysis
* Architecture discussion
* Creative support
* Development workflow coordination

AI requirements are different depending on the task.

Some tasks require:

* Local execution
* Privacy
* Low cost
* Offline capability

Other tasks require:

* Advanced reasoning
* Large context processing
* Specialized capabilities

A single fixed AI provider would limit Atlas flexibility.

---

# Decision

Atlas adopts a Hybrid AI Provider Architecture.

SERA communicates through an AI Provider Interface rather than depending on a specific AI model.

The architecture is:

```text id="0ap7fw"
SERA Agent Layer

↓

AI Provider Interface

↓

--------------------------------

Local AI Provider

Cloud AI Provider

Specialized AI Provider

--------------------------------
```

---

# AI Provider Responsibilities

AI Providers are responsible for:

* Receiving requests
* Generating responses
* Providing reasoning capability

AI Providers do not own:

* Atlas state
* Project knowledge
* Execution decisions

Atlas remains the source of truth.

---

# Local AI Provider

Local AI models support:

Examples:

* Private development work
* Large code analysis
* Offline operation
* Frequent iteration

Advantages:

* Data control
* Lower operating cost
* Availability without external dependency

Limitations:

* Hardware requirements
* Model capability differences

---

# Cloud AI Provider

Cloud AI services support:

Examples:

* Complex reasoning
* Large context analysis
* Specialized capabilities

Advantages:

* High capability models
* Flexible scaling
* Access to advanced features

Limitations:

* Cost
* External dependency
* Data handling requirements

---

# Provider Selection

AI provider selection should consider:

* Task complexity
* Required context size
* Privacy requirements
* Cost
* Available hardware

Example:

```text id="nqzv4p"
Simple Code Search

↓

Local AI


Complex Architecture Review

↓

Cloud AI
```

---

# SERA Relationship

SERA acts as the intelligence coordination layer.

SERA responsibilities:

* Understand user intent
* Prepare context
* Select appropriate capability
* Interpret results

SERA does not:

* Become dependent on one model
* Store authoritative project state
* Replace Atlas execution rules

---

# Evidence and Validation

AI output should be treated as a recommendation until validated.

Flow:

```text id="1u4r1a"
AI Response

↓

Human / System Validation

↓

Evidence

↓

Trusted State Update
```

---

# Security and Privacy Considerations

Provider selection should consider:

* Project confidentiality
* Source code sensitivity
* External transmission requirements

Sensitive information should remain within approved environments.

---

# Consequences

Positive:

* Atlas can use the best AI capability for each task.
* Local and cloud models can coexist.
* AI technology changes do not break the system.
* SERA remains provider-independent.

Trade-offs:

* Provider management becomes more complex.
* Context synchronization must be controlled.
* Cost management is required.

---

# Summary

Atlas uses a Hybrid AI Provider Architecture to separate:

* AI intelligence coordination
* AI model execution
* Project knowledge
* Development state

This allows SERA and Atlas to evolve independently from specific AI technologies.


---

# Related Decisions

Related:

- ADR-001 RuntimeContext as the Official Execution Model
- ADR-006 State and Event Driven Execution Model
- ADR-008 Evidence-First Development Model
- ADR-009 Environment Capability Model