/** Boss from JSON + modifiers + patternDriven mode */

export function makeBossFromDef(def, x, y) {
  const patternDriven = Array.isArray(def.phases) && def.phases[0] && def.phases[0].patterns;
  return {
    def,
    type: def.id,
    displayName: def.displayName,
    color: def.color || '#c44',
    shape: def.shape || 'box',
    x,
    y,
    r: def.radius || 24,
    hp: def.hp,
    maxHp: def.hp,
    damage: def.damage || 22,
    state: 'idle',
    timer: 0.5,
    aimX: -1,
    aimY: 0,
    vx: 0,
    vy: 0,
    scale: 1,
    flash: 0,
    phase: 1,
    patternIdx: 0,
    comboLeft: 0,
    redirectLeft: 0,
    alive: true,
    _act: null,
    afterimage: [],
    adaptSpeed: 1,
    adaptFake: 0,
    patternDriven,
    patternCursor: 0,
    extraPatterns: [],
  };
}

function aimAt(e, player) {
  const dx = player.x - e.x;
  const dy = player.y - e.y;
  const len = Math.hypot(dx, dy) || 1;
  e.aimX = dx / len;
  e.aimY = dy / len;
}

function phaseList(e) {
  if (e.patternDriven) return [];
  const key = String(e.phase);
  return e.def.phases[key] || e.def.phases['1'] || [];
}

function getMod(e) {
  if (e.patternDriven) {
    const ph = e.def.phases.find((p) => p.id === e.phase) || e.def.phases[e.phase - 1];
    const m = (ph && ph.modifier) || {};
    return {
      speed_scale: (m.speed_scale || 1) * (e.adaptSpeed || 1),
      fake_rate: Math.min(0.95, (m.fake_rate || 0) + (e.adaptFake || 0)),
    };
  }
  const m = (e.def.phaseModifiers && e.def.phaseModifiers[String(e.phase)]) || {};
  return {
    speed_scale: (m.speed_scale || 1) * (e.adaptSpeed || 1),
    fake_rate: Math.min(0.95, (m.fake_rate || 0) + (e.adaptFake || 0)),
  };
}

export function updateAdaptive(e, stage) {
  if (!e.def.adaptive || !stage) return;
  const rules = e.def.adaptiveRules || {};
  const maxS = rules.maxSpeedScale || 1.45;
  const maxF = rules.maxFakeRate || 0.7;
  const pBonus = (stage.perfects || 0) * (rules.perfectStreakSpeed || 0.05);
  const fBonus = (stage.misses || 0) * (rules.missFakeBonus || 0.08);
  e.adaptSpeed = Math.min(maxS, 1 + pBonus);
  e.adaptFake = Math.min(maxF, fBonus);
  if (rules.onPerfectStreak && stage.perfects >= 5 && rules.onPerfectStreak.addPattern) {
    if (!e.extraPatterns.includes(rules.onPerfectStreak.addPattern)) {
      e.extraPatterns.push(rules.onPerfectStreak.addPattern);
    }
    e.adaptSpeed = Math.min(maxS, e.adaptSpeed * (rules.onPerfectStreak.speedMultiplier || 1.2));
  }
  if (rules.onMissSpike && stage.misses >= 3) {
    e.adaptFake = Math.min(maxF, e.adaptFake + (rules.onMissSpike.feintChance || 0.4));
  }
}

function pickAction(e) {
  const list = phaseList(e);
  const mod = getMod(e);
  if (!list.length) return { type: 'normal', telegraph: 0.7, speed: 500, duration: 0.45 };
  if (mod.fake_rate > 0 && Math.random() < mod.fake_rate) {
    e.patternIdx++;
    return {
      type: 'fake',
      paint: 0.35,
      cancel: 0.3,
      telegraph: 0.2,
      speed: 520 * mod.speed_scale,
      duration: 0.4,
    };
  }
  const act = { ...list[e.patternIdx % list.length] };
  e.patternIdx++;
  if (act.speed) act.speed *= mod.speed_scale;
  return act;
}

function startCharge(e, duration, speed, sfx) {
  e.state = 'charge';
  e.timer = duration;
  e.vx = e.aimX * speed;
  e.vy = e.aimY * speed;
  e.scale = 1.15;
  if (sfx) sfx.charge();
}

export function syncPhase(e, stage, onPhaseChange) {
  const ratio = e.hp / e.maxHp;
  const next = stage.computePhase(ratio, e.def.phaseThresholds);
  if (next !== e.phase) {
    e.phase = next;
    stage.phase = next;
    e.patternIdx = 0;
    e.patternCursor = 0;
    e.state = 'recover';
    e.timer = 0.7;
    if (onPhaseChange) onPhaseChange(e, next);
  }
}

