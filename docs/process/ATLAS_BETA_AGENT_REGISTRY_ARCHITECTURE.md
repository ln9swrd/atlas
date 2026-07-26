# ATLAS Beta Agent Registry Architecture

## 1. Current State

The current Agent Registry is a Markdown index of named agents and their
high-level responsibilities. Business Agent registration has established the
following current state:

| Area | Current state |
| --- | --- |
| Business Agent Profile | Exists at `docs/agents/BUSINESS_AGENT_PROFILE.md` |
| Registry Index | No Business Agents category or Business Agent index entry |
| Capability Definition | Documentation-based table exists in the Business Agent profile |
| Lifecycle Definition | Documentation-based role boundary exists in the Business Agent profile |
| Runtime | No Agent Registry runtime implementation |
| PrintGuard Relationship | Documented project context; canonical Project Registry registration remains pending |

This document is a Beta architecture proposal. It does not create a Registry,
change Alpha documentation, or introduce runtime behavior.

## 2. Required Registry Architecture

Beta should treat an Agent Registry record as a structured contract composed
of the following six concerns:

```text
Agent Registry Record
├── Agent Identity
├── Capability Definition
├── Lifecycle Definition
├── Input / Output Contract
├── Permission Model
└── Audit History
```

| Concern | Required definition | Current Business Agent evidence |
| --- | --- | --- |
| Agent Identity | Stable ID, name, domain, scope, and status | Profile defines `business-agent`, display name, scope, and no-runtime status |
| Capability Definition | Supported capabilities, inputs, outputs, and maturity | Profile capability schema is documentation-defined |
| Lifecycle Definition | Applicable stages, entry conditions, exit conditions, and boundaries | Profile defines Idea/Planning activity and handoff limits |
| Input / Output Contract | Accepted context and generated artifacts | Profile defines supplied concept context and project-status/handover outputs |
| Permission Model | Permitted project actions and prohibited system actions | Planned; current constraints prohibit Core ownership and implementation |
| Audit History | Registration, context-transfer, and handoff evidence | Planned; no audit mechanism exists |

## 3. Business Agent Registration Flow

The proposed documentation-to-registry flow is:

```text
Idea
  ↓
Business Agent
  ↓
Agent Registry Validation
  ↓
Project Candidate
  ↓
Project Registry
```

| Step | Required outcome | Business Agent boundary |
| --- | --- | --- |
| Idea | Supplied facts and explicit unknowns are captured | May create business context; must not infer facts |
| Business Agent | Concept is converted into project context | May maintain project-scoped status and handover documents |
| Agent Registry Validation | Identity, capability, lifecycle, I/O, and permission contract are checked | Documentation validation in the initial Beta scope |
| Project Candidate | Project purpose, status, ownership, dependencies, and next actions are complete | No architecture or code implementation ownership |
| Project Registry | Candidate is entered into the canonical project index | Requires authorized registry update |

PrintGuard is the reference candidate for this flow. Its current status is
Concept Validation; its project-owner, MVP, architecture, dependencies, and
commercial context remain `UNKNOWN`.

## 4. Agent vs Project Boundary

| Entity | Definition | Owns | Does not own |
| --- | --- | --- | --- |
| Agent | A reusable role with capability and responsibility contracts | Its declared capabilities, lifecycle role, I/O contract, and permission boundary | A project's product decisions, implementation, or runtime state unless explicitly assigned |
| Project | A managed unit of business or development work | Its context, goals, lifecycle state, owners, deliverables, and evidence | The reusable definition of an Agent capability |

For Business Agent and PrintGuard, the Business Agent owns documentation
context handling only. PrintGuard owns its business/project context. Neither
relationship grants the Business Agent ownership of Atlas Core or PrintGuard
implementation.

## 5. Beta Implementation Candidates

| Priority | Candidate | Intended outcome | Current status |
| --- | --- | --- | --- |
| P1 | Central Agent Registry Index | Canonical index with a Business Agents category and Business Agent entry | Planned |
| P2 | Capability Schema Validation | Validate required identity, capability, lifecycle, and I/O fields | Planned |
| P3 | Lifecycle Runtime | Represent authorized agent lifecycle transitions without assigning implementation ownership by default | Planned |
| P4 | Permission / Audit Enforcement | Enforce boundaries and retain registration/context-transfer evidence | Planned |

These candidates are ordered proposals only. They do not authorize Beta code
or runtime changes by themselves.

## 6. Recommendation

**Recommend Business Agent as the first Beta Registry Validation Agent.**

Business Agent is suitable as the first validation case because it has a
bounded, documentation-first role; its inputs, outputs, and prohibitions are
explicit; and PrintGuard provides a real Project Candidate without requiring a
runtime implementation. The initial Beta validation should remain
documentation-based and should first prove P1 Registry indexing and P2 schema
validation before considering P3 or P4.

Success criteria for this recommendation are:

1. A canonical Registry index can represent the Business Agent profile without
   ambiguity.
2. Required profile fields can be validated without inferring `UNKNOWN` data.
3. The Business Agent → PrintGuard → Project Registry handoff is traceable.
4. No Agent Registry work changes Atlas Core or grants unapproved project
   ownership.
