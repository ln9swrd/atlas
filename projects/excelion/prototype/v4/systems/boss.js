/** Enemy factory + state machine from boss_patterns.json */

export function makeEnemy(type, x, y, data) {
  const d = data[type] || data.montu;
  const hp = d.hp ?? 50;
  return {
    type,
    x,
    y,
    r: type === 'anubis' ? 32 : 20,
    hp,
    maxHp: hp,
    state: 'idle',
    timer: 0.4 + Math.random() * 0.4,
    aimX: 1,
    aimY: 0,
    vx: 0,
    vy: 0,
    scale: 1,
    flash: 0,
    chargeCount: 0,
    comboLeft: 0,
    redirectLeft: 0,
    phase: 1,
    patternIdx: 0,
    alive: true,
    speedMul: 1,
    damage: d.damage ?? 22,
  };
}

function aimAt(e, player) {
  const dx = player.x - e.x;
  const dy = player.y - e.y;
  const len = Math.hypot(dx, dy) || 1;
  e.aimX = dx / len;
  e.aimY = dy / len;
}

function startCharge(e, duration, speed, sfx) {
  e.state = 'charge';
  e.timer = duration;
  e.vx = e.aimX * speed;
  e.vy = e.aimY * speed;
  e.scale = 1.15;
  if (sfx) sfx.charge();
}

function pickAnubisAction(e, data) {
  const phase = e.hp <= e.maxHp * (data.anubis.phaseThreshold ?? 0.5) ? 2 : 1;
  e.phase = phase;
  const list = phase === 2 ? data.anubis.phase2 : data.anubis.phase1;
  const act = list[e.patternIdx % list.length];
  e.patternIdx++;
  return act;
}

export function updateEnemy(e, dt, player, data, W, H, sfx, onHitPlayer) {
  if (!e.alive) return;
  e.timer -= dt;
  if (e.flash > 0) e.flash -= dt;
  if (e.scale < 1) e.scale = Math.min(1, e.scale + dt * 2.5);

  const typeData = data[e.type] || data.montu;

  if (e.state === 'idle') {
    if (e.timer > 0) return;
    if (e.type === 'fake') {
      e.state = 'fake_paint';
      e.timer = typeData.paint ?? 0.4;
      aimAt(e, player);
      if (sfx) sfx.warn();
    } else if (e.type === 'anubis') {
      const act = pickAnubisAction(e, data);
      e._act = act;
      if (act.type === 'combo') {
        e.comboLeft = act.count;
        e.redirectLeft = 0;
        e.state = 'telegraph';
        e.timer = act.telegraph;
      } else if (act.type === 'redirect') {
        e.redirectLeft = act.redirects;
        e.comboLeft = 0;
        e.state = 'telegraph';
        e.timer = act.telegraph;
      } else {
        e.comboLeft = 0;
        e.redirectLeft = 0;
        e.state = 'telegraph';
        e.timer = act.telegraph;
      }
      aimAt(e, player);
      if (sfx) sfx.warn();
    } else {
      e.state = 'telegraph';
      e.timer = typeData.telegraph ?? 0.8;
      aimAt(e, player);
      if (sfx) sfx.warn();
    }
  } else if (e.state === 'fake_paint') {
    if (e.timer <= 0) {
      e.state = 'fake_cancel';
      e.timer = typeData.cancel ?? 0.3;
    }
  } else if (e.state === 'fake_cancel') {
    if (e.timer <= 0) {
      aimAt(e, player);
      e.state = 'telegraph';
      e.timer = typeData.telegraph ?? 0.22;
      if (sfx) sfx.warn();
    }
  } else if (e.state === 'telegraph') {
    if (e.timer <= 0) {
      let speed = typeData.chargeSpeed ?? 500;
      let dur = typeData.chargeDuration ?? 0.48;
      if (e.type === 'anubis' && e._act) {
        const a = e._act;
        speed = a.baseSpeed || a.speed || speed;
        if (a.speedMin) speed *= a.speedMin + Math.random() * ((a.speedMax || a.speedMin) - a.speedMin);
        dur = a.duration || dur;
      }
      startCharge(e, dur, speed, sfx);
    }
  } else if (e.state === 'charge') {
    e.x += e.vx * dt;
    e.y += e.vy * dt;
    const dx = player.x - e.x;
    const dy = player.y - e.y;
    if (dx * dx + dy * dy < (player.r + e.r) ** 2) {
      onHitPlayer(e);
    }
    const m = e.r + 6;
    const hitWall = e.x < m || e.x > W - m || e.y < m || e.y > H - m;
    if (hitWall || e.timer <= 0) {
      e.x = Math.max(m, Math.min(W - m, e.x));
      e.y = Math.max(m, Math.min(H - m, e.y));
      e.vx = e.vy = 0;
      e.scale = 1;
      e.chargeCount++;
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
        e.timer = e.type === 'anubis' ? 0.5 : 0.6;
      }
    }
  } else if (e.state === 'recover') {
    if (e.timer <= 0) {
      e.state = 'idle';
      e.timer = 0.3 + Math.random() * 0.35;
    }
  }
}

export function drawEnemy(ctx, e, debugHB) {
  if (!e.alive) return;
  if (e.state === 'telegraph' || e.state === 'fake_paint') {
    const col = e.state === 'fake_paint' ? 'rgba(160,170,255,0.55)' : 'rgba(255,200,40,0.92)';
    ctx.strokeStyle = col;
    ctx.lineWidth = e.type === 'fast' ? 3 : 4;
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
    ctx.arc(e.x, e.y, 50, 0, Math.PI * 2);
    ctx.fill();
  }
  ctx.save();
  ctx.translate(e.x, e.y);
  ctx.scale(e.scale, e.scale);
  const atk = e.state === 'charge' || e.state === 'telegraph';
  if (e.type === 'anubis') {
    ctx.fillStyle = e.flash > 0 ? '#f0d0ff' : atk ? '#9b4dff' : '#4a3a6a';
    ctx.beginPath();
    ctx.moveTo(0, -36);
    ctx.lineTo(28, 28);
    ctx.lineTo(-28, 28);
    ctx.closePath();
    ctx.fill();
  } else if (e.type === 'fast') {
    ctx.fillStyle = e.flash > 0 ? '#ffe08a' : atk ? '#e6a817' : '#5c4a1a';
    ctx.beginPath();
    ctx.moveTo(18, 0);
    ctx.lineTo(-14, -14);
    ctx.lineTo(-14, 14);
    ctx.closePath();
    ctx.fill();
  } else if (e.type === 'fake') {
    ctx.fillStyle = e.flash > 0 ? '#cce' : atk ? '#6688cc' : '#2a3550';
    ctx.fillRect(-16, -18, 32, 36);
  } else {
    ctx.fillStyle = e.flash > 0 ? '#f86' : atk ? '#c44' : '#3d4450';
    ctx.fillRect(-16, -18, 32, 36);
  }
  ctx.restore();
  if (debugHB) {
    ctx.strokeStyle = '#0f0';
    ctx.beginPath();
    ctx.arc(e.x, e.y, e.r, 0, Math.PI * 2);
    ctx.stroke();
  }
}
