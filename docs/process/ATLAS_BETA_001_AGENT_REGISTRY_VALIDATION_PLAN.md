# ATLAS Beta-001 Agent Registry Validation Plan

## 1. Validation Scope

**Validation target:** Business Agent

Beta-001 validates whether a documentation-based Agent profile has enough
defined context to be represented in a future canonical Agent Registry. It does
not implement a Registry, runtime, permission system, or audit system.

| Validation area | Objective |
| --- | --- |
| Identity | Confirm a stable, unambiguous Agent identity and type. |
| Capability | Confirm declared capabilities, maturity, and non-overlap with the defined role. |
| Lifecycle | Confirm lifecycle entry, role, output boundary, and handoff position. |
| Input / Output Contract | Confirm accepted inputs and generated outputs are explicitly defined. |
| Responsibility Boundary | Confirm permitted responsibilities and prohibited ownership are explicit. |

## 2. Registry Entry Requirements

A Registry entry must provide the following fields before approval:

| Required field | Definition | Minimum validation rule |
| --- | --- | --- |
| Agent ID | Stable, unique registry identifier | Present and non-empty. |
| Agent Type | Registry classification, such as Business Agent | Present and maps to one Registry category. |
| Capabilities | Supported actions and maturity | Each capability has a defined purpose and status. |
| Lifecycle Position | Supported stages, entry, exit, and handoff boundary | At least one supported stage and an explicit boundary. |
| Input Schema | Required and optional incoming context | Inputs are named and distinguish known values from `UNKNOWN`. |
| Output Schema | Produced artifacts and their minimum contents | Outputs are named and their purpose is defined. |
| Permission Level | Permitted and prohibited operations | Core, project, and implementation boundaries are explicit. |
| Audit Metadata | Evidence required to trace registration and handoffs | Required audit fields are identified. |

## 3. Validation Process

```text
Profile Creation
  ↓
Schema Validation
  ↓
Capability Review
  ↓
Lifecycle Review
  ↓
Registry Approval
```

| Step | Review activity | Pass condition |
| --- | --- | --- |
| Profile Creation | Confirm the profile exists and identifies its Registry target | A versioned documentation profile is available. |
| Schema Validation | Check all Registry Entry Requirements | No required field is missing. |
| Capability Review | Check capabilities against role and responsibility boundary | No unsupported capability or unbounded ownership claim exists. |
| Lifecycle Review | Check lifecycle position and handoff conditions | Entry, exit, and downstream handoff conditions are explicit. |
| Registry Approval | Record review outcome | All required fields pass; no failure condition remains. |

## 4. Failure Conditions

Registry approval fails when any of the following conditions applies:

- Responsibility scope is unclear or assigns unspecified project, Core, or
  implementation ownership.
- A capability duplicates another Agent role without an explicit boundary.
- Input or output context is absent, ambiguous, or cannot preserve `UNKNOWN`
  information.
- Permission level is absent or does not state prohibited operations.
- Agent ID or Agent Type is absent.
- Lifecycle handoff has no explicit exit condition.
- Required audit metadata is absent.

## 5. Business Agent Validation

Validation evidence: `docs/agents/BUSINESS_AGENT_PROFILE.md`.

| Requirement | Result | Evidence / gap |
| --- | --- | --- |
| Agent ID | PASS | `business-agent` is defined. |
| Agent Type | MISSING | The display name and scope indicate a Business Agent, but no explicit `Agent Type` Registry field is defined. |
| Capabilities | PASS | Capability table defines intake, context creation, unknown-area identification, registry readiness, and planned handoffs. |
| Lifecycle Position | PASS | Idea and Planning roles, later-stage limits, and the Registry/MVP handoff boundary are defined. |
| Input Schema | WARNING | Inputs are listed by capability but are not represented as a formal required/optional schema. |
| Output Schema | WARNING | Outputs are listed by capability but minimum artifact fields are not formalized. |
| Permission Level | MISSING | Constraints prohibit Core ownership and implementation, but no named permission level exists. |
| Audit Metadata | MISSING | The profile identifies future audit history but defines no metadata fields. |
| Responsibility Boundary | PASS | The profile excludes Core ownership, runtime operation, code implementation, and unverified inference. |

**Current validation outcome: WARNING — Registry Approval Pending.**

The Business Agent is suitable as the first Beta validation subject because its
role boundary is explicit and its missing fields are documentation-schema gaps,
not runtime dependencies. Approval requires completion of the missing Registry
entry requirements in an authorized future Registry update.

## 6. PrintGuard Relationship

PrintGuard is the Business Agent's reference project output and the first
Business → Project conversion test case.

```text
Business Agent
  ↓ creates and maintains project context
PrintGuard Project Status + Handover
  ↓ pending canonical registration
ATLAS Project Registry
```

| Relationship check | Result |
| --- | --- |
| Project context documents exist | PASS |
| Concept Validation status is explicit | PASS |
| Business Agent owns documentation context only | PASS |
| PrintGuard implementation or architecture ownership is assigned to Business Agent | PASS — explicitly excluded |
| PrintGuard canonical Project Registry entry | MISSING — pending authorized Registry update |
| PrintGuard named project owner | MISSING — `UNKNOWN` |

PrintGuard does not prove runtime integration. It supplies a controlled,
documentation-only case for validating the Business Agent's inputs, outputs,
and handoff boundary.
