/** Boss + telegraph final 0.1s emphasis · smoothed telegraphScale */

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
    telegraphScale: 1,
    telegraphScaleTarget: 1,
    adaptSamples: 0,
    patternDriven,
    patternCursor: 0,
    extraPatterns: [],
    telegraphMax: 0,
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
  e.adaptSpeed = Math.min(maxS, 1 + (stage.perfects || 0) * (rules.perfectStreakSpeed || 0.05));
  e.adaptFake = Math.min(maxF, (stage.misses || 0) * (rules.missFakeBonus || 0.08));

  // sample count = actual judgments (PERFECT/GOOD/MISS), not frames
  const j = (stage.perfects || 0) + (stage.goods || 0) + (stage.misses || 0);
  e.adaptSamples = j;
  // only after ~5 judgments start moving telegraphScale
  if (j < 5) {
    e.telegraphScaleTarget = 1;
  } else {
    const denom = Math.max(1, j);
    const pr = (stage.perfects || 0) / denom;
    let target = 1;
    if (pr > 0.6) target = Math.max(0.88, 1 - (pr - 0.6) * 0.4);
    else if ((stage.misses || 0) >= 3) target = Math.min(1.12, 1 + 0.03 * Math.min(4, stage.misses));
    e.telegraphScaleTarget = target;
  }
  // smooth lerp — no single-miss spikes
  e.telegraphScale += ((e.telegraphScaleTarget || 1) - (e.telegraphScale || 1)) * 0.12;
}

function pickAction(e) {
  const list = phaseList(e);
  const mod = getMod(e);
  const ts = e.telegraphScale || 1;
  if (!list.length) return { type: 'normal', telegraph: 0.7 * ts, speed: 500, duration: 0.45 };
  if (mod.fake_rate > 0 && Math.random() < mod.fake_rate) {
    e.patternIdx++;
    return {
      type: 'fake',
      paint: 0.35,
      cancel: 0.3,
      telegraph: 0.2 * ts,
      speed: 520 * mod.speed_scale,
      duration: 0.4,
    };
  }
  const act = { ...list[e.patternIdx % list.length] };
  e.patternIdx++;
  if (act.speed) act.speed *= mod.speed_scale;
  if (act.telegraph) act.telegraph *= ts;
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
  if (next !== e.phase && !e.finale) {
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
    if (e.patternDriven) return;
    if (e.timer > 0) return;
    const act = pickAction(e);
    e._act = act;
    if (act.type === 'fake') {
      e.state = 'fake_paint';
      e.timer = act.paint ?? 0.4;
      e.telegraphMax = e.timer;
      aimAt(e, player);
      if (sfx) sfx.warn();
    } else if (act.type === 'combo') {
      e.comboLeft = act.count;
      e.redirectLeft = 0;
      e.state = 'telegraph';
      e.timer = act.telegraph;
      e.telegraphMax = e.timer;
      aimAt(e, player);
      if (sfx) sfx.warn();
    } else if (act.type === 'redirect') {
      e.redirectLeft = act.redirects;
      e.comboLeft = 0;
      e.state = 'telegraph';
      e.timer = act.telegraph;
      e.telegraphMax = e.timer;
      aimAt(e, player);
      if (sfx) sfx.warn();
    } else {
      e.comboLeft = 0;
      e.redirectLeft = 0;
      e.state = 'telegraph';
      e.timer = act.telegraph ?? 0.7;
      e.telegraphMax = e.timer;
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
      e.telegraphMax = e.timer;
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
        e.telegraphMax = gap;
      } else if (e.comboLeft > 1) {
        e.comboLeft--;
        aimAt(e, player);
        e.state = 'telegraph';
        e.timer = gap;
        e.telegraphMax = gap;
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

export function drawBoss(ctx, e, debugHB, player) {
  if (!e.alive) return;
  for (const a of e.afterimage) {
    ctx.globalAlpha = Math.max(0, a.life * 2.2);
    ctx.fillStyle = e.color;
    ctx.beginPath();
    ctx.arc(a.x, a.y, e.r * 0.65, 0, Math.PI * 2);
    ctx.fill();
    ctx.globalAlpha = 1;
  }

  if (e.state === 'telegraph' || e.state === 'fake_paint' || e.state === 'fake_cancel') {
    const progress = e.telegraphMax > 0 ? 1 - Math.max(0, e.timer) / e.telegraphMax : 0.5;
    const timeToImpact = Math.max(0, e.timer);
    let baseR, baseG, baseB, dash;
    if (e.state === 'fake_paint') {
      baseR = 255;
      baseG = 210;
      baseB = 40;
      dash = [6, 10];
    } else if (e.state === 'fake_cancel') {
      baseR = 180;
      baseG = 180;
      baseB = 200;
      dash = [4, 14];
    } else if (progress > 0.72) {
      baseR = 255;
      baseG = 255;
      baseB = 255;
      dash = [];
    } else {
      baseR = 255;
      baseG = 55;
      baseB = 40;
      dash = [10, 6];
    }

    let pulse = 1;
    let brightness = 1;
    if (timeToImpact < 0.4 && e.state === 'telegraph') {
      pulse = 1 + Math.sin(performance.now() / 50) * 0.06;
    }
    // final 0.1s — forced emphasis
    if (timeToImpact < 0.1 && e.state === 'telegraph') {
      pulse = 1.2;
      brightness = 1.5;
      baseR = Math.min(255, Math.round(baseR * brightness));
      baseG = Math.min(255, Math.round(baseG * brightness));
      baseB = Math.min(255, Math.round(baseB * brightness));
    }
    let wobbleX = 0;
    let wobbleY = 0;
    if (e.state === 'fake_paint') {
      wobbleX = Math.sin(performance.now() / 40) * 6;
      wobbleY = Math.cos(performance.now() / 55) * 4;
    }

    const segs = 12;
    const maxDist = 900;
    for (let i = 0; i < segs; i++) {
      const t0 = i / segs;
      const t1 = (i + 1) / segs;
      const x0 = e.x + wobbleX + e.aimX * maxDist * t0;
      const y0 = e.y + wobbleY + e.aimY * maxDist * t0;
      const x1 = e.x + wobbleX + e.aimX * maxDist * t1;
      const y1 = e.y + wobbleY + e.aimY * maxDist * t1;
      let near = 0.35 + t0 * 0.65;
      if (player) {
        const midX = (x0 + x1) / 2;
        const midY = (y0 + y1) / 2;
        const d = Math.hypot(midX - player.x, midY - player.y);
        near = Math.max(near, 1 - Math.min(1, d / 320));
      }
      const alpha = Math.min(1, (0.35 + progress * 0.55) * (0.4 + near * 0.6) * brightness);
      ctx.strokeStyle = `rgba(${baseR},${baseG},${baseB},${alpha})`;
      ctx.lineWidth = (1.5 + progress * 4) * (0.6 + near * 0.9) * pulse;
      ctx.setLineDash(dash);
      ctx.beginPath();
      ctx.moveTo(x0, y0);
      ctx.lineTo(x1, y1);
      ctx.stroke();
    }
    ctx.setLineDash([]);
    ctx.fillStyle = `rgba(${baseR},${baseG},${baseB},${0.6 + progress * 0.4})`;
    ctx.beginPath();
    ctx.arc(e.x + e.aimX * 70 + wobbleX, e.y + e.aimY * 70 + wobbleY, 3 + progress * 4 * pulse, 0, Math.PI * 2);
    ctx.fill();
  }

  if (e.state === 'fake_cancel') {
    ctx.fillStyle = 'rgba(100,120,180,0.12)';
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
