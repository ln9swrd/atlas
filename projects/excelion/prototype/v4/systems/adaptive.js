/** Adaptive rules, critical state, pattern chains */

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
  const ratio = boss.hp / boss.maxHp;
  if (ratio > (crit.hpThreshold || 0.3)) return false;
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

export function adaptiveSnapshot(boss, stage) {
  return {
    phase: boss.phase,
    critical: !!boss.critical,
    adaptSpeed: +(boss.adaptSpeed || 1).toFixed(2),
    adaptFake: +(boss.adaptFake || 0).toFixed(2),
    combo: stage.combo,
    perfects: stage.perfects,
    misses: stage.misses,
  };
}