export function updateBoss(e, dt, player, W, H, sfx, onHitPlayer, stage, onPhaseChange) {
  if (!e.alive) return;
  updateAdaptive(e, stage);
  syncPhase(e, stage, onPhaseChange);
  e.timer -= dt;
  if (e.flash > 0) e.flash -= dt;
  if (e.scale < 1) e.scale = Math.min(1, e.scale + dt * 2.5);

  if (e.state === 'charge') {
    e.afterimage.unshift({ x: e.x, y: e.y, life: 0.18 });
    if (e.afterimage.length > 6) e.afterimage.pop();
  }
  for (const a of e.afterimage) a.life -= dt;
  e.afterimage = e.afterimage.filter((a) => a.life > 0);

  if (e.state === 'idle') {
    if (e.patternDriven) return; // Pattern Runner drives commands
    if (e.timer > 0) return;
    const act = pickAction(e);
    e._act = act;
    if (act.type === 'fake') {
      e.state = 'fake_paint';
      e.timer = act.paint ?? 0.4;
      aimAt(e, player);
      if (sfx) sfx.warn();
    } else if (act.type === 'combo') {
      e.comboLeft = act.count;
      e.redirectLeft = 0;
      e.state = 'telegraph';
      e.timer = act.telegraph;
      aimAt(e, player);
      if (sfx) sfx.warn();
    } else if (act.type === 'redirect') {
      e.redirectLeft = act.redirects;
      e.comboLeft = 0;
      e.state = 'telegraph';
      e.timer = act.telegraph;
      aimAt(e, player);
      if (sfx) sfx.warn();
    } else {
      e.comboLeft = 0;
      e.redirectLeft = 0;
      e.state = 'telegraph';
      e.timer = act.telegraph ?? 0.7;
      aimAt(e, player);
      if (sfx) sfx.warn();
    }
  } else if (e.state === 'fake_paint') {
    if (e.timer <= 0) {
      e.state = 'fake_cancel';
      e.timer = (e._act && e._act.cancel) || 0.3;
    }
  } else if (e.state === 'fake_cancel') {
    if (e.timer <= 0) {
      aimAt(e, player);
      e.state = 'telegraph';
      e.timer = (e._act && e._act.telegraph) || 0.22;
      if (sfx) sfx.warn();
    }
  } else if (e.state === 'telegraph') {
    if (e.timer <= 0) {
      const a = e._act || {};
      startCharge(e, a.duration || 0.45, a.speed || 500, sfx);
    }
  } else if (e.state === 'charge') {
    e.x += e.vx * dt;
    e.y += e.vy * dt;
    const dx = player.x - e.x;
    const dy = player.y - e.y;
    if (dx * dx + dy * dy < (player.r + e.r) ** 2) onHitPlayer(e);
    const m = e.r + 6;
    const hitWall = e.x < m || e.x > W - m || e.y < m || e.y > H - m;
    if (hitWall || e.timer <= 0) {
      e.x = Math.max(m, Math.min(W - m, e.x));
      e.y = Math.max(m, Math.min(H - m, e.y));
      e.vx = e.vy = 0;
      e.scale = 1;
      const gap = (e._act && e._act.gap) || 0.26;
      if (e.redirectLeft > 0) {
        e.redirectLeft--;
        aimAt(e, player);
        e.state = 'telegraph';
        e.timer = gap;
      } else if (e.comboLeft > 1) {
        e.comboLeft--;
        aimAt(e, player);
        e.state = 'telegraph';
        e.timer = gap;
      } else {
        e.comboLeft = 0;
        e.redirectLeft = 0;
        e.state = 'recover';
        e.timer = 0.55;
      }
    }
  } else if (e.state === 'recover') {
    if (e.timer <= 0) {
      e.state = 'idle';
      e.timer = 0.25;
    }
  }
}

export function drawBoss(ctx, e, debugHB) {
  if (!e.alive) return;
  for (const a of e.afterimage) {
    ctx.globalAlpha = Math.max(0, a.life * 2.2);
    ctx.fillStyle = e.color;
    ctx.beginPath();
    ctx.arc(a.x, a.y, e.r * 0.65, 0, Math.PI * 2);
    ctx.fill();
    ctx.globalAlpha = 1;
  }
  if (e.state === 'telegraph' || e.state === 'fake_paint') {
    const col = e.state === 'fake_paint' ? 'rgba(160,170,255,0.55)' : 'rgba(255,200,40,0.92)';
    ctx.strokeStyle = col;
    ctx.lineWidth = e._act && e._act.type === 'fast' ? 3 : 4;
    ctx.setLineDash(e.state === 'fake_paint' ? [5, 12] : [10, 8]);
    ctx.beginPath();
    ctx.moveTo(e.x, e.y);
    ctx.lineTo(e.x + e.aimX * 900, e.y + e.aimY * 900);
    ctx.stroke();
    ctx.setLineDash([]);
  }
  if (e.state === 'fake_cancel') {
    ctx.fillStyle = 'rgba(100,120,180,0.15)';
    ctx.beginPath();
    ctx.arc(e.x, e.y, 55, 0, Math.PI * 2);
    ctx.fill();
  }
  ctx.save();
  ctx.translate(e.x, e.y);
  ctx.scale(e.scale, e.scale);
  ctx.fillStyle = e.flash > 0 ? '#ffffff' : e.color;
  if (e.shape === 'triangle') {
    ctx.beginPath();
    ctx.moveTo(0, -e.r * 1.2);
    ctx.lineTo(e.r, e.r);
    ctx.lineTo(-e.r, e.r);
    ctx.closePath();
    ctx.fill();
  } else if (e.shape === 'shield') {
    ctx.beginPath();
    ctx.moveTo(0, -e.r);
    ctx.lineTo(e.r * 0.9, -e.r * 0.3);
    ctx.lineTo(e.r * 0.7, e.r);
    ctx.lineTo(-e.r * 0.7, e.r);
    ctx.lineTo(-e.r * 0.9, -e.r * 0.3);
    ctx.closePath();
    ctx.fill();
  } else {
    ctx.fillRect(-e.r * 0.75, -e.r * 0.85, e.r * 1.5, e.r * 1.7);
  }
  ctx.restore();
  if (debugHB) {
    ctx.strokeStyle = '#0f0';
    ctx.beginPath();
    ctx.arc(e.x, e.y, e.r, 0, Math.PI * 2);
    ctx.stroke();
  }
}
