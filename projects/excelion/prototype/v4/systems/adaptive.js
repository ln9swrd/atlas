/** Adaptive 2.0 + skill curve */

export function createStyleTracker() {
  return {
    early: 0,
    late: 0,
    samples: 0,
    timings: [],
    recordDodge(dashAge, invuln) {
      if (!invuln && dashAge <= 0) return;
      this.samples++;
      this.timings.push(dashAge);
      if (this.timings.length > 40) this.timings.shift();
      if (dashAge < 0.04) this.early++;
      else if (dashAge > 0.1) this.late++;
    },
    recordMissReason(reason) {
      if (!reason) return;
      if (reason.includes('EARLY')) this.early++;
      if (reason.includes('LATE')) this.late++;
      this.samples++;
    },
    stats() {
      const n = Math.max(1, this.samples);
      let variance = 0;
      if (this.timings.length > 1) {
        const mean = this.timings.reduce((a, b) => a + b, 0) / this.timings.length;
        variance = this.timings.reduce((s, x) => s + (x - mean) ** 2, 0) / this.timings.length;
      }
      return {
        dodgeTimingVariance: +variance.toFixed(5),
        earlyInputRate: +(this.early / n).toFixed(2),
        lateInputRate: +(this.late / n).toFixed(2),
        avgReaction: this.timings.length
          ? +(this.timings.reduce((a, b) => a + b, 0) / this.timings.length).toFixed(3)
          : 0,
      };
    },
    reset() {
      this.early = this.late = this.samples = 0;
      this.timings = [];
    },
  };
}

/** skill = perfectRate * (1 + comboAvg factor) */
export function skillScore(stage) {
  const j = Math.max(1, stage.judgments || stage.perfects + stage.goods + stage.misses || 1);
  const perfectRate = (stage.perfects || 0) / j;
  const comboAvg = Math.min(1, (stage.maxCombo || 0) / 40);
  return +(perfectRate * (0.6 + comboAvg * 0.4)).toFixed(3);
}

export function applyStyleAdaptive(boss, styleStats, stage) {
  if (!boss || !boss.def.adaptive) return;
  const rules = boss.def.adaptiveRules || {};
  const st = rules.style || {};
  const maxS = rules.maxSpeedScale || 1.55;
  const maxF = rules.maxFakeRate || 0.75;
  const skill = stage ? skillScore(stage) : 0.5;

  if (styleStats.earlyInputRate > 0.35) {
    boss.adaptFake = Math.min(maxF, (boss.adaptFake || 0) + (st.earlyFeintBonus || 0.12));
  }
  if (styleStats.lateInputRate > 0.35) {
    boss.adaptSpeed = Math.min(maxS, (boss.adaptSpeed || 1) + (st.lateSpeedBonus || 0.08));
  }
  // high skill → more fake pressure; low skill → slight ease (less speed)
  if (skill > 0.65) {
    boss.adaptFake = Math.min(maxF, (boss.adaptFake || 0) + 0.08);
  } else if (skill < 0.3) {
    boss.adaptSpeed = Math.max(1, (boss.adaptSpeed || 1) * 0.97);
  }
}

export function resolveChains(def, lastPatternId, stage) {
  if (!def.chains || !lastPatternId) return null;
  for (const c of def.chains) {
    if (c.from !== lastPatternId) continue;
    if (evalCondition(c.condition, stage)) return c.to;
  }
  return null;
}

function evalCondition(cond, stage) {
  if (!cond) return true;
  if (cond.startsWith('perfectStreak>=')) {
    const n = parseInt(cond.split('>=')[1], 10);
    return (stage.combo || 0) >= n || (stage.perfects || 0) >= n;
  }
  return false;
}

export function applyCritical(boss, stage, feedback, audio) {
  const crit = boss.def.critical;
  if (!crit || boss.critical) return false;
  if (boss.hp / boss.maxHp > (crit.hpThreshold || 0.3)) return false;
  boss.critical = true;
  boss.adaptSpeed = Math.max(boss.adaptSpeed || 1, crit.modifiers?.speed || 1.25);
  boss.adaptFake = Math.max(boss.adaptFake || 0, crit.modifiers?.feintRate || 0.2);
  if (crit.addPatterns) {
    for (const p of crit.addPatterns) {
      if (!boss.extraPatterns.includes(p)) boss.extraPatterns.unshift(p);
    }
  }
  if (feedback) feedback.onCriticalEnter();
  if (audio) {
    audio.setCritical(true);
    audio.phaseBgm(4);
  }
  return true;
}

export function applyFinale(boss, stage, feedback, audio) {
  const fin = boss.def.finale;
  if (!fin || boss.finale) return false;
  if (boss.hp / boss.maxHp > (fin.hpThreshold || 0.1)) return false;
  boss.finale = true;
  boss.phase = 4;
  stage.phase = 4;
  boss.adaptSpeed = Math.max(boss.adaptSpeed || 1, fin.modifiers?.speed || 1.35);
  boss.adaptFake = Math.max(boss.adaptFake || 0, fin.modifiers?.feintRate || 0.35);
  boss.extraPatterns = (fin.addPatterns || []).concat(boss.extraPatterns || []);
  boss.patternCursor = 0;
  if (feedback) feedback.onCriticalEnter();
  if (audio) {
    audio.setCritical(true);
    audio.phaseBgm(5);
  }
  return true;
}

export function adaptiveSnapshot(boss, stage, styleStats) {
  return {
    phase: boss.phase,
    critical: !!boss.critical,
    finale: !!boss.finale,
    adaptSpeed: +(boss.adaptSpeed || 1).toFixed(2),
    adaptFake: +(boss.adaptFake || 0).toFixed(2),
    skill: stage ? skillScore(stage) : 0,
    combo: stage.combo,
    perfects: stage.perfects,
    misses: stage.misses,
    ...(styleStats || {}),
  };
}

export function coachTip(stage, styleStats, lastDeath) {
  if (lastDeath && lastDeath.includes('FAKE')) return '페인트에 속았습니다';
  if (lastDeath && lastDeath.includes('EARLY')) return '조금 빨랐습니다';
  if (lastDeath && lastDeath.includes('LATE')) return '조금 늦었습니다';
  if (styleStats && styleStats.earlyInputRate > 0.4) return '조금 빨랐습니다 — 예고선을 더 보세요';
  if (styleStats && styleStats.lateInputRate > 0.4) return '반응이 늦습니다 — 예고에 맞춰 준비';
  if (stage.misses > stage.perfects) return 'PERFECT 구간을 노려보세요';
  return '안정적입니다 — 콤보를 이어가보세요';
}
