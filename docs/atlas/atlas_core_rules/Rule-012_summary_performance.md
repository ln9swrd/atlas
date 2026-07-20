# Atlas Core Rule: Summary Performance Optimization

## Rule Identifier
Rule-012: Summary Performance Optimization

## Rule Statement
When session context exceeds 50k Prompt Tokens, implementation of Conversation Summary shall be executed to maintain optimal performance metrics.

## Rule Rationale
Observations indicate that:
- Session context exceeding 50k tokens results in significant performance degradation (To First Token > 15s)
- Implementation of Conversation Summary reduces context by approximately 90% (73k → 5k tokens)
- Performance improvements are measurable and reproducible across multiple sessions

## Verification Requirements
1. Context size monitoring (Prompt Tokens > 50k)
2. Performance baseline establishment
3. Summary implementation timing
4. Post-summary performance validation
5. Statistical analysis of improvement consistency

## Compliance Metrics
- To First Token reduction to < 6 seconds
- Prompt Token usage < 10k after summary
- Response quality maintenance at previous levels
- Reproducibility across 3+ test sessions

## Exception Handling
If session context is < 50k tokens, Summary implementation shall be skipped to avoid unnecessary overhead.

## Decision Framework
- If performance degradation detected, implement Summary
- If improvement pattern confirmed, adopt as operational procedure
- If no improvement observed after 3 tests, reassess approach