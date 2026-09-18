# PLAYTEST_RESULT — 2026-08-09

> Method: document walkthrough + tabletop (B1) · **no** Forge / UE / images  
> Scope: EP1 · EP6 · EP8 · Sources: VERTICAL_SLICE · PLAYTEST_SCOPE · BALANCE_SOR · BOSS_STATS · scene scripts · SETH_BATTLE_FIXED · PLAY_DESIGN_6STEPS

---

## Verdict summary

| EP | Design fun | Difficulty intent | Character motive | Gate |
|----|------------|-------------------|------------------|------|
| **EP1** | Pass (with notes) | Easy / tutorial | Pass | Conditional pass |
| **EP6** | Pass | Mid boss 4–7m | Pass | Pass |
| **EP8** | Pass (high stakes) | Stress + partial clear | Pass | Conditional pass |

**Overall:** Vertical slice design is coherent enough to proceed. Main risks are (1) EP1 Kai seed vs H1 naming consistency, (2) EP8 dual-layer clarity in UI, (3) residual Ashur wording in older combat docs.

---

## EP1 — 동기화 (first loop + Kai seed)

### Walkthrough

1. Boarding is a **choice** (not forced) — fantasy OK  
2. Loop: approach → combo → push → special → clear  
3. GRUNT HP15 · special 40 · multi 4–6 — tabletop: special clears cluster in 1 hit once S-Core ≥50  
4. Sample S-Core I: ~30s combat + 10 hits ≈ 65 ≥ 50 → first special available  
5. Time target 2–4m combat fits  
6. Closing line locked: 「세계가 끝났는데, 나는 아직 여기 있다.」

### Fun / difficulty / direction

| Check | Result |
|-------|--------|
| 30s “I board” readable | Pass (script CUT01–03) |
| Special feels rewarding | Pass on numbers |
| Failure = HP0 retry | Pass |
| Kai attachment seed for EP8 | **Risk** |

### Issues

1. **Kai line inconsistency (report only)**  
   - VERTICAL_SLICE / KAI habit: H1「콜.」  
   - EP1_EP8_SCENE_SCRIPT: 「내리지 마.」  
   → EP8 payoff needs a **single** memorable seed. Not fixed here.

2. Tutorial density: first special + heat + dash in one short stage may overwhelm if all taught at once (tabletop only — confirm in later proto).

### Improvements (design, not implemented)

- Pick one EP1 Kai seed line and mirror in slice + script  
- Optionally delay Heat teaching to EP2 if first session feels heavy

---

## EP6 — 달의 그림자 (Seth 1:1)

### Walkthrough

| Phase | HP band | Behavior |
|-------|---------|----------|
| P1 | 480→144 | Block fire · seal gauge 240 |
| P2 | 144→0 | Prosecute · expose window · re-block 1 |

Weakness: obsession break ×1.5 · overload delay ×1.3  
Clear: HP0 · 「…보고, 끝.」 · Nemesis distant stare 1 cut  
Carry line: 「승리가 쌓여도 전망은 없었다.」

### Tabletop tension

- Player HP100 · Seth hits 8–22 → 5–12 hits to death if passive → forces movement  
- 4–7 minute target with HP480 and special 40 is plausible if seal windows open  
- Tone rules (no tragedy lead, ≤1 micro-crack) support “cold wall” fantasy

### Fun / motive

| Check | Result |
|-------|--------|
| Want to break this enemy | Pass |
| Not final wall (stair) | Pass vs Nemesis later HP |
| Seth emotion crack ≤1 | Pass if script held |
| Post-clear “no outlook” | Pass |

### Issues

1. **Legacy wording (report only)**  
   `SETH_BATTLE_FIXED.md` still mentions 아슈르원경 / EP7 아슈르 일격 in checklist while EPISODE_MATRIX / 09_STORY lock **Nemesis** and **Ashur discarded**.  
   → Docs drift · do not change settings here.

2. Seal gauge 240 vs player DPS needs practical feel later; on paper OK.

### Improvements

- Align SETH_BATTLE leftover Ashur strings to Nemesis (docs PR later)  
- Keep “보고, 끝.” non-negotiable

---

## EP8 — 선택의 무게 (partial success + loss)

### Walkthrough

| Layer | Rule |
|-------|------|
| Game | Hold base · partial objectives OK |
| Story | Overload 3s → Kai sacrifice · comms cut · **fixed** |

Enemy: GRUNT/HEAVY waves · not boss  
S-Core II ×1.3 · time 6–10m  
Kai H3「끝나면 내려.」 · Lia「…헛되게 안 해.」

### Fun / difficulty / motive

| Check | Result |
|-------|--------|
| Dual layer (clear ≠ save Kai) | Design Pass · **UI risk** |
| Overload read as cost not buff | Pass if hand/visual signals kept |
| EP1 seed → EP8 pain | Pass **if** EP1 seed consistent |
| Retry does not restore Kai | Pass (story lock) |

### Issues

1. Players may interpret stage clear as “Kai survived” unless UI/story framing is explicit.  
2. Without EP1 seed consistency, sacrifice lands hollow.  
3. Wave HP mix (15 / 45) with II multiplier should feel stronger than EP1 — OK on paper.

### Improvements

- Result screen: separate **Mission** vs **Story** outcome lines  
- Protect 3s overload telegraphs (hand stop · crack) as mandatory direction notes for later proto

---

## Cross-slice measurement

| Metric | EP1 | EP6 | EP8 |
|--------|-----|-----|-----|
| Loop rhythm | OK | OK | OK |
| Growth feel EP1→6 | Special + boss stair | — | II multiplier |
| Tension | Low | Mid-high | High emotional |
| Climax | First special | P2 break | Overload + loss |
| Attachment | Seed | H1 optional | Payoff |

---

## Confirmed improvement backlog (design only)

| ID | Item | Priority |
|----|------|----------|
| P1 | Unify EP1 Kai seed line across VERTICAL_SLICE / scene script / KAI_HABIT | High |
| P2 | EP8 mission UI: game clear ≠ story loss messaging | High |
| P3 | Scrub Ashur leftovers in SETH_BATTLE / related combat notes → Nemesis | Med |
| P4 | Optional: thin EP1 teaching (Heat) | Low |
| P5 | Later: proto validate seal 240 / overload 3s timing | After HOLD tools |

---

## State conflicts (report only — not fixed)

- CURRENT_STATE = idle  
- MILESTONES = M5 Active  
- DESIGN_TASK_MAP = ORD-GRUNT Next  
- TASK_MAP = Playtest Open → **this result completes the playtest execution document**

SoR single-line cleanup deferred until Master reviews this + Forge survey.

---

## Non-actions

No code · no UE · no Meshy · no images · no novel prose · no TEXT-LOCK setting changes.
