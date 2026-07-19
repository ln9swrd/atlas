# Review Layer

The **Review Layer** is the core quality gate in Project Atlas. It focuses on evaluating output, score-carding, and providing actionable improvement directions.

## Review Philosophy
> **"AI prioritizes review over generation."**
Evaluating and validating quality is a higher-leverage activity for AI than pure code or asset generation.

## Atlas Review Scorecard Format
Every asset or feature review should produce a structured markdown block in this format:

```markdown
### Atlas Review: [Asset/Feature Name]

| Category | Rating | Notes |
| :--- | :--- | :--- |
| **Topology** | ★★★★★ | Polycount, flow, edge loops, manifold state |
| **Naming** | ★★★★☆ | Adherence to naming rules and directory paths |
| **Animation** | ★★★☆☆ | Deformations, weight painting, rigs |
| **Performance** | ★★★★★ | Material slots, texture size, draw calls |
| **Printability** | ★★★★☆ | (If physical output) Solid walls, thickness, overhangs |

#### Actionable Improvements
1. **[Urgent]** Fix...
2. **[Optimization]** Reduce...
3. **[Style]** Rename...
```
